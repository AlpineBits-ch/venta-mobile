import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../diagnostics/secure_storage_fault.dart';

/// Reads and writes keychain items that may still be stored under the
/// **previous** accessibility class.
///
/// ## The bug this exists for
///
/// `kSecAttrAccessible` is part of every query `flutter_secure_storage_darwin`
/// builds (`FlutterSecureStorage.baseQuery`), but it is **not** part of a
/// generic-password item's primary key - that is service + account + access
/// group + synchronizable. Those two facts together are a trap, and this app
/// walked into it:
///
/// * Before the MLS hardening the app used the plugin's default,
///   `KeychainAccessibility.unlocked` (`kSecAttrAccessibleWhenUnlocked`), so
///   every token, device id and server URL on every installed handset is stored
///   under it.
/// * That release set `accessibility: first_unlock_this_device` - correctly, and
///   for good reasons: `whenUnlocked` items are unreadable exactly when the
///   notification-service extension needs them, and `ThisDevice` keeps MLS keys
///   out of an iCloud Keychain sync that would put one device's leaf on another.
///
/// From that build onward every query carried the *new* accessibility, so:
///
/// * **reads silently miss.** `SecItemCopyMatching` does not match the stored
///   item, returns `errSecItemNotFound`, and the plugin maps that to `null` -
///   indistinguishable from "nothing was ever stored". The app concluded it had
///   no session and no device id.
/// * **writes fail with `errSecDuplicateItem` (-25299).** `containsKey` misses
///   for the same reason, so the plugin skips `SecItemUpdate` and calls
///   `SecItemAdd` - against a primary key that very much still exists.
///
/// Which is the whole reported sequence: a blank launch (the unguarded write in
/// `DeviceIdService.init` threw before `runApp`), then, once that was guarded, a
/// fresh ephemeral device id the server had never seen, and a login that the
/// server completed and the client reported as "Something went wrong" when
/// `writeTokens` threw.
///
/// Android is untouched: the Keystore has no accessibility class, which is
/// exactly why every Android test passed throughout.
///
/// ## What this does
///
/// On a miss under the current options, it looks again under the legacy ones and
/// migrates what it finds: delete under legacy, rewrite under current. On a
/// write failure it clears the legacy item and retries once, which covers the
/// duplicate-item case where nothing read first.
///
/// Idempotent, and self-retiring: once an item has been migrated the legacy
/// lookup misses forever after and costs one extra keychain call on a cold read.
class MigratingSecureStore {
  MigratingSecureStore({required this.current, required this.legacy});

  /// Configured with the accessibility this build wants.
  final FlutterSecureStorage current;

  /// Identical, except for the accessibility every pre-hardening build used.
  final FlutterSecureStorage legacy;

  Future<String?> read({required String key}) async {
    final value = await current.read(key: key);
    if (value != null) return value;

    // Nothing under the current class. Either genuinely absent, or stored by a
    // build that predates the change - and those two are indistinguishable from
    // here, which is precisely what made this silent.
    final String? stranded;
    try {
      stranded = await legacy.read(key: key);
    } catch (e, stack) {
      reportSwallowed('KeychainMigration/legacyRead', e, stack, {'key': key});
      return null;
    }
    if (stranded == null) return null;

    debugPrint('keychain: migrating "$key" to the current accessibility class');
    await _migrate(key: key, value: stranded);
    return stranded;
  }

  Future<void> write({required String key, required String value}) async {
    try {
      await current.write(key: key, value: value);
      return;
    } catch (e, stack) {
      // -25299 when a legacy item holds the primary key. Reported either way:
      // if the retry below succeeds this was the migration bug, and if it does
      // not we finally learn the real status.
      reportSwallowed('KeychainMigration/write', e, stack, {'key': key});
    }

    // Clear whatever is squatting on the primary key, then try once more. Not a
    // loop: a second failure is a different fault and belongs to the caller.
    await _deleteLegacy(key);
    await current.write(key: key, value: value);
  }

  /// Deletes under both classes: a delete that leaves the legacy copy behind
  /// would let a "cleared" token reappear on the next read.
  Future<void> delete({required String key}) async {
    await current.delete(key: key);
    await _deleteLegacy(key);
  }

  Future<void> _migrate({required String key, required String value}) async {
    try {
      await legacy.delete(key: key);
      await current.write(key: key, value: value);
    } catch (e, stack) {
      // The value has already been returned to the caller, so this launch
      // works; the migration simply retries next time.
      reportSwallowed('KeychainMigration/migrate', e, stack, {'key': key});
    }
  }

  Future<void> _deleteLegacy(String key) async {
    try {
      await legacy.delete(key: key);
    } catch (e, stack) {
      reportSwallowed('KeychainMigration/legacyDelete', e, stack, {'key': key});
    }
  }
}
