import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/conversation_member_service.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../friends/data/models/relationship_model.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../../mls/data/models/mls_dtos.dart';
import '../../data/conversation_repository.dart';
import '../../data/models/conversation_dto.dart';
import 'conversation_icon.dart';

/// Everything a group DM's identity and roster can be changed from: its name,
/// its icon, who is in it, and leaving.
///
/// One surface rather than Alpine's separate rename modal because a handset
/// has no header to hang a second entry point off - the title is the only
/// affordance there is, and it should lead somewhere that answers every
/// question about the group rather than just one of them.
///
/// Returns true when the conversation was left, so the caller can pop the
/// thread behind it. Every other change is published through
/// [ConversationRepository] and needs nothing from the caller.
Future<bool> showGroupSettingsSheet({
  required BuildContext context,
  required String conversationId,
}) async {
  final left = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    // The shell's nav rail is a sibling of the content pane's Navigator, so
    // without this the sheet is clipped to the pane instead of the device.
    useRootNavigator: true,
    builder: (context) => _GroupSettingsSheet(conversationId: conversationId),
  );
  return left ?? false;
}

class _GroupSettingsSheet extends StatefulWidget {
  const _GroupSettingsSheet({required this.conversationId});

  final String conversationId;

  @override
  State<_GroupSettingsSheet> createState() => _GroupSettingsSheetState();
}

class _GroupSettingsSheetState extends State<_GroupSettingsSheet> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  ConversationDto? _conversation;
  bool _savingName = false;
  bool _busyIcon = false;
  bool _leaving = false;

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  @override
  void initState() {
    super.initState();
    _adopt(_held());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ConversationDto? _held() => getIt<ConversationRepository>().cached
      .where((c) => c.id == widget.conversationId)
      .firstOrNull;

  /// Seeds the controls from a conversation.
  ///
  /// The name field is only re-seeded while it matches what is stored: a push
  /// landing mid-edit must not overwrite what is being typed, which is the one
  /// thing here the user cannot get back.
  void _adopt(ConversationDto? conversation) {
    if (conversation == null) return;
    final stored = conversation.name ?? '';
    final untouched =
        _conversation == null ||
        _nameController.text == (_conversation!.name ?? '');
    setState(() {
      _conversation = conversation;
      if (untouched) _nameController.text = stored;
    });
  }

  void _report(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // -- Name -------------------------------------------------------------------

  Future<void> _saveName() async {
    final conversation = _conversation;
    if (conversation == null || _savingName) return;

    final typed = _nameController.text.trim();
    if (typed == (conversation.name ?? '')) return;

    setState(() => _savingName = true);
    try {
      _adopt(
        await getIt<ConversationRepository>().rename(
          conversation.id,
          typed.isEmpty ? null : typed,
        ),
      );
      _report(typed.isEmpty ? 'Name cleared.' : 'Group renamed.');
    } catch (e) {
      _report(apiErrorMessage(e) ?? 'Could not rename the group.');
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  // -- Icon -------------------------------------------------------------------

  Future<void> _pickIcon() async {
    final conversation = _conversation;
    if (conversation == null || _busyIcon) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;

    setState(() => _busyIcon = true);
    try {
      final bytes = await file.readAsBytes();
      _adopt(
        await getIt<ConversationRepository>().setIcon(
          conversation.id,
          bytes: bytes,
          fileName: file.name,
        ),
      );
    } catch (e) {
      _report(apiErrorMessage(e) ?? 'Could not upload the icon.');
    } finally {
      if (mounted) setState(() => _busyIcon = false);
    }
  }

  Future<void> _removeIcon() async {
    final conversation = _conversation;
    if (conversation == null || _busyIcon) return;

    setState(() => _busyIcon = true);
    try {
      _adopt(await getIt<ConversationRepository>().removeIcon(conversation.id));
    } catch (e) {
      _report(apiErrorMessage(e) ?? 'Could not remove the icon.');
    } finally {
      if (mounted) setState(() => _busyIcon = false);
    }
  }

  // -- Members ----------------------------------------------------------------

  Future<void> _addPeople() async {
    final conversation = _conversation;
    if (conversation == null) return;

    final existing = conversation.members.map((m) => m.userId).toSet();
    final picked = await showDialog<List<MinimalProfileId>>(
      context: context,
      builder: (_) => _AddPeopleDialog(excludeUserIds: existing),
    );
    if (picked == null || picked.isEmpty || !mounted) return;

    final service = getIt<ConversationMemberService>();
    final unreachable = <UnreachableDeviceDto>[];
    final failed = <String>[];
    ConversationDto? latest;

    // One call per person: the service takes a single user id, and an MLS
    // commit per addition is the honest shape anyway - a failure half way
    // through has genuinely added the people before it.
    for (final person in picked) {
      try {
        final result = await service.addMember(
          conversationId: conversation.id,
          userId: person.userId,
        );
        latest = result.conversation;
        unreachable.addAll(result.unreachableDevices);
      } catch (_) {
        failed.add(person.userName);
      }
    }

    // The service does not touch the repository and the server broadcasts
    // nothing this client listens for on an add, so without this the roster
    // is only right on the next full list read.
    if (latest != null) {
      getIt<ConversationRepository>().replaceCached(latest);
      _adopt(latest);
    }

    if (!mounted) return;
    if (failed.isNotEmpty) {
      _report('Could not add ${failed.join(', ')}.');
    }
    // Reported after the fact rather than confirmed in advance: unlike
    // creating a conversation, the add has already happened by the time the
    // unreachable devices are known, so this is news and not a choice.
    if (unreachable.isNotEmpty) await _reportUnreachable(unreachable);
  }

  Future<void> _reportUnreachable(List<UnreachableDeviceDto> devices) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Some devices cannot read this group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'These devices had no encryption keys available, so they will '
              'not be able to read this conversation until they are let back '
              'in - including anything sent in the meantime.',
            ),
            const SizedBox(height: AppSpacing.s),
            for (final device in devices)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('- ${device.deviceName ?? device.deviceId}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _leave() async {
    final conversation = _conversation;
    if (conversation == null || _leaving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave group?'),
        content: const Text(
          'You will stop receiving messages from this group, and you will '
          'need to be added back to rejoin it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _leaving = true);
    try {
      await getIt<ConversationRepository>().close(conversation.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _leaving = false);
      _report(apiErrorMessage(e) ?? 'Could not leave the group.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conversation = _conversation;
    if (conversation == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final others = conversation.members
        .where((m) => m.userId != _myUserId)
        .toList();
    final hasIcon = conversation.iconUpdatedAt != null;
    final dirty = _nameController.text.trim() != (conversation.name ?? '');

    return SafeArea(
      child: Padding(
        // The keyboard is up for most of this sheet's life; without the
        // viewInsets the name field it exists for is behind it.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ConversationIcon(
                      conversation: conversation,
                      myUserId: _myUserId,
                      radius: 40,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: IconButton.filled(
                        iconSize: 18,
                        tooltip: 'Change icon',
                        onPressed: _busyIcon ? null : _pickIcon,
                        icon: _busyIcon
                            ? const ButtonProgressIndicator()
                            : const Icon(Icons.edit),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasIcon)
                Center(
                  child: TextButton(
                    onPressed: _busyIcon ? null : _removeIcon,
                    child: const Text('Remove icon'),
                  ),
                ),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: _nameController,
                maxLength: 100,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _saveName(),
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  helperText: 'Leave blank to show the member names instead.',
                ),
              ),
              FilledButton(
                onPressed: !dirty || _savingName ? null : _saveName,
                child: _savingName
                    ? const ButtonProgressIndicator()
                    : const Text('Save name'),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${conversation.members.length} members',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addPeople,
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Add people'),
                  ),
                ],
              ),
              for (final member in others)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: UserAvatar(
                    userId: member.userId,
                    fallbackLabel: member.cachedUserName,
                    showStatus: true,
                  ),
                  title: Text(member.cachedUserName),
                ),
              const Divider(height: AppSpacing.l),
              TextButton.icon(
                onPressed: _leaving ? null : _leave,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Leave group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Friend picker for adding people to a group already in progress.
///
/// Deliberately separate from `showNewConversationDialog`: that one decides
/// encryption and a group name, neither of which is still open once the
/// conversation exists.
class _AddPeopleDialog extends StatefulWidget {
  const _AddPeopleDialog({required this.excludeUserIds});

  final Set<String> excludeUserIds;

  @override
  State<_AddPeopleDialog> createState() => _AddPeopleDialogState();
}

class _AddPeopleDialogState extends State<_AddPeopleDialog> {
  final Set<String> _selected = {};
  List<MinimalProfileId> _candidates = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    try {
      final relationships = await getIt<RelationshipRepository>().fetch();
      final friends = relationships
          .where((r) => r.status == RelationshipStatus.friends)
          .map((r) => r.otherParty(myUserId))
          .where((f) => !widget.excludeUserIds.contains(f.userId))
          .toList();
      if (mounted) {
        setState(() {
          _candidates = friends;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add people'),
      content: SizedBox(
        width: double.maxFinite,
        height: 320,
        child: _loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : _candidates.isEmpty
            ? const Center(child: Text('Everyone you know is already here.'))
            : ListView.builder(
                itemCount: _candidates.length,
                itemBuilder: (context, index) {
                  final friend = _candidates[index];
                  return CheckboxListTile.adaptive(
                    value: _selected.contains(friend.userId),
                    onChanged: (_) => setState(() {
                      if (!_selected.remove(friend.userId)) {
                        _selected.add(friend.userId);
                      }
                    }),
                    secondary: UserAvatar(
                      userId: friend.userId,
                      fallbackLabel: friend.userName,
                      onTap: () => setState(() {
                        if (!_selected.remove(friend.userId)) {
                          _selected.add(friend.userId);
                        }
                      }),
                    ),
                    title: Text(friend.userName),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(
                  _candidates
                      .where((f) => _selected.contains(f.userId))
                      .toList(),
                ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
