import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../device/device_id_service.dart';
import 'mls_service.dart';
import 'mls_sync_service.dart';

/// Why an approval did not result in an admission.
///
/// Distinct from an ordinary failure because it might mean tampering rather than
/// breakage, and the UI has to say so rather than showing "something went
/// wrong".
class JoinRequestVerificationException implements Exception {
  const JoinRequestVerificationException(this.message);

  final String message;

  @override
  String toString() => 'JoinRequestVerificationException: $message';
}

/// Getting into, and letting people into, an encrypted channel.
///
/// The server cannot admit anyone — it holds no group keys, so only a current
/// member can produce an Add commit. Admission is therefore a request that
/// members review, and the approval that meets the threshold is what makes that
/// member's client mint the Welcome.
///
/// This is what closes the hole where somebody who joined a guild after a
/// channel was encrypted could neither read it nor send to it, with nobody able
/// to do anything about it.
class MlsJoinRequestService {
  MlsJoinRequestService({
    required this.mls,
    required this.sync,
    required this.api,
    required this.deviceIdService,
  });

  final MlsService mls;
  final MlsSyncService sync;
  final MlsApi api;
  final DeviceIdService deviceIdService;

  Future<List<MlsJoinRequestDto>> list(String channelId) =>
      api.listJoinRequests(channelId);

  Future<void> deny({required String channelId, required String requestId}) =>
      api.denyJoinRequest(channelId: channelId, requestId: requestId);

  Future<void> cancel({required String channelId, required String requestId}) =>
      api.cancelJoinRequest(channelId: channelId, requestId: requestId);

  /// Asks to be let into an encrypted channel.
  ///
  /// Mints a key package specifically for this request rather than pointing at
  /// the pool on the server: reviewers approve exact bytes, and bytes nobody
  /// else can hand out cannot be swapped between approval and add.
  Future<MlsJoinRequestDto> requestAccess(String channelId) async {
    final keyPackage = await _mintRequestKeyPackage();
    final info = await mls.inspectKeyPackage(keyPackage);

    return api.requestAccess(
      channelId: channelId,
      keyPackage: keyPackage,
      deviceId: deviceIdService.deviceId,
      signatureKeyFingerprint: info.signatureKeyFingerprint,
    );
  }

  /// This device's own identity fingerprint, so its owner can read it out to a
  /// reviewer over a call.
  ///
  /// Free to call as often as the UI likes: it is a hash of the signing key this
  /// device already holds. It deliberately does *not* mint a key package to
  /// inspect - that writes key material nothing will ever consume into the
  /// engine's store, permanently, and the store is rewritten in full on every
  /// save. The value is identical either way (pinned by
  /// `a_devices_own_fingerprint_needs_no_key_package` in the Rust tests),
  /// because both hash the same long-lived signature key.
  Future<String?> ownFingerprint() => mls.ownFingerprint();

  Future<String> _mintRequestKeyPackage() async {
    final packages = await mls.generateKeyPackages(1);
    if (packages.isEmpty) {
      throw StateError('Could not generate a key package for the request');
    }
    return packages.first.keyPackage;
  }

  /// Vouches for a request, and admits the device when that completes the
  /// threshold.
  ///
  /// Before adding anything this re-derives the fingerprint, hash and claimed
  /// identity from the bytes the server handed back and checks all three against
  /// what was reviewed. Skipping that would make the whole review ceremonial: a
  /// server that substituted its own key package between approval and add would
  /// have its key silently welcomed into the group.
  ///
  /// Returns whether the device was actually admitted by this call.
  Future<bool> approve({
    required String channelId,
    required MlsJoinRequestDto request,
  }) async {
    final result = await api.approveJoinRequest(
      channelId: channelId,
      requestId: request.id,
    );

    if (!result.thresholdMet) return false;

    final keyPackage = result.keyPackage;
    if (keyPackage == null) {
      throw const JoinRequestVerificationException(
        'The server reported the threshold met but returned no key package.',
      );
    }

    final info = await mls.inspectKeyPackage(keyPackage);

    if (info.keyPackageHash != request.keyPackageHash) {
      throw const JoinRequestVerificationException(
        'The key package does not match the one that was reviewed. '
        'Nothing was added.',
      );
    }
    if (info.signatureKeyFingerprint != request.signatureKeyFingerprint) {
      throw const JoinRequestVerificationException(
        'The identity key does not match the one that was reviewed. '
        'Nothing was added.',
      );
    }
    if (info.identity != request.requesterUserId) {
      throw const JoinRequestVerificationException(
        'The key package claims a different user than the request. '
        'Nothing was added.',
      );
    }

    final admitted = await sync.publish(
      contextId: channelId,
      isChannel: true,
      produce: () async {
        final groupId = mls.activeGroupId(channelId)!;
        final out = await mls.addMembers(
          groupIdB64: groupId,
          keyPackagesB64: [keyPackage],
        );
        return StagedCommit(
          commit: out.commit,
          epoch: out.epoch,
          deviceWelcomes: [
            DeviceWelcomeDto(
              deviceId: request.requesterDeviceId,
              userId: request.requesterUserId,
              welcome: out.welcome!,
            ),
          ],
          fulfilledJoinRequestIds: [request.id],
        );
      },
    );

    if (!admitted) {
      throw StateError(
        'The group moved on while admitting; the request is still open.',
      );
    }

    return true;
  }
}
