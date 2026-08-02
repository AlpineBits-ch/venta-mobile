import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_store.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';

/// The MLS state files are sealed (see `StateFileCipher`), but sealing is only
/// half of §C8. The other half lives in files no Dart test would otherwise ever
/// open - an Android manifest attribute, an XML resource, two entitlements plists
/// and one Swift source - and every one of them fails **silently** when it is
/// wrong: the backup still happens, the keychain read still returns null, the
/// extension still writes a file. There is no runtime signal at all.
///
/// So these are asserted here instead. They are string matches against platform
/// config, which is not elegant, and they are the only automated check that
/// exists for any of it. The last group is the same idea one language further
/// out: a Rust error string that Dart branches on.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  final extractionRules = File(
    'android/app/src/main/res/xml/data_extraction_rules.xml',
  );
  final decryptor = File('ios/NotificationService/MlsNotificationDecryptor.swift');
  final entitlements = [
    File('ios/Runner/Runner.entitlements'),
    File('ios/Runner/Runner-Release.entitlements'),
    File('ios/NotificationService/NotificationService.entitlements'),
  ];

  group('Android backup', () {
    test('the data directory is not uploaded to Auto Backup', () {
      // The default is true. Left alone, mls_state.json and the decrypted
      // message cache leave the device the first time the user backs up.
      expect(manifest.readAsStringSync(), contains('android:allowBackup="false"'));
    });

    test('device-to-device transfer is excluded as well', () {
      // allowBackup="false" does not cover it on Android 12+, which is the
      // easiest way to think this is handled when it is not.
      expect(
        manifest.readAsStringSync(),
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );

      final rules = extractionRules.readAsStringSync();
      for (final section in ['cloud-backup', 'device-transfer']) {
        final body = rules.substring(
          rules.indexOf('<$section>'),
          rules.indexOf('</$section>'),
        );
        for (final domain in ['root', 'file', 'database', 'sharedpref']) {
          expect(
            body,
            contains('<exclude domain="$domain" />'),
            reason: '$section still carries the $domain domain off the device',
          );
        }
        expect(
          body,
          isNot(contains('<include')),
          reason: 'an <include> in $section overrides the excludes above it',
        );
      }
    });
  });

  // Two separate ways for this to be wrong, and both of them look like success:
  // the entitlement missing entirely (`errSecMissingEntitlement`), and the
  // runtime string not being the *expanded* form of the entitlement
  // (`errSecItemNotFound`). Either one is swallowed by
  // `readOrCreateMlsStateKey` into a null key, and sealing silently becomes a
  // no-op on iOS while the Android half keeps working.
  group('iOS keychain sharing', () {
    final accessGroup = SecureStorageService.sharedKeychainGroup;
    final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');

    test('the group is team-prefixed', () {
      // A bare `gg.venta.mobile.shared` is the failure mode: it is what the
      // entitlements file literally says, it looks right next to it, and it
      // matches no access group at runtime.
      final team = RegExp(r'DEVELOPMENT_TEAM = ([A-Z0-9]{10});')
          .firstMatch(pbxproj.readAsStringSync())
          ?.group(1);
      expect(team, isNotNull, reason: 'no DEVELOPMENT_TEAM to check against');
      expect(
        accessGroup,
        startsWith('$team.'),
        reason: r'kSecAttrAccessGroup needs the expanded $(AppIdentifierPrefix)',
      );
    });

    test('all three targets declare the unexpanded form of it', () {
      final team = accessGroup.split('.').first;
      final suffix = accessGroup.substring(team.length + 1);
      for (final file in entitlements) {
        final plist = file.readAsStringSync();
        expect(
          plist,
          contains('<key>keychain-access-groups</key>'),
          reason: '${file.path} cannot reach the MLS state key at all',
        );
        expect(
          plist,
          contains('<string>\$(AppIdentifierPrefix)$suffix</string>'),
          reason: '${file.path} declares a different group than Dart queries',
        );
      }
    });

    test('the shared group is never the default for new items', () {
      // The **first** entry is the default access group for every keychain write
      // that does not name one. Declaring only the shared group therefore moves
      // the MLS signing key, the account master key, the account identity key
      // and the auth tokens into the group the notification extension can read.
      // Silently: existing items stay where they are and reads search every
      // entitled group, so nothing looks broken - only new secrets land wide.
      for (final file in entitlements) {
        final plist = file.readAsStringSync();
        final array = plist.substring(
          plist.indexOf('<key>keychain-access-groups</key>'),
        );
        final first = RegExp(
          r'<string>([^<]*)</string>',
        ).firstMatch(array)!.group(1)!;
        expect(
          first,
          isNot(endsWith('.shared')),
          reason: '${file.path} hands the extension every new secret by default',
        );
      }
    });

    test('the extension looks the key up under the same group', () {
      final swift = decryptor.readAsStringSync();
      expect(
        swift,
        contains('keychainAccessGroup = "$accessGroup"'),
        reason: 'the extension and the app would use different keychain groups',
      );
      expect(swift, contains('kSecAttrAccessGroup: keychainAccessGroup'));
      expect(swift, contains('"venta.mls.statekey.\\(userId)"'));
      // Must match AppleOptions.defaultAccountName; a mismatch here is a
      // keychain miss, which reads as "no key" and unseals nothing loudly.
      expect(swift, contains('"flutter_secure_storage_service"'));
    });

    test('the lookup does not pin an accessibility class', () {
      final swift = decryptor.readAsStringSync();
      // `kSecAttrAccessible` is in every query flutter_secure_storage builds
      // but is *not* part of a generic-password item's primary key. Those two
      // facts together stranded the app's own items when the class changed
      // (see MigratingSecureStore), and `_sharedStorage` is deliberately not
      // wrapped in that migration - so the only thing keeping the extension
      // immune is that it never names an accessibility class at all. Naming
      // one here would reintroduce the bug on the one process that has no way
      // to report it.
      // The colon matters: the symbol is named in a comment explaining exactly
      // this, and only a dictionary key puts it into the query.
      expect(swift, isNot(contains('kSecAttrAccessible:')));
      expect(swift, isNot(contains('kSecAttrAccessible]')));
    });

    test('a key in the wrong group is found and named, not missed', () {
      final swift = decryptor.readAsStringSync();
      // The group carries a hardcoded team prefix, because
      // `$(AppIdentifierPrefix)` in the entitlements is substituted at build
      // time and cannot be read back at runtime. Nothing checks that guess, and
      // getting it wrong is indistinguishable from having no key. So a miss
      // retries without the group - which spans only this extension's own group
      // and `.shared`, never the app's private one - and reports where the item
      // actually was.
      expect(swift, contains('query.removeValue(forKey: kSecAttrAccessGroup)'));
      expect(swift, contains('.stateKeyInAnotherGroup'));
    });
  });

  group('the notification extension is a participant in the sealing', () {
    final swift = decryptor.readAsStringSync();

    test('it hands the engine the state key', () {
      // Without this, initStorage against a sealed mls_state.json fails and
      // every push falls back to the placeholder.
      expect(swift, contains('storageArgs["stateKeyB64"] = stateKey'));
    });

    // Behaviourally verified too: a Foundation-only transcription of both
    // functions was compiled and run under swiftc 6.3.3 and reproduces the Dart
    // pins below exactly. It is not checked in because there is no runner for
    // it, so what CI can hold onto is the source.
    test('it sanitizes user ids the way Dart does, so `..` cannot survive', () {
      // `recipientUserId` comes straight off the push payload, so the server
      // picks it. Swift allowed `.` under a comment claiming it matched Dart -
      // which had already removed it, and pins the removal. `sanitize("..")`
      // returning ".." walks stateDirectory out of mls/ and into another
      // account's state.
      expect(
        swift,
        contains(
          '(character.isLetter || character.isNumber || character == "_" '
          '|| character == "-")',
        ),
      );
      expect(
        swift,
        isNot(contains('character == "."')),
        reason: 'the traversal Dart closed is open again on iOS',
      );
      // The Dart side of the same contract, on the inputs the probe ran.
      expect(MlsStore.sanitize('..'), '__');
      expect(MlsStore.sanitize('a/../b'), 'a____b');
    });

    test('it keys the cache by context and generation, not the bare id', () {
      // `messageId` is chosen by the server. On the id alone, a server that
      // reuses one it has used in another conversation gets this device to
      // render that conversation's plaintext here - and a cache hit decrypts
      // nothing, so no MLS property is violated on the way. Both Dart writers
      // always keyed it properly; the extension did not, which made it reachable
      // on iOS.
      expect(
        swift,
        contains(r'"\(contextId)#\(generation.map(String.init) ?? "?")#\(messageId)"'),
      );
      expect(
        swift,
        isNot(contains('cache[messageId] =')),
        reason: 'the extension is writing the bare-id key again',
      );
    });

    test('a fresh install still gets its first cache file', () {
      // replaceItemAt throws when there is nothing to replace, and the first
      // push to an install that has never decrypted anything is exactly that.
      expect(swift, contains('try FileManager.default.moveItem(at: temporary, to: url)'));
    });

    test('a file that exists but will not read is not treated as empty', () {
      // `try? Data(contentsOf:)` swallows I/O errors and allocation failures as
      // well as absence, and folding those into `[:]` puts the single-entry
      // overwrite straight back. Only absence may mean empty.
      expect(
        swift,
        contains('guard FileManager.default.fileExists(atPath: url.path) else {'),
      );
      expect(swift, contains('guard let data = try? Data(contentsOf: url) else {'));
    });

    test('it opens and seals the host files rather than reading them raw', () {
      expect(swift, contains('"openHostBlob"'));
      expect(swift, contains('"sealHostBlob"'));
      expect(swift, contains('VENTABOX1'));
    });

    test('a file it cannot open is never written', () {
      // The bug this replaces: readAnyMap returned [:] for a sealed cache, the
      // merge produced a single-entry map, and the atomic write replaced the
      // device's entire decrypted history with one plaintext message. The guard
      // is that `read` returns nil - distinct from empty - and that the write
      // path bails on it.
      expect(
        swift,
        contains('guard let existing = read(url, stateKey: stateKey) else {'),
      );
      // And that sealing failing does not degrade to writing plaintext over a
      // sealed file.
      expect(swift, contains('let data = seal(json, stateKey: stateKey)'));
      expect(
        swift,
        isNot(contains('readAnyMap')),
        reason: 'the plaintext-only reader that caused this is still here',
      );
    });
  });

  // `MlsService.init` decides between "leave the state file alone" and "wipe
  // every group on this handset and start fresh" by substring-matching the
  // engine's error text. A code would be sturdier; until there is one, the
  // literals it matches are pinned here. Rewording one of them in Rust would
  // otherwise turn an unavailable keychain into an irreversible wipe, with
  // nothing failing anywhere to say so.
  group('the wipe-or-leave-it decision still recognises the engine', () {
    final rust = File('packages/venta_mls/rust/src/mls.rs').readAsStringSync();

    /// Every `MlsError` literal in the crate that is about the state key.
    final stateKeyErrors = RegExp(r'"(MlsError: [^"]*state key[^"]*)"')
        .allMatches(rust)
        .map((m) => m.group(1)!)
        .toList();

    test('the crate still raises the errors this matches on', () {
      // A floor rather than isNotEmpty, because the selector above and the
      // matcher below key off the same substring: reword a message to drop
      // "state key" and the regex simply stops picking it up, so the loop would
      // pass while the thing it guards got worse. A tripwire, not a spec - if
      // this number has to move, go and check that `looksSealedWithoutKey` still
      // recognises whatever replaced the message, because the other reading of
      // an unmatched error is a wiped handset.
      expect(
        stateKeyErrors.length,
        greaterThanOrEqualTo(6),
        reason: 'mls.rs lost a state-key error the wipe decision depends on',
      );
      for (final message in stateKeyErrors) {
        expect(
          MlsService.looksSealedWithoutKey(Exception(message)),
          isTrue,
          reason: '"$message" would be read as corruption and trigger a wipe',
        );
      }
    });

    test('an actually corrupt state file is still wiped', () {
      // The matcher has to stay narrow, or the fail-closed branch swallows real
      // corruption and the app never recovers on its own.
      expect(
        MlsService.looksSealedWithoutKey(
          Exception('MlsError: expected value at line 1 column 1'),
        ),
        isFalse,
      );
    });
  });
}
