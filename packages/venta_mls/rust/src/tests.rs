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

/// A device: its own engine state, its own signing key handle.
struct Device {
    state: MlsState,
    handle: String,
}

impl Device {
    fn new(identity: &str, key_package_count: u32) -> (Self, Vec<String>) {
        let mut state = MlsState::default();
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

    let received = process_message(&mut bob.state, &gid, &sent.ciphertext).expect("decrypt");
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

    let processed = process_message(&mut bob.state, &gid, &removal.commit).unwrap();
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

