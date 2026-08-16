import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../data/bot_modal_api.dart';
import '../../data/bot_modal_service.dart';
import '../../data/models/bot_modal_dtos.dart';
import '../bot_modal_field.dart';

/// Turns a failed submit into copy that tells the user which of the three
/// things went wrong.
///
/// The route's own failure modes, distinctly: `403` is a permission check on
/// the channel (`SendMessages` and `UseApplicationCommands`, the same pair a
/// slash command needs), `404` is the bot being disabled or no longer installed
/// here, and a [DioException] carrying no response at all is the request never
/// reaching the server - the Dart equivalent of Alpine's `status: 0`.
///
/// Three separate sentences rather than one apology, because the three want
/// three different reactions: ask someone with permissions, stop waiting for
/// this bot, or check your connection and press Submit again.
String describeModalSubmitFailure(Object error) {
  if (error is! DioException) return 'Something went wrong sending this form.';
  final response = error.response;
  if (response == null) {
    return 'Could not reach the server. Check your connection and try again.';
  }
  return switch (response.statusCode) {
    403 =>
      'You do not have permission to send messages in this channel, so this '
          'form cannot be submitted.',
    404 =>
      'This bot is no longer available in this server, so it cannot receive '
          'this form.',
    _ => 'Something went wrong sending this form.',
  };
}

/// Renders a modal a bot asked for, and sends the answer back.
///
/// `guild.ModalOpen` arrives with the `customId` the bot correlates the reply
/// on; `POST /bots/guilds/{g}/channels/{c}/modal-submit` is where it goes, via
/// [BotModalApi.submitModal]. That route answers `202`, which means the
/// MODAL_SUBMIT interaction has been handed to the bot's gateway connection -
/// not that the bot has done anything with it. So a successful submit closes
/// the dialog and stops there: whatever the bot decides to do arrives
/// afterwards as an ordinary message or an ephemeral push, and a "Sent!"
/// confirmation here would be this client vouching for a process it cannot see.
///
/// Reads [BotModalService.request] live rather than taking the payload as a
/// constructor argument. A second modal replacing the first has to re-seed this
/// form in place - the route is already up, and pushing another dialog over it
/// would leave a form standing over an interaction that has moved on.
class BotModalDialog extends StatefulWidget {
  const BotModalDialog({super.key, required this.service, required this.api});

  final BotModalService service;
  final BotModalApi api;

  @override
  State<BotModalDialog> createState() => _BotModalDialogState();
}

class _BotModalDialogState extends State<BotModalDialog> {
  /// The payload this form is currently seeded from. Compared by identity on
  /// every notification, so a re-emission of the same object leaves whatever
  /// the user has typed alone.
  BotModalOpenDto? _request;

  List<ModalField> _fields = const [];
  final _controllers = <String, TextEditingController>{};

  /// Validation messages stay hidden until the first submit attempt. A form
  /// that turns red before it has been touched reads as broken; one that stays
  /// silent after a rejected Submit reads as a dead button.
  bool _attempted = false;

  bool _submitting = false;

  /// The last failure from the submit route, already turned into something a
  /// user can act on.
  String? _error;

  @override
  void initState() {
    super.initState();
    _seed(widget.service.request.value);
    widget.service.request.addListener(_onRequestChanged);
  }

  @override
  void dispose() {
    widget.service.request.removeListener(_onRequestChanged);
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onRequestChanged() {
    final request = widget.service.request.value;
    // Null is the close signal, from any of the four things that can produce
    // one: Cancel, an accepted submit, the barrier, or a sign-out clearing the
    // service out from under an open form. Popping here rather than at each of
    // those sites is what keeps them from disagreeing about whether the dialog
    // is up.
    if (request == null) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    if (identical(request, _request)) return;
    setState(() => _seed(request));
  }

  /// Rebuilds the whole form from [request], discarding every answer.
  ///
  /// Wholesale rather than merged by `custom_id`: the second modal is a
  /// different question from a bot that has already seen the first one's
  /// answer, and carrying a value across on a name collision would submit
  /// something the user never typed into the form they are looking at.
  void _seed(BotModalOpenDto? request) {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    _request = request;
    _fields = flattenModalRows(
      request?.components ?? const [],
    ).indexed.map((entry) => toModalField(entry.$2, entry.$1)).toList();
    for (final field in _fields) {
      _controllers[field.key] = TextEditingController(text: field.initialValue)
        // Re-runs validation as the user types, but only after a rejected
        // Submit has put the messages on screen - see [_attempted].
        ..addListener(_onValueChanged);
    }
    _attempted = false;
    _submitting = false;
    _error = null;
  }

  void _onValueChanged() {
    if (_attempted && mounted) setState(() {});
  }

  Map<String, String> get _values => {
    for (final entry in _controllers.entries) entry.key: entry.value.text,
  };

  Map<String, String> get _fieldErrors {
    final values = _values;
    final errors = <String, String>{};
    for (final field in _fields) {
      if (field.isUnsupported) continue;
      final error = validateModalField(field, values[field.key] ?? '');
      if (error != null) errors[field.key] = error;
    }
    return errors;
  }

  Future<void> _submit() async {
    final request = _request;
    if (request == null || _submitting) return;

    setState(() {
      _attempted = true;
      _error = null;
    });
    if (_fieldErrors.isNotEmpty) return;

    // Re-checked rather than trusted from the disabled button: `isAnswerable`
    // is what decides whether there is a route to call at all, and the two
    // pieces it needs are also the two the request is built from.
    final guildId = request.guildId?.trim();
    final customId = request.customId?.trim();
    if (guildId == null ||
        guildId.isEmpty ||
        customId == null ||
        customId.isEmpty) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.api.submitModal(
        guildId: guildId,
        channelId: request.channelId,
        botUserId: request.botUserId,
        customId: customId,
        components: buildModalSubmitRows(_fields, _values),
      );
      // Closing the service is what pops this route - see [_onRequestChanged].
      widget.service.close();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = describeModalSubmitFailure(e);
      });
    }
  }

  /// Cancel and the barrier both go through the service rather than popping
  /// directly, so the request is cleared even on the paths this widget never
  /// hears about.
  void _dismiss() => widget.service.close();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = _request;
    final title = request?.title?.trim();
    final answerable = request?.isAnswerable ?? false;
    final errors = _attempted ? _fieldErrors : const <String, String>{};

    return PopScope(
      // A submit in flight has already been handed to the server; letting the
      // route go here would leave the answer sent and the user with no account
      // of whether it worked.
      canPop: !_submitting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) widget.service.close();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.smart_toy_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        // The bot's own title, or a neutral stand-in. Nothing
                        // here names the bot: the payload carries its user id
                        // and not its name, and resolving one would be a
                        // profile fetch in the way of a form the user is
                        // already looking at.
                        title != null && title.isNotEmpty
                            ? title
                            : 'A bot needs some details',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: _buildBody(theme, answerable, errors),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _submitting ? null : _dismiss,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    FilledButton(
                      onPressed: !answerable || _submitting ? null : _submit,
                      child: _submitting
                          ? AdaptiveProgressIndicator(
                              size: 16,
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            )
                          : const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(
    ThemeData theme,
    bool answerable,
    Map<String, String> errors,
  ) {
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return [
      if (_fields.isEmpty)
        Text(
          'This bot sent a form with no fields in it.',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      for (final field in _fields) ...[
        _buildField(theme, field, errors[field.key]),
        const SizedBox(height: AppSpacing.m),
      ],

      // Only shown for a payload that cannot be answered at all - no customId,
      // or no guild in a route that needs one. Everything else gets a working
      // Submit button.
      if (!answerable)
        _Notice(
          icon: Icons.info_outline,
          color: theme.colorScheme.tertiary,
          message:
              'This form arrived without the identifier the bot needs to '
              'match up an answer, so it cannot be sent back.',
        ),
      if (_error != null) ...[
        if (!answerable) const SizedBox(height: AppSpacing.s),
        _Notice(
          icon: Icons.error_outline,
          color: theme.colorScheme.error,
          message: _error!,
        ),
      ],
    ];
  }

  Widget _buildField(ThemeData theme, ModalField field, String? error) {
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                field.label,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              field.isRequired ? '(required)' : '(optional)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (field.isUnsupported)
          Text(
            'This bot asked for an input this client does not render yet.',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          )
        else
          TextField(
            controller: _controllers[field.key],
            enabled: !_submitting,
            // The bound is enforced on the keyboard rather than only on
            // Submit, which is what the browser's `maxlength` attribute does on
            // the desktop client. Material draws its own "12/200" counter off
            // this, which the web version has no equivalent of - kept, because
            // on a phone the field is small enough that running out of room
            // without warning is a real surprise.
            maxLength: field.maxLength,
            minLines: field.isParagraph ? 3 : 1,
            maxLines: field.isParagraph ? 5 : 1,
            keyboardType: field.isParagraph
                ? TextInputType.multiline
                : TextInputType.text,
            textInputAction: field.isParagraph
                ? TextInputAction.newline
                : TextInputAction.next,
            decoration: InputDecoration(
              hintText: field.placeholder.isEmpty ? null : field.placeholder,
              isDense: true,
            ),
          ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// The two tinted callouts at the foot of the form - "this cannot be sent" and
/// "sending it failed". One widget because they differ only in colour, icon and
/// sentence, and the shape is the thing that has to stay identical between them.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
