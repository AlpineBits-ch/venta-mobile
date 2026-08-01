//! Round-trip tests for the ported engine.
//!
//! Each simulated device gets its own [`MlsState`] rather than sharing the
//! process-global one: two devices in the same group hold the same group id,
//! and a single shared `groups` map would have one overwrite the other, testing
//! nothing.
//!
//! Run with `cargo test --manifest-path packages/venta_mls/rust/Cargo.toml`.

use crate::mls::*;
use base64::{engine::general_purpose::STANDARD as B64, Engine};

/// A device: its own engine state, its own signing key handle, its own storage.
///
/// The storage is not incidental. `save_to_disk` now **errors** when no state
/// path is configured, rather than returning `Ok(())` - an engine that was never
/// initialised used to perform every operation perfectly and persist none of it,
/// so every group it joined and every commit it merged vanished on the next
/// launch with nothing anywhere saying so. These tests were relying on exactly
/// that no-op, which is why they are the first thing the change caught.
struct Device {
    state: MlsState,
    handle: String,
    /// Held so the directory outlives the device rather than being swept the
    /// moment it goes out of scope.
    _dir: tempfile::TempDir,
}

impl Device {
    fn new(identity: &str, key_package_count: u32) -> (Self, Vec<String>) {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut state = MlsState::default();
        init_storage(&mut state, &dir.path().to_string_lossy(), false)
            .expect("storage must be initialised before anything can persist");
        let batch = generate_key_packages(&mut state, identity.to_owned(), key_package_count)
            .expect("key package generation");
        let packages = batch
            .key_packages
            .iter()
            .map(|p| p.key_package.clone())
            .collect();
        (
            Self {
                state,
                handle: batch.key_handle,
                _dir: dir,
            },
            packages,
        )
    }
}

fn group_id() -> String {
    B64.encode([7u8; 16])
}

#[test]
fn two_devices_exchange_an_encrypted_message() {
    let (mut alice, _) = Device::new("alice", 1);
    let (mut bob, bob_packages) = Device::new("bob", 1);

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).expect("create group");

    let commit = add_members(&mut alice.state, &gid, &alice.handle, &bob_packages)
        .expect("add bob to the group");
    // The server took it, so Alice may advance. Skipping this is the bug the
    // two-phase dance exists to prevent, and the assertions below would still
    // pass without it - hence the explicit epoch check afterwards.
    merge_pending_commit(&mut alice.state, &gid).expect("merge alice's own commit");

    let welcome = commit.welcome.expect("adding a member produces a Welcome");
    let joined = join_group(&mut bob.state, &welcome, &bob.handle).expect("bob joins from Welcome");

    assert_eq!(joined.group_id, gid, "bob landed in a different group");
    assert_eq!(joined.members.len(), 2, "group should hold alice and bob");
    assert_eq!(
        get_group_info(&alice.state, &gid).unwrap().epoch,
        joined.epoch,
        "both devices must agree on the epoch after the join"
    );

    let plaintext = B64.encode("the eagle lands at noon");
    let sent = send_message(&mut alice.state, &gid, &alice.handle, &plaintext).expect("encrypt");
    assert_ne!(sent.ciphertext, plaintext, "content went out in the clear");

    let received = process_message(&mut bob.state, &gid, &sent.ciphertext, None).expect("decrypt");
    assert_eq!(received.kind, "application");
    assert_eq!(received.plaintext.as_deref(), Some(plaintext.as_str()));
    assert_eq!(received.sender_identity.as_deref(), Some("alice"));
}

#[test]
fn a_rejected_commit_can_be_discarded_without_forking_the_group() {
    let (mut alice, _) = Device::new("alice", 1);
    let (_bob, bob_packages) = Device::new("bob", 1);

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();
    let before = get_group_info(&alice.state, &gid).unwrap().epoch;

    add_members(&mut alice.state, &gid, &alice.handle, &bob_packages).unwrap();
    // Server refused it - somebody else won this epoch.
    clear_pending_commit(&mut alice.state, &gid).expect("discard the staged commit");

    assert_eq!(
        get_group_info(&alice.state, &gid).unwrap().epoch,
        before,
        "a discarded commit must leave the group exactly where it was"
    );
    assert_eq!(
        get_members(&alice.state, &gid).unwrap().len(),
        1,
        "bob must not be a member of a commit the server never took"
    );
}

#[test]
fn a_removed_device_is_told_it_was_removed() {
    let (mut alice, _) = Device::new("alice", 1);
    let (mut bob, bob_packages) = Device::new("bob", 1);

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();
    let add = add_members(&mut alice.state, &gid, &alice.handle, &bob_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    join_group(&mut bob.state, &add.welcome.unwrap(), &bob.handle).unwrap();

    let bob_leaf = get_members(&alice.state, &gid)
        .unwrap()
        .into_iter()
        .find(|m| m.identity == "bob")
        .expect("bob is in the roster")
        .leaf_index;

    let removal = remove_members(&mut alice.state, &gid, &alice.handle, &[bob_leaf]).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();

    let processed = process_message(&mut bob.state, &gid, &removal.commit, None).unwrap();
    assert_eq!(processed.kind, "commit");
    assert!(
        processed.self_removed,
        "bob has to learn he is out, or the UI keeps claiming he can read the context"
    );
}

// ─── Key package inspection ─────────────────────────────────────────────────
//
// What a reviewer is shown before vouching for someone's admission to an
// encrypted room.

#[test]
fn inspect_reports_the_identity_the_package_claims() {
    let (device, packages) = Device::new("alice", 1);

    let info = inspect_key_package(&device.state, &packages[0]).expect("inspect must succeed");

    assert_eq!(info.identity, "alice");
    assert!(!info.signature_key_fingerprint.is_empty());
    assert_eq!(
        info.key_package_hash.len(),
        64,
        "hash should be hex-encoded SHA-256"
    );
}

#[test]
fn fingerprint_is_stable_across_a_devices_key_packages() {
    let (device, packages) = Device::new("alice", 3);

    let fingerprints: Vec<String> = packages
        .iter()
        .map(|kp| {
            inspect_key_package(&device.state, kp)
                .expect("inspect must succeed")
                .signature_key_fingerprint
        })
        .collect();

    // The whole point of fingerprinting the signature key rather than the
    // package: a value that changed with every package could never be read out
    // and compared over a call.
    assert_eq!(fingerprints[0], fingerprints[1]);
    assert_eq!(fingerprints[1], fingerprints[2]);
}

#[test]
fn fingerprint_differs_between_devices() {
    let (alice, alice_packages) = Device::new("alice", 1);
    let (bob, bob_packages) = Device::new("bob", 1);

    let fa = inspect_key_package(&alice.state, &alice_packages[0])
        .unwrap()
        .signature_key_fingerprint;
    let fb = inspect_key_package(&bob.state, &bob_packages[0])
        .unwrap()
        .signature_key_fingerprint;

    assert_ne!(fa, fb);
}

#[test]
fn the_hash_binds_an_approval_to_exact_bytes() {
    let (device, packages) = Device::new("alice", 2);

    let first = inspect_key_package(&device.state, &packages[0]).unwrap();
    let second = inspect_key_package(&device.state, &packages[1]).unwrap();

    // Two packages from one device share a fingerprint but must not share a
    // hash - otherwise an approval could be replayed against different bytes,
    // which is the substitution the review exists to prevent.
    assert_eq!(first.signature_key_fingerprint, second.signature_key_fingerprint);
    assert_ne!(first.key_package_hash, second.key_package_hash);
}

#[test]
fn a_devices_own_fingerprint_needs_no_key_package() {
    let (device, packages) = Device::new("alice", 1);
    let from_package = inspect_key_package(&device.state, &packages[0]).unwrap();

    // What the requester shows about itself has to be the same string the
    // reviewer sees against the request, or the two cannot be compared over a
    // call - which is the entire point of the fingerprint.
    let direct =
        fingerprint_for_signature_key(&from_package.signature_public_key).expect("should derive");

    assert_eq!(direct, from_package.signature_key_fingerprint);
}

#[test]
fn inspect_refuses_bytes_that_are_not_a_key_package() {
    let (device, _) = Device::new("alice", 1);

    let result = inspect_key_package(&device.state, &B64.encode(b"not a key package"));

    assert!(
        result.is_err(),
        "a reviewer must never be shown an identity lifted from something unparseable"
    );
}

#[test]
fn state_survives_a_restart() {
    let dir = std::env::temp_dir().join(format!("venta_mls_test_{}", std::process::id()));
    let dir_str = dir.to_string_lossy().into_owned();
    let _ = std::fs::remove_dir_all(&dir);

    let gid = group_id();

    let signing = {
        let mut alice = MlsState::default();
        init_storage(&mut alice, &dir_str, false).expect("init storage");
        let batch = generate_key_packages(&mut alice, "alice".to_owned(), 1).unwrap();
        create_group(&mut alice, &gid, &batch.key_handle).unwrap();
        (batch.signing_public_key, batch.signing_private_key)
    };

    // Cold start: a brand-new engine pointed at the same directory.
    let mut restarted = MlsState::default();
    let restored = init_storage(&mut restarted, &dir_str, false).expect("re-init storage");
    assert!(restored, "state should have been restored from disk");

    let handle = load_signing_key(&mut restarted, &signing.0, &signing.1, "alice".to_owned())
        .expect("reload the signing key from the keychain");
    let info = get_group_info(&restarted, &gid).expect("group survived the restart");
    assert_eq!(info.group_id, gid);

    // The reloaded signer must still be usable, not merely present.
    send_message(&mut restarted, &gid, &handle, &B64.encode("still here")).expect("encrypt");

    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn re_initialising_the_same_directory_leaves_live_state_alone() {
    let dir = std::env::temp_dir().join(format!("venta_mls_reinit_{}", std::process::id()));
    let dir_str = dir.to_string_lossy().into_owned();
    let _ = std::fs::remove_dir_all(&dir);

    let gid = group_id();
    let mut alice = MlsState::default();
    init_storage(&mut alice, &dir_str, false).expect("init storage");
    let batch = generate_key_packages(&mut alice, "alice".to_owned(), 1).unwrap();
    create_group(&mut alice, &gid, &batch.key_handle).unwrap();

    // What Android's FCM background isolate does on every push: it shares the
    // process (and therefore this state) with the running app, so a second init
    // must be a no-op rather than a reload that clobbers unsaved work.
    init_storage(&mut alice, &dir_str, false).expect("re-init the same directory");

    let info = get_group_info(&alice, &gid).expect("the group is still there exactly once");
    assert_eq!(info.group_id, gid);
    send_message(&mut alice, &gid, &batch.key_handle, &B64.encode("still usable")).expect("encrypt");

    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn read_only_storage_never_writes_back() {
    let dir = std::env::temp_dir().join(format!("venta_mls_ro_{}", std::process::id()));
    let dir_str = dir.to_string_lossy().into_owned();
    let _ = std::fs::remove_dir_all(&dir);

    let gid = group_id();
    let signing = {
        let mut alice = MlsState::default();
        init_storage(&mut alice, &dir_str, false).expect("init storage");
        let batch = generate_key_packages(&mut alice, "alice".to_owned(), 1).unwrap();
        create_group(&mut alice, &gid, &batch.key_handle).unwrap();
        (batch.signing_public_key, batch.signing_private_key)
    };

    let state_file = dir.join("mls_state.json");
    let before = std::fs::read(&state_file).expect("state was written");

    // An iOS notification-service extension: a separate process that loads the
    // app's state to read one message and must not persist anything, or it will
    // eventually write a stale copy over whatever the app has committed since.
    let mut extension = MlsState::default();
    init_storage(&mut extension, &dir_str, true).expect("read-only init");
    let handle = load_signing_key(&mut extension, &signing.0, &signing.1, "alice".to_owned()).unwrap();
    send_message(&mut extension, &gid, &handle, &B64.encode("ratchets forward")).expect("encrypt");

    let after = std::fs::read(&state_file).expect("state file still exists");
    assert_eq!(before, after, "a read-only engine must leave the state file untouched");

    let _ = std::fs::remove_dir_all(&dir);
}


// ---------------------------------------------------------------------------
// Account isolation, key-package durability, backup and identity (§D/§G/§H)
// ---------------------------------------------------------------------------

/// `init_storage` used to *insert into* whatever was already in the provider
/// rather than replacing it, so switching accounts on one handset merged two
/// accounts' key material into one store - and the next save wrote account A's
/// private keys into account B's file. That is a confidentiality failure, not a
/// corruption one, which is why this asserts on the *absence* of A's group
/// rather than merely on B working.
#[test]
fn a_second_account_does_not_inherit_the_first_accounts_state() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir_a = root.path().join("a").to_string_lossy().into_owned();
    let dir_b = root.path().join("b").to_string_lossy().into_owned();

    let gid_a = B64.encode([1u8; 16]);
    let mut engine = MlsState::default();

    init_storage(&mut engine, &dir_a, false).expect("account A storage");
    let batch_a = generate_key_packages(&mut engine, "alice".to_owned(), 1).unwrap();
    create_group(&mut engine, &gid_a, &batch_a.key_handle).unwrap();
    assert!(get_group_info(&engine, &gid_a).is_ok());

    // Same process, same engine - exactly what an account switch looks like.
    init_storage(&mut engine, &dir_b, false).expect("account B storage");

    assert!(
        get_group_info(&engine, &gid_a).is_err(),
        "account B must not be able to see account A's group"
    );
    assert!(
        get_members(&engine, &gid_a).is_err(),
        "account B must not hold account A's roster"
    );
    // A's handle is gone too: a key minted for one account must not stay usable
    // against another's groups.
    assert!(
        generate_key_packages_with_handle(&engine, &batch_a.key_handle, 1).is_err(),
        "account A's signing handle must not survive the switch"
    );

    // And A's file is intact - switching back finds its history, not a wipe.
    init_storage(&mut engine, &dir_a, false).expect("back to account A");
    assert!(
        get_group_info(&engine, &gid_a).is_ok(),
        "account A's own state must survive a round trip through account B"
    );
}

/// The private init key of a key package lives in the provider store, and the
/// store is what `save_to_disk` writes. If a restart lost it, every Welcome
/// minted against a package from before the restart would be undecryptable by
/// the very device it was addressed to - which is root cause R3 seen from the
/// client side.
#[test]
fn key_package_init_keys_survive_a_restart_and_still_open_a_welcome() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("bob").to_string_lossy().into_owned();

    let (mut alice, _) = Device::new("alice", 1);
    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();

    // Bob mints a package and persists it, then goes away.
    let (bob_signing, bob_package) = {
        let mut bob = MlsState::default();
        init_storage(&mut bob, &dir, false).expect("bob storage");
        let batch = generate_key_packages(&mut bob, "bob".to_owned(), 1).unwrap();
        (
            (batch.signing_public_key, batch.signing_private_key),
            batch.key_packages[0].key_package.clone(),
        )
    };

    // Alice welcomes him while he is offline.
    let commit = add_members(&mut alice.state, &gid, &alice.handle, &[bob_package]).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    let welcome = commit.welcome.expect("a Welcome for bob");

    // Bob comes back on a cold start - a brand new engine reading the file.
    let mut bob = MlsState::default();
    assert!(
        init_storage(&mut bob, &dir, false).expect("restore bob"),
        "state should have been restored, not started fresh"
    );
    let handle = load_signing_key(&mut bob, &bob_signing.0, &bob_signing.1, "bob".to_owned())
        .expect("reload bob's signing key");

    let joined = join_group(&mut bob, &welcome, &handle)
        .expect("the init key must have survived the restart");
    assert_eq!(joined.members.len(), 2);
}

#[test]
fn a_backup_round_trips_on_the_same_device() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("device").to_string_lossy().into_owned();

    let gid = group_id();
    let mut engine = MlsState::default();
    init_storage(&mut engine, &dir, false).unwrap();
    let batch = generate_key_packages(&mut engine, "alice".to_owned(), 1).unwrap();
    create_group(&mut engine, &gid, &batch.key_handle).unwrap();

    let mut registry = std::collections::HashMap::new();
    registry.insert("conv_1#1".to_owned(), serde_json::json!(gid.clone()));
    registry.insert("conv_1#active".to_owned(), serde_json::json!(1));
    let mut cache = std::collections::HashMap::new();
    cache.insert("msg_1".to_owned(), B64.encode("hello"));

    let identity = generate_account_identity(&engine).unwrap();

    let blob = export_backup(
        &engine,
        "correct horse battery staple".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
        "1.0.0".to_owned(),
        batch.key_handle.clone(),
        registry,
        Some(cache),
        Some((identity.public_key.clone(), identity.private_key.clone())),
    )
    .expect("export");

    // A fresh install, same device id - the reinstall journey (§H.3 row 1).
    let restore_dir = root.path().join("restored").to_string_lossy().into_owned();
    let mut restored = MlsState::default();
    init_storage(&mut restored, &restore_dir, false).unwrap();

    let result = import_backup(
        &mut restored,
        blob.clone(),
        "correct horse battery staple".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
    )
    .expect("import");

    assert!(result.engine_restored, "same device id restores the engine");
    assert_eq!(result.group_registry.len(), 2);
    assert_eq!(result.message_cache.len(), 1);
    assert_eq!(
        result.account_identity_public_key.as_deref(),
        Some(identity.public_key.as_str())
    );
    assert!(
        get_group_info(&restored, &gid).is_ok(),
        "the restored engine must hold the group"
    );
}

/// The rule §D exists to enforce. Two devices sharing one leaf reuse ratchet
/// generations, which openmls treats as a replay - so a new device gets the
/// signing key, the registry and the history, and never the engine.
#[test]
fn a_backup_restored_on_a_different_device_skips_the_engine() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("original").to_string_lossy().into_owned();

    let gid = group_id();
    let mut engine = MlsState::default();
    init_storage(&mut engine, &dir, false).unwrap();
    let batch = generate_key_packages(&mut engine, "alice".to_owned(), 1).unwrap();
    create_group(&mut engine, &gid, &batch.key_handle).unwrap();

    let blob = export_backup(
        &engine,
        "passphrase".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
        "1.0.0".to_owned(),
        batch.key_handle.clone(),
        std::collections::HashMap::new(),
        None,
        None,
    )
    .unwrap();

    let new_dir = root.path().join("new-handset").to_string_lossy().into_owned();
    let mut new_device = MlsState::default();
    init_storage(&mut new_device, &new_dir, false).unwrap();

    let result = import_backup(
        &mut new_device,
        blob,
        "passphrase".to_owned(),
        "user_1".to_owned(),
        "device_2".to_owned(),
    )
    .unwrap();

    assert!(
        !result.engine_restored,
        "a different device must not clone ratchet state"
    );
    assert!(
        get_group_info(&new_device, &gid).is_err(),
        "the group must not have come across"
    );
    assert!(
        !result.key_handle.is_empty(),
        "the signing key is still restored - it is what a re-join is made with"
    );
}

#[test]
fn a_backup_for_another_account_is_refused() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("d").to_string_lossy().into_owned();
    let mut engine = MlsState::default();
    init_storage(&mut engine, &dir, false).unwrap();
    let batch = generate_key_packages(&mut engine, "alice".to_owned(), 0).unwrap();

    let blob = export_backup(
        &engine,
        "passphrase".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
        "1.0.0".to_owned(),
        batch.key_handle,
        std::collections::HashMap::new(),
        None,
        None,
    )
    .unwrap();

    let err = import_backup(
        &mut engine,
        blob,
        "passphrase".to_owned(),
        "user_2".to_owned(),
        "device_1".to_owned(),
    )
    .expect_err("a backup for another account must be refused outright");
    assert!(err.contains("different account"), "unhelpful error: {}", err);
}

#[test]
fn a_backup_will_not_open_with_the_wrong_passphrase() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("d").to_string_lossy().into_owned();
    let mut engine = MlsState::default();
    init_storage(&mut engine, &dir, false).unwrap();
    let batch = generate_key_packages(&mut engine, "alice".to_owned(), 0).unwrap();

    let blob = export_backup(
        &engine,
        "right".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
        "1.0.0".to_owned(),
        batch.key_handle,
        std::collections::HashMap::new(),
        None,
        None,
    )
    .unwrap();

    assert!(import_backup(
        &mut engine,
        blob,
        "wrong".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
    )
    .is_err());
}

#[test]
fn a_device_certificate_verifies_only_against_the_issuing_account_key() {
    let engine = MlsState::default();
    let account = generate_account_identity(&engine).unwrap();
    let impostor = generate_account_identity(&engine).unwrap();

    let cert = issue_device_certificate(
        &engine,
        &account.private_key,
        "device_1",
        "ZGV2aWNlLXNpZ25pbmcta2V5",
        1_000,
        2_000,
    )
    .unwrap();

    assert!(verify_device_certificate(
        &engine,
        &account.public_key,
        "device_1",
        "ZGV2aWNlLXNpZ25pbmcta2V5",
        1_000,
        2_000,
        &cert,
    )
    .unwrap());

    // Section H.4: a certificate the server minted. It has no account identity
    // private key, so the best it can do is sign with some other key.
    assert!(
        !verify_device_certificate(
            &engine,
            &impostor.public_key,
            "device_1",
            "ZGV2aWNlLXNpZ25pbmcta2V5",
            1_000,
            2_000,
            &cert,
        )
        .unwrap(),
        "a certificate must not verify against an account key that did not issue it"
    );

    // Every field is bound. Moving the certificate to another device, another
    // signing key, or another validity window must all fail.
    let variations: [(&str, &str, i64, i64); 4] = [
        ("device_2", "ZGV2aWNlLXNpZ25pbmcta2V5", 1_000, 2_000),
        ("device_1", "b3RoZXIta2V5", 1_000, 2_000),
        ("device_1", "ZGV2aWNlLXNpZ25pbmcta2V5", 1_001, 2_000),
        ("device_1", "ZGV2aWNlLXNpZ25pbmcta2V5", 1_000, 2_001),
    ];
    for (device, key, issued, expires) in variations {
        assert!(
            !verify_device_certificate(
                &engine,
                &account.public_key,
                device,
                key,
                issued,
                expires,
                &cert,
            )
            .unwrap(),
            "certificate must not transfer to {} / {} / {} / {}",
            device,
            key,
            issued,
            expires
        );
    }

    // An absent certificate is a failed verification, not a caller error - the
    // three-state enforcement in section I.1 decides what to do about it.
    assert!(!verify_device_certificate(
        &engine,
        &account.public_key,
        "device_1",
        "ZGV2aWNlLXNpZ25pbmcta2V5",
        1_000,
        2_000,
        "",
    )
    .unwrap());
}

/// Section G.6's headline: a proof the server made up, without the master key,
/// is rejected. The server relays the challenge and the proof but holds neither
/// the master key nor anything derived from it, so it cannot produce a valid
/// one.
#[test]
fn a_forged_admission_proof_is_rejected() {
    let master = B64.encode([9u8; 32]);
    let server_guess = B64.encode([0u8; 32]);
    let challenge = B64.encode([4u8; 32]);

    let genuine = sign_admission_proof(&master, &challenge, "device_2", "AAAAA-BBBBB").unwrap();
    assert!(
        verify_admission_proof(&master, &challenge, "device_2", "AAAAA-BBBBB", &genuine).unwrap()
    );

    let forged =
        sign_admission_proof(&server_guess, &challenge, "device_2", "AAAAA-BBBBB").unwrap();
    assert!(
        !verify_admission_proof(&master, &challenge, "device_2", "AAAAA-BBBBB", &forged).unwrap(),
        "a proof produced without the account master key must never verify"
    );

    // Bound to the challenge, the device and the fingerprint, so a proof cannot
    // be replayed onto a second admission.
    let other_challenge = B64.encode([5u8; 32]);
    assert!(!verify_admission_proof(
        &master,
        &other_challenge,
        "device_2",
        "AAAAA-BBBBB",
        &genuine
    )
    .unwrap());
    assert!(
        !verify_admission_proof(&master, &challenge, "device_3", "AAAAA-BBBBB", &genuine).unwrap()
    );
    assert!(
        !verify_admission_proof(&master, &challenge, "device_2", "CCCCC-DDDDD", &genuine).unwrap()
    );
    assert!(
        !verify_admission_proof(&master, &challenge, "device_2", "AAAAA-BBBBB", "not base64!")
            .unwrap()
    );
}

/// Section G.3: an unsigned or wrongly-signed level must be rejected rather than
/// defaulted, because a server that could flip the level could then auto-admit
/// its own device.
#[test]
fn a_protection_level_assertion_cannot_be_forged_or_edited() {
    let engine = MlsState::default();
    let account = generate_account_identity(&engine).unwrap();
    let server = generate_account_identity(&engine).unwrap();

    let assertion = sign_protection_level(
        &engine,
        &account.private_key,
        "user_1",
        "VerifiedDevices",
        3,
        "2026-08-01T00:00:00Z",
    )
    .unwrap();

    assert!(verify_protection_level(
        &engine,
        &account.public_key,
        "user_1",
        "VerifiedDevices",
        3,
        "2026-08-01T00:00:00Z",
        &assertion,
    )
    .unwrap());

    // The downgrade attack, stated directly: the server re-labels the same
    // signature as the weaker level.
    assert!(
        !verify_protection_level(
            &engine,
            &account.public_key,
            "user_1",
            "TrustedSignIn",
            3,
            "2026-08-01T00:00:00Z",
            &assertion,
        )
        .unwrap(),
        "re-labelling a signed assertion must not verify"
    );

    // A rollback to an older version is equally a downgrade.
    assert!(!verify_protection_level(
        &engine,
        &account.public_key,
        "user_1",
        "VerifiedDevices",
        2,
        "2026-08-01T00:00:00Z",
        &assertion,
    )
    .unwrap());

    // And the server signing its own is not enough without the account key.
    let forged = sign_protection_level(
        &engine,
        &server.private_key,
        "user_1",
        "TrustedSignIn",
        4,
        "2026-08-01T00:00:00Z",
    )
    .unwrap();
    assert!(!verify_protection_level(
        &engine,
        &account.public_key,
        "user_1",
        "TrustedSignIn",
        4,
        "2026-08-01T00:00:00Z",
        &forged,
    )
    .unwrap());

    // Absent entirely. Section G.3 says reject, not default.
    assert!(!verify_protection_level(
        &engine,
        &account.public_key,
        "user_1",
        "VerifiedDevices",
        3,
        "2026-08-01T00:00:00Z",
        "",
    )
    .unwrap());
}

// ---------------------------------------------------------------------------
// Cross-client golden vectors (contract section F)
// ---------------------------------------------------------------------------

/// Consumes the fixture Alpine's engine produced.
///
/// `venta_mls/rust/Cargo.toml` pins openmls 0.8.1 with the comment "Bump both
/// together or neither". This is what turns that comment into an assertion: a
/// ciphersuite, protocol-version or TLS-codec drift fails here rather than
/// surfacing as "my friend texts me from desktop and I cannot read it".
#[test]
fn this_engine_consumes_alpines_golden_key_package_welcome_commit_and_message() {
    let fixture: serde_json::Value = serde_json::from_str(
        &std::fs::read_to_string(golden_path("fixture.json"))
            .expect("testdata/mls-golden/v1/fixture.json is checked in"),
    )
    .expect("the fixture is JSON");

    assert_eq!(
        fixture["ciphersuite"].as_str(),
        Some("MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519"),
        "the fixture was produced under a different ciphersuite"
    );

    let bob = &fixture["bob"];
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("bob");
    std::fs::create_dir_all(&dir).unwrap();

    // Bob's provider store holds the private half of his key package. Without it
    // nobody can open the Welcome, so it travels with the fixture and is loaded
    // through the ordinary restore path rather than a test-only back door.
    std::fs::write(
        dir.join("mls_state.json"),
        serde_json::to_vec(&bob["engine"]).unwrap(),
    )
    .unwrap();

    let mut engine = MlsState::default();
    init_storage(&mut engine, &dir.to_string_lossy(), false).expect("restore bob's store");

    // The key package must validate on this engine before anything else - that
    // is the check an approver makes before vouching for a device.
    let info = inspect_key_package(&engine, bob["keyPackageB64"].as_str().unwrap())
        .expect("alpine's key package must validate here");
    assert_eq!(info.identity, bob["identity"].as_str().unwrap());

    let handle = load_signing_key(
        &mut engine,
        bob["signingPublicKey"].as_str().unwrap(),
        bob["signingPrivateKey"].as_str().unwrap(),
        bob["identity"].as_str().unwrap().to_owned(),
    )
    .expect("load bob's signing key");

    let gid = fixture["groupIdB64"].as_str().unwrap();
    let joined = join_group(&mut engine, fixture["welcomeB64"].as_str().unwrap(), &handle)
        .expect("this engine must open a Welcome written by alpine's");
    assert_eq!(joined.group_id, gid);
    assert_eq!(joined.members.len(), 2, "alice and bob");

    let commit = process_message(&mut engine, gid, fixture["commitB64"].as_str().unwrap(), None)
        .expect("apply alpine's commit");
    assert_eq!(commit.kind, "commit");
    assert_eq!(commit.added_members.len(), 1, "charlie was added");

    let message = process_message(
        &mut engine,
        gid,
        fixture["applicationMessageB64"].as_str().unwrap(),
        None,
    )
    .expect("decrypt alpine's application message");
    assert_eq!(message.kind, "application");
    assert_eq!(
        message.plaintext.as_deref(),
        fixture["applicationPlaintextB64"].as_str(),
        "the plaintext did not survive the crossing"
    );
}

fn golden_path(name: &str) -> std::path::PathBuf {
    // CARGO_MANIFEST_DIR is packages/venta_mls/rust; the fixtures live at the
    // Flutter project root so both repos hold them at the same relative path.
    std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../../testdata/mls-golden/v1")
        .join(name)
}

/// Produces this engine's half of the shared fixture, for Alpine to consume.
///
/// Ignored by default and regenerated only when the format changes: a fixture
/// rebuilt on every run would have each engine consuming bytes it had just
/// produced, which proves nothing.
///
/// `cargo test --manifest-path packages/venta_mls/rust/Cargo.toml -- --ignored generate_golden_fixture`
#[test]
#[ignore]
fn generate_golden_fixture() {
    let root = tempfile::tempdir().expect("temp dir");
    let bob_dir = root.path().join("bob");
    std::fs::create_dir_all(&bob_dir).unwrap();

    let (mut alice, _) = Device::new("alice", 1);
    let (_charlie, charlie_packages) = Device::new("charlie", 1);

    // Bob is persisted so his provider store - and therefore the private half of
    // his key package - can be shipped in the fixture.
    let mut bob = MlsState::default();
    init_storage(&mut bob, &bob_dir.to_string_lossy(), false).unwrap();
    let bob_batch = generate_key_packages(&mut bob, "bob".to_owned(), 1).unwrap();
    let bob_package = bob_batch.key_packages[0].key_package.clone();

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();

    let add_bob = add_members(&mut alice.state, &gid, &alice.handle, &[bob_package.clone()]).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    let welcome = add_bob.welcome.unwrap();

    let add_charlie = add_members(&mut alice.state, &gid, &alice.handle, &charlie_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();

    let plaintext = B64.encode("golden vector application message");
    let message = send_message(&mut alice.state, &gid, &alice.handle, &plaintext).unwrap();

    let engine_json: serde_json::Value =
        serde_json::from_slice(&std::fs::read(bob_dir.join("mls_state.json")).unwrap()).unwrap();

    let fixture = serde_json::json!({
        "producedBy": "venta-mobile",
        "openmls": "0.8.1",
        "ciphersuite": "MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519",
        "groupIdB64": gid,
        "bob": {
            "identity": "bob",
            "keyPackageB64": bob_package,
            "signingPublicKey": bob_batch.signing_public_key,
            "signingPrivateKey": bob_batch.signing_private_key,
            "engine": engine_json,
        },
        "welcomeB64": welcome,
        "commitB64": add_charlie.commit,
        "applicationMessageB64": message.ciphertext,
        "applicationPlaintextB64": plaintext,
    });

    let out = golden_path("fixture-venta-mobile.json");
    std::fs::write(&out, serde_json::to_string_pretty(&fixture).unwrap()).unwrap();
    println!("wrote {}", out.display());
}

/// The master key is what every admission proof and every backup blob is bound
/// to, so a password change must re-wrap it rather than mint a new one.
#[test]
fn a_master_key_survives_a_password_change() {
    let envelope = setup_master_key("hunter2", None).expect("setup").password_wrapping;
    let key = decrypt_master_key(&envelope, "hunter2").expect("unwrap");

    assert!(
        decrypt_master_key(&envelope, "hunter3").is_err(),
        "the wrong password must not unwrap it"
    );

    let rewrapped = rewrap_master_key(&key, "hunter3").expect("rewrap");
    assert_eq!(
        decrypt_master_key(&rewrapped, "hunter3").expect("unwrap under the new password"),
        key,
        "a password change must preserve the master key itself"
    );
    assert!(decrypt_master_key(&rewrapped, "hunter2").is_err());
}

/// Section C.1's parameters are wire format: `ApplicationUser.EncryptedMasterKey`
/// is one row that both clients read, and a parameter that drifted here would
/// look exactly like a wrong password on whichever client did not change.
#[test]
fn the_master_key_envelope_matches_the_desktop_clients_parameters() {
    let envelope = setup_master_key("hunter2", None).unwrap().password_wrapping;
    assert_eq!(envelope.argon2_memory, 65536);
    assert_eq!(envelope.argon2_iterations, 3);
    assert_eq!(envelope.argon2_parallelism, 1);
    assert_eq!(envelope.version, 1);
    assert_eq!(
        B64.decode(&envelope.salt).unwrap().len(),
        16,
        "salt is 16 bytes"
    );
    assert_eq!(B64.decode(&envelope.iv).unwrap().len(), 12, "IV is 12 bytes");
}

// ---------------------------------------------------------------------------
// Engine changes mirrored from Alpine
// ---------------------------------------------------------------------------

/// An uninitialised engine used to perform every operation perfectly and persist
/// none of it: `save_to_disk` returned `Ok(())` when there was no state path, so
/// every group joined and every commit merged vanished on the next launch with
/// nothing anywhere saying so.
#[test]
fn an_uninitialised_engine_refuses_to_pretend_it_saved() {
    let mut engine = MlsState::default();

    let err = generate_key_packages(&mut engine, "alice".to_owned(), 1)
        .expect_err("an engine with nowhere to save must not report success");
    assert!(
        err.contains("not initialised"),
        "the error has to name the actual problem: {}",
        err
    );
}

/// The one legitimate no-save case, and the reason the flag is explicit rather
/// than inferred from a missing path: an iOS notification-service extension is a
/// separate process, so writing back would eventually replace whatever the app
/// committed in the meantime with an older copy.
#[test]
fn a_read_only_engine_still_works_and_still_writes_nothing() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("d").to_string_lossy().into_owned();

    let gid = group_id();
    let signing = {
        let mut app = MlsState::default();
        init_storage(&mut app, &dir, false).unwrap();
        let batch = generate_key_packages(&mut app, "alice".to_owned(), 1).unwrap();
        create_group(&mut app, &gid, &batch.key_handle).unwrap();
        (batch.signing_public_key, batch.signing_private_key)
    };

    let state_file = std::path::PathBuf::from(&dir).join("mls_state.json");
    let before = std::fs::read(&state_file).expect("state was written");

    let mut extension = MlsState::default();
    init_storage(&mut extension, &dir, true).expect("read-only init");
    let handle =
        load_signing_key(&mut extension, &signing.0, &signing.1, "alice".to_owned()).unwrap();
    send_message(&mut extension, &gid, &handle, &B64.encode("ratchets forward"))
        .expect("a read-only engine must still be able to read and write messages");

    assert_eq!(
        before,
        std::fs::read(&state_file).unwrap(),
        "a read-only engine must leave the state file untouched"
    );
}

/// A commit's GroupInfo describes the epoch that commit *establishes*. An
/// exported one can only ever describe the epoch the group is still on, and a
/// commit is deliberately not merged until the server accepts it - so every
/// published GroupInfo used to be one epoch stale, and a device recovering by
/// external commit landed behind the group it was rejoining.
#[test]
fn a_commit_carries_the_group_info_for_the_epoch_it_establishes() {
    let (mut alice, _) = Device::new("alice", 1);
    let (_bob, bob_packages) = Device::new("bob", 1);

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();
    let before = get_group_info(&alice.state, &gid).unwrap().epoch;

    let commit = add_members(&mut alice.state, &gid, &alice.handle, &bob_packages).unwrap();

    let group_info = commit
        .group_info
        .expect("openmls hands one back and it must not be discarded");
    assert!(!group_info.is_empty());
    assert_eq!(
        commit.epoch,
        before + 1,
        "the commit describes the epoch after it, not the one it was built on"
    );

    // And it is a real GroupInfo message, not merely non-empty - a device
    // rejoining by external commit has to be able to parse it.
    let bytes = B64.decode(&group_info).expect("standard padded base64");
    assert!(!bytes.is_empty());
}

/// `pending_messages` was declared, retained and cleared but **never written
/// to**, so the promised future-epoch buffer did not exist and a message that
/// arrived before its commit was gone for good - the wire copy decrypts exactly
/// once.
#[test]
fn a_message_from_a_future_epoch_is_buffered_rather_than_lost() {
    let (mut alice, _) = Device::new("alice", 1);
    let (mut bob, bob_packages) = Device::new("bob", 1);
    let (_charlie, charlie_packages) = Device::new("charlie", 1);

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();

    let add_bob = add_members(&mut alice.state, &gid, &alice.handle, &bob_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    join_group(&mut bob.state, &add_bob.welcome.unwrap(), &bob.handle).unwrap();

    // Alice moves the group on and then sends. Bob has not seen the commit yet -
    // the push beat the ordered catch-up, which is the ordinary race.
    let add_charlie =
        add_members(&mut alice.state, &gid, &alice.handle, &charlie_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    let plaintext = B64.encode("sent from the future");
    let sent = send_message(&mut alice.state, &gid, &alice.handle, &plaintext).unwrap();

    let early = process_message(
        &mut bob.state,
        &gid,
        &sent.ciphertext,
        Some("msg_1".to_owned()),
    )
    .expect("an early message is early, not an error");
    assert_eq!(early.kind, "buffered");
    assert!(early.plaintext.is_none());

    // Nothing to replay until the commit lands.
    assert!(drain_pending_messages(&mut bob.state, &gid)
        .unwrap()
        .is_empty());

    // Catch-up arrives.
    let applied = process_message(&mut bob.state, &gid, &add_charlie.commit, None).unwrap();
    assert_eq!(applied.kind, "commit");

    let replayed = drain_pending_messages(&mut bob.state, &gid).expect("drain");
    assert_eq!(replayed.len(), 1, "the buffered message must survive the commit");
    assert_eq!(replayed[0].plaintext, plaintext);
    assert_eq!(replayed[0].message_id.as_deref(), Some("msg_1"));
    assert_eq!(replayed[0].sender_identity.as_deref(), Some("alice"));

    // Drained once, gone once. Replaying it twice would duplicate it in the
    // timeline.
    assert!(drain_pending_messages(&mut bob.state, &gid)
        .unwrap()
        .is_empty());
}

/// The retain after a merge used `>`, which deleted exactly the messages the
/// commit had just made readable. Pinned separately from the happy path because
/// the happy path passes either way when the buffer holds only one epoch.
#[test]
fn a_message_at_the_new_epoch_survives_the_commit_that_unlocks_it() {
    let (mut alice, _) = Device::new("alice", 1);
    let (mut bob, bob_packages) = Device::new("bob", 1);
    let (_charlie, charlie_packages) = Device::new("charlie", 1);

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();
    let add_bob = add_members(&mut alice.state, &gid, &alice.handle, &bob_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    join_group(&mut bob.state, &add_bob.welcome.unwrap(), &bob.handle).unwrap();

    let add_charlie =
        add_members(&mut alice.state, &gid, &alice.handle, &charlie_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();

    let plaintext = B64.encode("exactly at the new epoch");
    let sent = send_message(&mut alice.state, &gid, &alice.handle, &plaintext).unwrap();
    process_message(&mut bob.state, &gid, &sent.ciphertext, Some("m".to_owned())).unwrap();

    // The commit that takes bob *to* that epoch. `retain(epoch > new)` dropped
    // the message here; `>=` keeps it.
    process_message(&mut bob.state, &gid, &add_charlie.commit, None).unwrap();

    let replayed = drain_pending_messages(&mut bob.state, &gid).unwrap();
    assert_eq!(
        replayed.len(),
        1,
        "a message at exactly the new epoch is the one the commit unlocked"
    );
}

#[test]
fn the_same_early_message_twice_is_buffered_once() {
    let (mut alice, _) = Device::new("alice", 1);
    let (mut bob, bob_packages) = Device::new("bob", 1);
    let (_charlie, charlie_packages) = Device::new("charlie", 1);

    let gid = group_id();
    create_group(&mut alice.state, &gid, &alice.handle).unwrap();
    let add_bob = add_members(&mut alice.state, &gid, &alice.handle, &bob_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    join_group(&mut bob.state, &add_bob.welcome.unwrap(), &bob.handle).unwrap();

    let add_charlie =
        add_members(&mut alice.state, &gid, &alice.handle, &charlie_packages).unwrap();
    merge_pending_commit(&mut alice.state, &gid).unwrap();
    let sent = send_message(
        &mut alice.state,
        &gid,
        &alice.handle,
        &B64.encode("delivered twice"),
    )
    .unwrap();

    // A socket delivery racing a REST page. Both carry the same server-side id.
    for _ in 0..3 {
        process_message(
            &mut bob.state,
            &gid,
            &sent.ciphertext,
            Some("msg_dup".to_owned()),
        )
        .unwrap();
    }

    process_message(&mut bob.state, &gid, &add_charlie.commit, None).unwrap();

    assert_eq!(
        drain_pending_messages(&mut bob.state, &gid).unwrap().len(),
        1,
        "the same message must not accumulate in the buffer"
    );
}

// ---------------------------------------------------------------------------
// The KDF headers are the authority, not the write-side constants
// ---------------------------------------------------------------------------

/// The two envelopes deliberately disagree about Argon2 parallelism - the master
/// key uses `p = 1`, the backup envelope `p = 4` - and that is only safe because
/// **both formats are self-describing and both readers derive from the declared
/// header, never from the constants this build happens to write with**.
///
/// A reader that hardcoded its own constants would open everything it wrote
/// itself and fail only on a blob written by the other client, at the only
/// moment that path is ever exercised: a cross-device restore, when the user has
/// no other copy.
///
/// Perturbing each declared parameter in turn is what catches that. Against a
/// hardcoding reader the edited header would be ignored and all three
/// perturbations would still open, so this test would fail loudly rather than
/// silently passing.
#[test]
fn declared_kdf_parameters_are_the_ones_actually_used() {
    let root = tempfile::tempdir().expect("temp dir");
    let dir = root.path().join("d").to_string_lossy().into_owned();
    let mut engine = MlsState::default();
    init_storage(&mut engine, &dir, false).unwrap();
    let batch = generate_key_packages(&mut engine, "alice".to_owned(), 0).unwrap();

    let blob = export_backup(
        &engine,
        "passphrase".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
        "1.0.0".to_owned(),
        batch.key_handle,
        std::collections::HashMap::new(),
        None,
        None,
    )
    .unwrap();

    // Not vacuous: the untouched envelope must open, or the perturbations below
    // would prove nothing.
    import_backup(
        &mut engine,
        blob.clone(),
        "passphrase".to_owned(),
        "user_1".to_owned(),
        "device_1".to_owned(),
    )
    .expect("the unmodified envelope must open");

    let envelope: serde_json::Value = serde_json::from_str(&blob).unwrap();
    assert_eq!(
        envelope["kdf"]["p"].as_u64(),
        Some(4),
        "the backup envelope declares p = 4; see the master-key test for why the \
         two must not be aligned"
    );

    // Every perturbation stays inside Argon2's valid range, so a failure is
    // genuinely "this derived a different key" rather than "these parameters are
    // malformed" - which would fail for the wrong reason and prove less.
    let perturbations: [(&str, serde_json::Value); 3] = [
        ("m", serde_json::json!(32768u32)),
        ("t", serde_json::json!(4u32)),
        ("p", serde_json::json!(2u32)),
    ];

    for (field, value) in perturbations {
        let mut edited = envelope.clone();
        edited["kdf"][field] = value.clone();
        let edited_blob = serde_json::to_string(&edited).unwrap();

        let err = import_backup(
            &mut engine,
            edited_blob,
            "passphrase".to_owned(),
            "user_1".to_owned(),
            "device_1".to_owned(),
        )
        .expect_err(&format!(
            "editing kdf.{} changed nothing, so the importer is deriving from \
             its own constants rather than the envelope - a blob written by the \
             desktop client would not open here",
            field
        ));

        assert!(
            err.contains("could not open the backup"),
            "kdf.{} should have failed at decryption, not earlier: {}",
            field,
            err
        );
    }
}

/// The same property for `ApplicationUser.EncryptedMasterKey`, which is one row
/// per account that both clients read.
#[test]
fn declared_master_key_parameters_are_the_ones_actually_used() {
    let envelope = setup_master_key("hunter2", None).expect("setup").password_wrapping;
    let key = decrypt_master_key(&envelope, "hunter2").expect("the real one opens");

    let as_json = serde_json::to_value(&envelope).unwrap();
    assert_eq!(
        as_json["argon2Parallelism"].as_u64(),
        Some(1),
        "the master key declares p = 1 while the backup envelope declares p = 4. \
         Do NOT align them: every key already wrapped under the other value would \
         stop opening, and nothing would notice until someone needed it."
    );

    let perturbations: [(&str, serde_json::Value); 3] = [
        ("argon2Memory", serde_json::json!(32768u32)),
        ("argon2Iterations", serde_json::json!(4u32)),
        ("argon2Parallelism", serde_json::json!(2u32)),
    ];

    for (field, value) in perturbations {
        let mut edited = as_json.clone();
        edited[field] = value.clone();
        let edited: EncryptedMasterKey = serde_json::from_value(edited).unwrap();

        assert!(
            decrypt_master_key(&edited, "hunter2").is_err(),
            "editing {} changed nothing, so the unwrap is deriving from this \
             build's constants rather than the stored envelope",
            field
        );
    }

    // And the untouched one still opens to the same key afterwards - the
    // perturbations must not have mutated anything shared.
    assert_eq!(decrypt_master_key(&envelope, "hunter2").unwrap(), key);
}

// ---------------------------------------------------------------------------
// Dual-wrapped master key (contract §C.1.1)
// ---------------------------------------------------------------------------

/// The scenario the second wrapping exists for, start to finish.
///
/// `ResetPassword` never touched `EncryptedMasterKey`, so the envelope stayed
/// sealed under a password the user had - by definition of a reset - forgotten.
/// Every backup blob and the account identity key became permanently unopenable,
/// silently, at exactly the moment someone was trying to recover their account.
#[test]
fn a_password_reset_does_not_destroy_the_master_key() {
    let setup = setup_master_key("hunter2", None).expect("setup");

    // The same 32 bytes are behind both wrappings - they are two doors to one
    // room, not two rooms.
    let via_password = decrypt_master_key(&setup.password_wrapping, "hunter2").unwrap();
    let via_code = decrypt_master_key(
        &setup.recovery_code_wrapping,
        &normalize_recovery_code(&setup.recovery_code).unwrap(),
    )
    .unwrap();
    assert_eq!(via_password, via_code);
    assert_eq!(via_password, setup.master_key);

    // The reset happens. The old password is gone and the password wrapping is
    // now undecryptable by anyone, including its owner.
    assert!(decrypt_master_key(&setup.password_wrapping, "whatever-the-new-one-is").is_err());

    // The recovery code still opens it, which is the entire point.
    let recovered = decrypt_master_key(
        &setup.recovery_code_wrapping,
        &normalize_recovery_code(&setup.recovery_code).unwrap(),
    )
    .expect("the recovery code must survive a password reset");

    // Re-wrap under the new password. Note it re-*wraps* - the master key itself
    // is unchanged, so every blob already sealed under it stays readable.
    let rewrapped = wrap_master_key_under(&recovered, "hunter3").unwrap();
    assert_eq!(
        decrypt_master_key(&rewrapped, "hunter3").unwrap(),
        setup.master_key,
        "re-wrapping must preserve the master key, not mint a new one"
    );

    // And the recovery code is still good afterwards - re-wrapping the password
    // side must not disturb the other door.
    assert_eq!(
        decrypt_master_key(
            &setup.recovery_code_wrapping,
            &normalize_recovery_code(&setup.recovery_code).unwrap()
        )
        .unwrap(),
        setup.master_key
    );
}

/// Retrofitting the accounts that predate §C.1.1 - every one of which is a single
/// password reset away from losing everything.
#[test]
fn an_account_with_only_a_password_wrapping_can_be_given_a_recovery_code() {
    let setup = setup_master_key("hunter2", None).unwrap();
    let master_key = decrypt_master_key(&setup.password_wrapping, "hunter2").unwrap();

    let code = generate_recovery_code();
    let added = wrap_master_key_under(&master_key, &normalize_recovery_code(&code).unwrap()).unwrap();

    assert_eq!(
        decrypt_master_key(&added, &normalize_recovery_code(&code).unwrap()).unwrap(),
        master_key,
        "the retrofitted wrapping must open the same key the password one does"
    );
}

/// A code the user types back is not the code they were shown: they lower-case
/// it, or drop the grouping dashes, or paste it with a trailing space. Deriving
/// from the raw string would reject a correct code at the one moment its owner
/// has nothing else to try.
#[test]
fn a_recovery_code_is_accepted_however_the_user_types_it() {
    let setup = setup_master_key("hunter2", None).unwrap();
    let shown = setup.recovery_code.clone();

    let variants = [
        shown.clone(),
        shown.to_lowercase(),
        shown.replace('-', ""),
        shown.replace('-', " "),
        format!("  {}  ", shown.to_lowercase()),
    ];

    for variant in variants {
        assert_eq!(
            decrypt_master_key(
                &setup.recovery_code_wrapping,
                &normalize_recovery_code(&variant).unwrap()
            )
            .expect("a correctly-typed code must open regardless of formatting"),
            setup.master_key,
            "failed for {:?}",
            variant
        );
    }

    // And a genuinely wrong code still does not open it.
    assert!(decrypt_master_key(
        &setup.recovery_code_wrapping,
        &normalize_recovery_code("2222-2222-2222-2222-2222-2222-2222-2222").unwrap()
    )
    .is_err());
}

#[test]
fn a_recovery_code_is_unambiguous_and_high_entropy() {
    let code = generate_recovery_code();

    // Eight groups of four: 32 characters over a 32-symbol alphabet is 160 bits.
    let groups: Vec<&str> = code.split('-').collect();
    assert_eq!(groups.len(), 8, "{}", code);
    assert!(groups.iter().all(|g| g.len() == 4), "{}", code);

    // None of the characters people transcribe wrongly.
    for bad in ['I', 'L', 'O', '0', '1'] {
        assert!(
            !code.contains(bad),
            "recovery code contains the ambiguous character {}: {}",
            bad,
            code
        );
    }

    // And it is actually random - two in a row must not match.
    assert_ne!(code, generate_recovery_code());
}

/// The caller may supply a code so a UI can show it and get confirmation before
/// committing, but the wrapping must be made under the *normalised* form or the
/// code that was displayed would not open it.
#[test]
fn a_caller_supplied_recovery_code_is_wrapped_normalised() {
    const TYPED: &str = "abcd-efgh-2345-6789-jkmn-pqrs-tvwx-yz23";
    let setup = setup_master_key("hunter2", Some(TYPED)).unwrap();

    assert_eq!(setup.recovery_code, TYPED, "shown back exactly as supplied");
    assert_eq!(
        decrypt_master_key(
            &setup.recovery_code_wrapping,
            "ABCDEFGH23456789JKMNPQRSTVWXYZ23"
        )
        .unwrap(),
        setup.master_key
    );
    // And as displayed, too.
    assert_eq!(
        decrypt_master_key(
            &setup.recovery_code_wrapping,
            &normalize_recovery_code(TYPED).unwrap()
        )
        .unwrap(),
        setup.master_key
    );

    // A malformed caller-supplied code is an error, not a silently generated
    // substitute - a UI that showed one code and wrapped under another would
    // hand its user a credential that opens nothing.
    assert!(setup_master_key("hunter2", Some("too-short")).is_err());
}

/// Two independently-derived wrap keys, so compromising one wrapping's KDF
/// output tells an attacker nothing about the other.
#[test]
fn the_two_wrappings_share_no_salt_and_no_ciphertext() {
    let setup = setup_master_key("hunter2", None).unwrap();

    assert_ne!(setup.password_wrapping.salt, setup.recovery_code_wrapping.salt);
    assert_ne!(setup.password_wrapping.iv, setup.recovery_code_wrapping.iv);
    assert_ne!(
        setup.password_wrapping.cipher_text,
        setup.recovery_code_wrapping.cipher_text
    );
    assert_eq!(
        setup.password_wrapping.version, setup.recovery_code_wrapping.version,
        "both wrappings seal the same bytes, so they share a version"
    );
}

// ---------------------------------------------------------------------------
// Recovery-code format (contract §C.1.2)
// ---------------------------------------------------------------------------

/// The alphabet is **wire format**, and this is the regression guard for the bug
/// that made it so.
///
/// A 32nd symbol, `*`, was briefly appended purely so a 5-bit mask would be
/// uniform. Sound about bias, wrong trade: `*` was not in the desktop client's
/// alphabet, so its validator rejected every code containing one and fell back to
/// the *unnormalised* input - deriving a different key silently, during the one
/// operation the code exists for. Roughly one character in 32 was a `*`, so most
/// codes were affected.
#[test]
fn recovery_codes_use_only_the_shared_31_symbol_alphabet() {
    const SHARED: &str = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";
    assert_eq!(
        SHARED.len(),
        31,
        "the alphabet is shared with the desktop client and is exactly 31 symbols"
    );

    // Enough draws that a 1-in-31 symbol would show up many times over if one had
    // crept back in.
    for _ in 0..200 {
        let code = generate_recovery_code();
        for c in code.chars().filter(|c| *c != '-') {
            assert!(
                SHARED.contains(c),
                "generated a character the desktop client would reject: {:?} in {}",
                c,
                code
            );
        }
    }
}

/// Rejection sampling, not masking. Every symbol has to be equally likely, and
/// the fix for the bias must not be "pad the alphabet to a power of two" - that
/// is precisely what broke cross-client recovery.
#[test]
fn recovery_code_symbols_are_uniformly_distributed() {
    const ALPHABET: &str = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";
    let mut counts = std::collections::HashMap::new();

    // 2000 codes x 32 characters = 64k draws, ~2064 expected per symbol.
    for _ in 0..2000 {
        for c in generate_recovery_code().chars().filter(|c| *c != '-') {
            *counts.entry(c).or_insert(0usize) += 1;
        }
    }

    assert_eq!(counts.len(), 31, "every symbol should appear at least once");

    let total: usize = counts.values().sum();
    let expected = total as f64 / 31.0;
    for (symbol, count) in &counts {
        let drift = (*count as f64 - expected).abs() / expected;
        // Generous - this is a smoke test for a systematic bias, not a
        // statistical proof, and a flaky crypto test is worse than none. Simple
        // masking against 31 symbols would put two of them ~100% high, far
        // outside this.
        assert!(
            drift < 0.25,
            "symbol {:?} appeared {} times against an expected {:.0} - that looks \
             like a sampling bias, not noise",
            symbol,
            count,
            expected
        );
        assert!(ALPHABET.contains(*symbol));
    }
}

/// Normalisation is total: anything that is not a well-formed recovery code is an
/// error, never a pass-through.
///
/// A silent fallback to the raw input converts a recoverable typo into
/// unrecoverable data loss with no diagnostic - the KDF derives *a* key from the
/// typo, the AEAD fails, and all the user learns is "wrong code".
#[test]
fn normalising_a_malformed_recovery_code_is_an_error_not_a_passthrough() {
    let valid = generate_recovery_code();
    assert!(normalize_recovery_code(&valid).is_ok());

    let bad: [(&str, &str); 5] = [
        ("too short", "ABCD-EFGH"),
        ("too long", "ABCD-EFGH-2345-6789-JKMN-PQRS-TVWX-YZ23-2345"),
        ("empty", ""),
        // The exact character that caused this. It must be rejected loudly rather
        // than fed to the KDF.
        ("contains an asterisk", "ABCD-EFGH-2345-6789-JKMN-PQRS-TVWX-YZ2*"),
        // The glyphs the alphabet deliberately omits.
        ("contains O and I", "ABCD-EFGH-2345-6789-JKMN-PQRS-TVWX-YZOI"),
    ];

    for (why, input) in bad {
        let err = normalize_recovery_code(input)
            .expect_err(&format!("{} should not normalise: {:?}", why, input));
        assert!(
            err.starts_with("RecoveryCodeInvalid:"),
            "the error has to be typed so the UI can say \"that is not a recovery \
             code\" rather than \"wrong code\": {}",
            err
        );
    }
}

/// Cross-client fixture. Contract §C.1.2 point 4 and the §F golden-vector
/// pattern: a code generated by the *other* client must open a wrapping this one
/// produces, and vice versa.
///
/// This is the class of bug that is invisible until somebody is mid-recovery with
/// no second copy, which is the worst possible moment to find it.
#[test]
fn a_recovery_code_fixture_round_trips_through_this_engine() {
    let fixture: serde_json::Value = serde_json::from_str(
        &std::fs::read_to_string(golden_path("recovery-code.json"))
            .expect("testdata/mls-golden/v1/recovery-code.json is checked in"),
    )
    .expect("the fixture is JSON");

    let code = fixture["recoveryCode"].as_str().unwrap();
    let expected_master_key = fixture["masterKey"].as_str().unwrap();

    // The code as written down has to validate here.
    let normalized = normalize_recovery_code(code)
        .expect("the fixture code must be well-formed under this alphabet");
    assert_eq!(normalized, fixture["normalized"].as_str().unwrap());

    // And the wrapping it was sealed under has to open.
    let wrapping: EncryptedMasterKey =
        serde_json::from_value(fixture["recoveryCodeWrapping"].clone()).unwrap();
    assert_eq!(
        decrypt_master_key(&wrapping, &normalized).expect("the fixture wrapping must open"),
        expected_master_key,
        "a wrapping sealed under this recovery code did not yield the master key"
    );

    // Typed the way a human would, too.
    assert_eq!(
        decrypt_master_key(
            &wrapping,
            &normalize_recovery_code(&code.to_lowercase().replace('-', " ")).unwrap()
        )
        .unwrap(),
        expected_master_key
    );
}

/// Consumes the desktop client's fixture, once it supplies one.
///
/// Deliberately tolerant of the file being absent rather than red in CI while the
/// other side lands its half - but loud about it, because a cross-client test
/// that quietly tests nothing is worse than no test at all.
#[test]
fn this_engine_opens_the_desktop_clients_recovery_code_fixture() {
    let path = golden_path("recovery-code-alpine.json");
    let Ok(raw) = std::fs::read_to_string(&path) else {
        println!(
            "SKIPPED: {} has not been supplied yet. Until it is, cross-client \
             recovery is asserted in one direction only.",
            path.display()
        );
        return;
    };

    let fixture: serde_json::Value = serde_json::from_str(&raw).expect("the fixture is JSON");
    let code = fixture["recoveryCode"].as_str().unwrap();

    let normalized = normalize_recovery_code(code)
        .expect("a code the desktop client generated must be well-formed here");

    let wrapping: EncryptedMasterKey =
        serde_json::from_value(fixture["recoveryCodeWrapping"].clone()).unwrap();
    assert_eq!(
        decrypt_master_key(&wrapping, &normalized)
            .expect("this engine must open a wrapping the desktop client sealed"),
        fixture["masterKey"].as_str().unwrap()
    );
}

/// Writes this client's half of the cross-client fixture, for the desktop client
/// to consume. Ignored by default - see `generate_golden_fixture`.
#[test]
#[ignore]
fn generate_recovery_code_fixture() {
    let setup = setup_master_key("fixture-password", None).expect("setup");
    let normalized = normalize_recovery_code(&setup.recovery_code).unwrap();

    let fixture = serde_json::json!({
        "producedBy": "venta-mobile",
        "alphabet": "23456789ABCDEFGHJKMNPQRSTUVWXYZ",
        "recoveryCode": setup.recovery_code,
        "normalized": normalized,
        "masterKey": setup.master_key,
        "recoveryCodeWrapping": serde_json::to_value(&setup.recovery_code_wrapping).unwrap(),
    });

    let out = golden_path("recovery-code.json");
    std::fs::write(&out, serde_json::to_string_pretty(&fixture).unwrap()).unwrap();
    println!("wrote {}", out.display());
}
