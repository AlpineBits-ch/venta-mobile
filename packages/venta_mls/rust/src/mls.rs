//! MLS (RFC 9420) group engine.
//!
//! Ported from Alpine's `src-tauri/src/crypto/mls.rs`. The logic is deliberately
//! kept line-for-line equivalent: both clients talk to the same server, join the
//! same groups and read each other's ciphertext, so any divergence here is a
//! divergence in the wire protocol. The only things that changed are the edges -
//! Tauri's `State`/`AppHandle` became a process-global `Mutex` and an explicitly
//! passed storage path, because Flutter has neither.

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{Mutex, OnceLock};

use aes_gcm::{
    aead::Aead,
    {Aes256Gcm, KeyInit, Nonce},
};
use base64::{engine::general_purpose::STANDARD as B64, Engine};
use openmls::prelude::*;
use openmls::prelude::{
    tls_codec::{Deserialize as TlsCodecDeserialize, DeserializeBytes, Serialize as TlsSerialize},
    BasicCredential, Ciphersuite, CredentialWithKey, GroupId, KeyPackage, KeyPackageIn,
    LeafNodeIndex, MlsGroup, MlsGroupCreateConfig, MlsGroupJoinConfig, MlsMessageBodyIn,
    MlsMessageIn, OpenMlsProvider, ProcessedMessageContent, ProtocolVersion, SignatureScheme,
    StagedWelcome,
};
use openmls_basic_credential::SignatureKeyPair;
use openmls_rust_crypto::OpenMlsRustCrypto;
use rand::RngCore;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use uuid::Uuid;

/// Must match Alpine's exactly. A group created under one ciphersuite cannot be
/// joined by a device offering a key package built under another.
const CIPHERSUITE: Ciphersuite = Ciphersuite::MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519;

// ---------------------------------------------------------------------------
// Output types (serialized to JSON across the FFI boundary)
// ---------------------------------------------------------------------------

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct KeyPackageResult {
    pub key_package: String,
    pub init_private_key: String,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MlsKeyPackageBatch {
    pub signing_public_key: String,
    pub signing_private_key: String,
    pub key_packages: Vec<KeyPackageResult>,
    pub key_handle: String,
}

#[derive(Serialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct MlsMemberInfo {
    pub leaf_index: u32,
    pub identity: String,
    pub encryption_key: String,
    pub signature_key: String,
}

#[derive(Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct MlsGroupInfo {
    pub group_id: String,
    pub epoch: u64,
    pub own_leaf_index: u32,
    pub members: Vec<MlsMemberInfo>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MlsCommitOut {
    pub commit: String,
    pub welcome: Option<String>,
    pub epoch: u64,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MlsProcessedMessage {
    pub kind: String,
    pub plaintext: Option<String>,
    pub self_removed: bool,
    pub added_members: Vec<MlsMemberInfo>,
    pub removed_leaf_indices: Vec<u32>,
    pub sender_identity: Option<String>,
    pub epoch: Option<u64>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MlsSendOut {
    pub ciphertext: String,
    pub epoch: u64,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MlsRejoinOut {
    pub group_info: MlsGroupInfo,
    pub external_commit: String,
}

/// Everything a reviewer needs to decide whether a key package really belongs to
/// who it claims.
#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MlsKeyPackageInfo {
    /// Identity from the BasicCredential - the user id the package claims.
    pub identity: String,
    /// Long-lived Ed25519 signature key (base64).
    pub signature_public_key: String,
    /// Human-comparable fingerprint of the *signature* key.
    ///
    /// Deliberately not a hash of the key package: that changes with every
    /// package a device mints, so two people reading it to each other would
    /// never agree on anything. The signature key is the device's stable
    /// identity, so this is the value that means something out of band.
    pub signature_key_fingerprint: String,
    /// SHA-256 of the key package bytes, hex. Binds an approval to these exact
    /// bytes.
    pub key_package_hash: String,
}

// ---------------------------------------------------------------------------
// In-process state
// ---------------------------------------------------------------------------

#[derive(Serialize, Deserialize)]
struct PersistedMlsState {
    version: u32,
    group_ids: Vec<String>,
    storage: HashMap<String, String>,
}

struct SignerEntry {
    pub_bytes: Vec<u8>,
    priv_bytes: Vec<u8>,
    identity: String,
}

#[derive(Default)]
pub struct MlsState {
    provider: OpenMlsRustCrypto,
    groups: HashMap<Vec<u8>, MlsGroup>,
    signers: HashMap<String, SignerEntry>,
    pending_messages: HashMap<Vec<u8>, Vec<(u64, Vec<u8>)>>,
    state_path: Option<PathBuf>,
}

impl MlsState {
    fn to_persisted(&self) -> PersistedMlsState {
        let values = self.provider.storage().values.read().unwrap();
        let storage = values
            .iter()
            .map(|(k, v)| (B64.encode(k), B64.encode(v)))
            .collect();
        let group_ids = self.groups.keys().map(|k| B64.encode(k)).collect();
        PersistedMlsState {
            version: 1,
            group_ids,
            storage,
        }
    }

    /// Writes via a temp file and a rename.
    ///
    /// Alpine writes in place, which it can afford: a desktop process is not
    /// killed mid-syscall. Android kills backgrounded apps freely, and a
    /// half-written `mls_state.json` is not a recoverable state - it is every
    /// group this device belongs to, gone.
    fn save_to_disk(&self) -> Result<(), String> {
        let Some(path) = &self.state_path else {
            return Ok(());
        };
        let json = serde_json::to_vec(&self.to_persisted()).map_err(|e| e.to_string())?;
        let tmp = path.with_extension("json.tmp");
        std::fs::write(&tmp, json).map_err(|e| e.to_string())?;
        std::fs::rename(&tmp, path).map_err(|e| e.to_string())?;
        Ok(())
    }
}

static STATE: OnceLock<Mutex<MlsState>> = OnceLock::new();

/// The one MLS state for the process.
///
/// A poisoned mutex is recovered from rather than propagated: the poison means
/// some earlier call panicked, not that the group data is wrong, and refusing
/// every subsequent call would turn one bad message into a permanently dead
/// engine.
pub fn with_state<T>(f: impl FnOnce(&mut MlsState) -> Result<T, String>) -> Result<T, String> {
    let mutex = STATE.get_or_init(|| Mutex::new(MlsState::default()));
    let mut guard = match mutex.lock() {
        Ok(g) => g,
        Err(poisoned) => poisoned.into_inner(),
    };
    f(&mut guard)
}

// ---------------------------------------------------------------------------
// Encryption helpers (encrypted state backup)
// ---------------------------------------------------------------------------

fn encrypt_blob(plaintext: &[u8], key_bytes: &[u8]) -> Result<Vec<u8>, String> {
    let cipher = Aes256Gcm::new_from_slice(key_bytes).map_err(|e| e.to_string())?;
    let mut nonce_bytes = [0u8; 12];
    rand::thread_rng().fill_bytes(&mut nonce_bytes);
    let nonce = Nonce::from_slice(&nonce_bytes);
    let ciphertext = cipher.encrypt(nonce, plaintext).map_err(|e| e.to_string())?;
    let mut out = nonce_bytes.to_vec();
    out.extend_from_slice(&ciphertext);
    Ok(out)
}

fn decrypt_blob(data: &[u8], key_bytes: &[u8]) -> Result<Vec<u8>, String> {
    if data.len() < 12 {
        return Err("MlsError: encrypted blob too short".to_string());
    }
    let (nonce_bytes, ciphertext) = data.split_at(12);
    let cipher = Aes256Gcm::new_from_slice(key_bytes).map_err(|e| e.to_string())?;
    cipher
        .decrypt(Nonce::from_slice(nonce_bytes), ciphertext)
        .map_err(|e| e.to_string())
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

fn build_signer_from_entry(entry: &SignerEntry) -> SignatureKeyPair {
    SignatureKeyPair::from_raw(
        SignatureScheme::ED25519,
        entry.priv_bytes.clone(),
        entry.pub_bytes.clone(),
    )
}

fn get_signer_entry<'a>(mls: &'a MlsState, key_handle: &str) -> Result<&'a SignerEntry, String> {
    mls.signers.get(key_handle).ok_or_else(|| {
        format!(
            "KeyNotFound: no signing key loaded for handle '{}'",
            key_handle
        )
    })
}

/// Prefixes the error with a kind the Dart side can branch on. Same vocabulary
/// as Alpine's `parseMlsError`, because the two clients hit the same failures
/// and a `WrongEpoch` has to mean "buffer and retry" on both.
pub fn map_mls_error(e: impl std::fmt::Display) -> String {
    let s = e.to_string();
    let lower = s.to_lowercase();
    if lower.contains("wrong epoch")
        || lower.contains("epoch mismatch")
        || lower.contains("wrongepoch")
    {
        format!("WrongEpoch: {}", s)
    } else if lower.contains("unknown sender")
        || lower.contains("invalid sender")
        || lower.contains("unknownsender")
    {
        format!("UnknownSender: {}", s)
    } else if lower.contains("validation") || lower.contains("invalid message") {
        format!("ValidationError: {}", s)
    } else if lower.contains("group not found") || lower.contains("no such group") {
        format!("GroupNotFound: {}", s)
    } else if lower.contains("key not found") || lower.contains("no key") {
        format!("KeyNotFound: {}", s)
    } else {
        format!("MlsError: {}", s)
    }
}

fn member_to_info(m: openmls::prelude::Member) -> MlsMemberInfo {
    let identity = BasicCredential::try_from(m.credential)
        .map(|bc| String::from_utf8_lossy(bc.identity()).into_owned())
        .unwrap_or_default();
    MlsMemberInfo {
        leaf_index: m.index.u32(),
        identity,
        encryption_key: B64.encode(&m.encryption_key),
        signature_key: B64.encode(&m.signature_key),
    }
}

fn group_members(group: &MlsGroup) -> Vec<MlsMemberInfo> {
    group.members().map(member_to_info).collect()
}

fn build_group_info(group: &MlsGroup) -> MlsGroupInfo {
    MlsGroupInfo {
        group_id: B64.encode(group.group_id().as_slice()),
        epoch: group.epoch().as_u64(),
        own_leaf_index: group.own_leaf_index().u32(),
        members: group_members(group),
    }
}

fn create_config() -> MlsGroupCreateConfig {
    let ratchet_config = SenderRatchetConfiguration::new(
        500, // max_forward_distance
        10,  // out_of_order_tolerance
    );
    MlsGroupCreateConfig::builder()
        .sender_ratchet_configuration(ratchet_config)
        .use_ratchet_tree_extension(true)
        .build()
}

fn join_config() -> MlsGroupJoinConfig {
    let ratchet_config = SenderRatchetConfiguration::new(500, 10);
    MlsGroupJoinConfig::builder()
        .sender_ratchet_configuration(ratchet_config)
        .use_ratchet_tree_extension(true)
        .build()
}

fn serialize_welcome(welcome_msg: openmls::prelude::MlsMessageOut) -> Result<String, String> {
    welcome_msg
        .tls_serialize_detached()
        .map(|b| B64.encode(&b))
        .map_err(|e| e.to_string())
}

// ---------------------------------------------------------------------------
// Operations
// ---------------------------------------------------------------------------

pub fn load_signing_key(
    mls: &mut MlsState,
    signing_public_key_b64: &str,
    signing_private_key_b64: &str,
    identity: String,
) -> Result<String, String> {
    let pub_bytes = B64
        .decode(signing_public_key_b64)
        .map_err(|e| e.to_string())?;
    let priv_bytes = B64
        .decode(signing_private_key_b64)
        .map_err(|e| e.to_string())?;
    let handle = Uuid::new_v4().to_string();
    mls.signers.insert(
        handle.clone(),
        SignerEntry {
            pub_bytes,
            priv_bytes,
            identity,
        },
    );
    Ok(handle)
}

pub fn unload_signing_key(mls: &mut MlsState, key_handle: &str) -> Result<(), String> {
    mls.signers.remove(key_handle);
    Ok(())
}

pub fn generate_key_packages(
    mls: &mut MlsState,
    identity: String,
    count: u32,
) -> Result<MlsKeyPackageBatch, String> {
    let signer =
        SignatureKeyPair::new(CIPHERSUITE.signature_algorithm()).map_err(|e| e.to_string())?;
    let credential = BasicCredential::new(identity.clone().into_bytes());
    let credential_with_key = CredentialWithKey {
        credential: credential.into(),
        signature_key: signer.public().into(),
    };
    let mut key_packages = Vec::with_capacity(count as usize);
    {
        let provider = &mls.provider;
        for _ in 0..count {
            let bundle = KeyPackage::builder()
                .build(CIPHERSUITE, provider, &signer, credential_with_key.clone())
                .map_err(|e| e.to_string())?;
            let kp_bytes = bundle
                .key_package()
                .tls_serialize_detached()
                .map_err(|e| e.to_string())?;
            key_packages.push(KeyPackageResult {
                key_package: B64.encode(&kp_bytes),
                init_private_key: B64.encode(&**bundle.init_private_key()),
            });
        }
    }
    let pub_b64 = B64.encode(signer.public());
    let priv_b64 = B64.encode(signer.private());
    let handle = Uuid::new_v4().to_string();
    mls.signers.insert(
        handle.clone(),
        SignerEntry {
            pub_bytes: signer.public().to_vec(),
            priv_bytes: signer.private().to_vec(),
            identity,
        },
    );
    let batch = MlsKeyPackageBatch {
        signing_public_key: pub_b64,
        signing_private_key: priv_b64,
        key_packages,
        key_handle: handle,
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(batch)
}

pub fn generate_key_packages_with_handle(
    mls: &MlsState,
    key_handle: &str,
    count: u32,
) -> Result<Vec<KeyPackageResult>, String> {
    let (signer, identity) = {
        let entry = get_signer_entry(mls, key_handle)?;
        (build_signer_from_entry(entry), entry.identity.clone())
    };
    let credential = BasicCredential::new(identity.into_bytes());
    let credential_with_key = CredentialWithKey {
        credential: credential.into(),
        signature_key: signer.public().into(),
    };
    let mut key_packages = Vec::with_capacity(count as usize);
    {
        let provider = &mls.provider;
        for _ in 0..count {
            let bundle = KeyPackage::builder()
                .build(CIPHERSUITE, provider, &signer, credential_with_key.clone())
                .map_err(|e| e.to_string())?;
            let kp_bytes = bundle
                .key_package()
                .tls_serialize_detached()
                .map_err(|e| e.to_string())?;
            key_packages.push(KeyPackageResult {
                key_package: B64.encode(&kp_bytes),
                init_private_key: B64.encode(&**bundle.init_private_key()),
            });
        }
    }
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(key_packages)
}

pub fn create_group(
    mls: &mut MlsState,
    group_id_b64: &str,
    key_handle: &str,
) -> Result<MlsGroupInfo, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let group_id = GroupId::from_slice(&group_id_bytes);
    let (signer, identity) = {
        let entry = get_signer_entry(mls, key_handle)?;
        (build_signer_from_entry(entry), entry.identity.clone())
    };
    let credential = BasicCredential::new(identity.into_bytes());
    let credential_with_key = CredentialWithKey {
        credential: credential.into(),
        signature_key: signer.public().into(),
    };
    let group = {
        let MlsState { provider, .. } = &*mls;
        MlsGroup::new_with_group_id(
            provider,
            &signer,
            &create_config(),
            group_id,
            credential_with_key,
        )
        .map_err(map_mls_error)?
    };
    let info = build_group_info(&group);
    mls.groups.insert(group_id_bytes, group);
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(info)
}

pub fn add_members(
    mls: &mut MlsState,
    group_id_b64: &str,
    key_handle: &str,
    key_packages_b64: &[String],
) -> Result<MlsCommitOut, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let signer = {
        let entry = get_signer_entry(mls, key_handle)?;
        build_signer_from_entry(entry)
    };
    let key_packages: Vec<KeyPackage> = {
        let crypto = mls.provider.crypto();
        key_packages_b64
            .iter()
            .map(|kp_b64| {
                let kp_bytes = B64.decode(kp_b64).map_err(|e| e.to_string())?;
                let kp_in =
                    KeyPackageIn::tls_deserialize(&mut &kp_bytes[..]).map_err(|e| e.to_string())?;
                kp_in
                    .validate(crypto, ProtocolVersion::Mls10)
                    .map_err(map_mls_error)
            })
            .collect::<Result<_, _>>()?
    };
    let commit_out = {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        let (commit_msg, welcome_msg, _group_info) = group
            .add_members(provider, &signer, &key_packages)
            .map_err(map_mls_error)?;
        // Deliberately *not* merged here. The server accepts exactly one commit
        // per epoch, so a commit that loses that race must never have been
        // applied locally - a group that advanced on a commit nobody else has is
        // forked, and MLS gives no way to walk that back. The caller merges via
        // `merge_pending_commit` once the server takes it, or discards via
        // `clear_pending_commit` when it does not.
        let epoch = group.epoch().as_u64() + 1;
        let commit_bytes = commit_msg
            .tls_serialize_detached()
            .map_err(|e| e.to_string())?;
        let welcome_bytes = welcome_msg
            .tls_serialize_detached()
            .map_err(|e| e.to_string())?;
        MlsCommitOut {
            commit: B64.encode(&commit_bytes),
            welcome: Some(B64.encode(&welcome_bytes)),
            epoch,
        }
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(commit_out)
}

pub fn join_group(
    mls: &mut MlsState,
    welcome_b64: &str,
    key_handle: &str,
) -> Result<MlsGroupInfo, String> {
    get_signer_entry(mls, key_handle)?;
    let welcome_bytes = B64.decode(welcome_b64).map_err(|e| e.to_string())?;
    let welcome_msg_in =
        MlsMessageIn::tls_deserialize_exact_bytes(&welcome_bytes).map_err(|e| e.to_string())?;
    let welcome = match welcome_msg_in.extract() {
        MlsMessageBodyIn::Welcome(w) => w,
        _ => return Err("MlsError: message is not a Welcome".to_string()),
    };
    let group = {
        let MlsState { provider, .. } = &*mls;
        let staged = StagedWelcome::new_from_welcome(provider, &join_config(), welcome, None)
            .map_err(map_mls_error)?;
        staged.into_group(provider).map_err(map_mls_error)?
    };
    let info = build_group_info(&group);
    let group_id_bytes = group.group_id().as_slice().to_vec();
    mls.groups.insert(group_id_bytes, group);
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(info)
}

/// In MLS a member cannot commit their own removal, so this produces a Remove
/// *proposal*. Callers broadcast it so a remaining member can commit it via
/// [`commit_pending_proposals`]. Local group state is dropped immediately, so
/// the leaver loses access whether or not anyone ever commits it.
pub fn leave_group(
    mls: &mut MlsState,
    group_id_b64: &str,
    key_handle: &str,
) -> Result<MlsCommitOut, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let signer = {
        let entry = get_signer_entry(mls, key_handle)?;
        build_signer_from_entry(entry)
    };
    let proposal_out = {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        let own_leaf = group.own_leaf_index();
        let (proposal_msg, _group_info) = group
            .propose_remove_member(provider, &signer, own_leaf)
            .map_err(map_mls_error)?;
        let proposal_bytes = proposal_msg
            .tls_serialize_detached()
            .map_err(|e| e.to_string())?;
        groups.remove(&group_id_bytes);
        MlsCommitOut {
            commit: B64.encode(&proposal_bytes),
            welcome: None,
            epoch: 0,
        }
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(proposal_out)
}

pub fn commit_pending_proposals(
    mls: &mut MlsState,
    group_id_b64: &str,
    key_handle: &str,
) -> Result<MlsCommitOut, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let signer = {
        let entry = get_signer_entry(mls, key_handle)?;
        build_signer_from_entry(entry)
    };
    let commit_out = {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        let (commit_msg, welcome_opt, _group_info) = group
            .commit_to_pending_proposals(provider, &signer)
            .map_err(map_mls_error)?;
        // Staged, not merged - see add_members for why.
        let epoch = group.epoch().as_u64() + 1;
        let commit_bytes = commit_msg
            .tls_serialize_detached()
            .map_err(|e| e.to_string())?;
        let welcome = welcome_opt.map(serialize_welcome).transpose()?;
        MlsCommitOut {
            commit: B64.encode(&commit_bytes),
            welcome,
            epoch,
        }
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(commit_out)
}

/// Second half of the two-phase commit dance: applies a staged commit once the
/// server has accepted it. Safe to retry - merging with nothing staged is a
/// no-op, so a client that published and then died can merge on next launch.
pub fn merge_pending_commit(mls: &mut MlsState, group_id_b64: &str) -> Result<u64, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let epoch = {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        group.merge_pending_commit(provider).map_err(map_mls_error)?;
        group.epoch().as_u64()
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(epoch)
}

/// Discards a staged commit the server refused, leaving the group where it was.
/// This is the losing side of a concurrent-commit race; applying a commit the
/// server did not take would fork this device off the group permanently.
pub fn clear_pending_commit(mls: &mut MlsState, group_id_b64: &str) -> Result<(), String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        group
            .clear_pending_commit(provider.storage())
            .map_err(|e| e.to_string())?;
    }
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(())
}

pub fn export_group_info(
    mls: &MlsState,
    group_id_b64: &str,
    key_handle: &str,
) -> Result<String, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let signer = {
        let entry = get_signer_entry(mls, key_handle)?;
        build_signer_from_entry(entry)
    };
    let group = mls
        .groups
        .get(&group_id_bytes)
        .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
    let group_info_msg = group
        .export_group_info(mls.provider.crypto(), &signer, true)
        .map_err(|e| e.to_string())?;
    let bytes = group_info_msg
        .tls_serialize_detached()
        .map_err(|e| e.to_string())?;
    Ok(B64.encode(&bytes))
}

pub fn rejoin_group(
    mls: &mut MlsState,
    group_info_b64: &str,
    key_handle: &str,
) -> Result<MlsRejoinOut, String> {
    let (signer, identity) = {
        let entry = get_signer_entry(mls, key_handle)?;
        (build_signer_from_entry(entry), entry.identity.clone())
    };
    let gi_bytes = B64.decode(group_info_b64).map_err(|e| e.to_string())?;
    let gi_msg = MlsMessageIn::tls_deserialize_exact_bytes(&gi_bytes).map_err(|e| e.to_string())?;
    let verifiable_group_info = match gi_msg.extract() {
        MlsMessageBodyIn::GroupInfo(vgi) => vgi,
        _ => return Err("MlsError: message is not a GroupInfo".to_string()),
    };
    let credential = BasicCredential::new(identity.into_bytes());
    let credential_with_key = CredentialWithKey {
        credential: credential.into(),
        signature_key: signer.public().into(),
    };
    let rejoin_out = {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let (group, bundle) = MlsGroup::external_commit_builder()
            .with_config(join_config())
            .build_group(provider, verifiable_group_info, credential_with_key)
            .map_err(map_mls_error)?
            .load_psks(provider.storage())
            .map_err(map_mls_error)?
            .build(provider.rand(), provider.crypto(), &signer, |_| true)
            .map_err(map_mls_error)?
            .finalize(provider)
            .map_err(|e| e.to_string())?;
        let external_commit_bytes = bundle
            .into_commit()
            .tls_serialize_detached()
            .map_err(|e| e.to_string())?;
        let info = build_group_info(&group);
        let group_id_bytes = group.group_id().as_slice().to_vec();
        groups.insert(group_id_bytes, group);
        MlsRejoinOut {
            group_info: info,
            external_commit: B64.encode(&external_commit_bytes),
        }
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(rejoin_out)
}

pub fn delete_group(mls: &mut MlsState, group_id_b64: &str) -> Result<(), String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    if mls.groups.remove(&group_id_bytes).is_none() {
        return Err("GroupNotFound: group not found".to_string());
    }
    mls.pending_messages.remove(&group_id_bytes);
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(())
}

pub fn send_message(
    mls: &mut MlsState,
    group_id_b64: &str,
    key_handle: &str,
    plaintext_b64: &str,
) -> Result<MlsSendOut, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let plaintext = B64.decode(plaintext_b64).map_err(|e| e.to_string())?;
    let signer = {
        let entry = get_signer_entry(mls, key_handle)?;
        build_signer_from_entry(entry)
    };
    let out = {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        let msg_out = group
            .create_message(provider, &signer, &plaintext)
            .map_err(map_mls_error)?;
        let epoch = group.epoch().as_u64();
        let msg_bytes = msg_out
            .tls_serialize_detached()
            .map_err(|e| e.to_string())?;
        MlsSendOut {
            ciphertext: B64.encode(&msg_bytes),
            epoch,
        }
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(out)
}

pub fn process_message(
    mls: &mut MlsState,
    group_id_b64: &str,
    message_b64: &str,
) -> Result<MlsProcessedMessage, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let msg_bytes = B64.decode(message_b64).map_err(|e| e.to_string())?;
    let msg_in = MlsMessageIn::tls_deserialize_exact_bytes(&msg_bytes).map_err(|e| e.to_string())?;
    let protocol_msg = msg_in
        .try_into_protocol_message()
        .map_err(|e| e.to_string())?;
    let processed_msg = {
        let MlsState {
            provider,
            groups,
            pending_messages,
            ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        let processed = group
            .process_message(provider, protocol_msg)
            .map_err(map_mls_error)?;
        let sender_identity = BasicCredential::try_from(processed.credential().clone())
            .map(|bc| String::from_utf8_lossy(bc.identity()).into_owned())
            .ok();
        match processed.into_content() {
            ProcessedMessageContent::ApplicationMessage(app_msg) => MlsProcessedMessage {
                kind: "application".into(),
                plaintext: Some(B64.encode(app_msg.into_bytes())),
                self_removed: false,
                added_members: vec![],
                removed_leaf_indices: vec![],
                sender_identity,
                epoch: None,
            },
            ProcessedMessageContent::StagedCommitMessage(staged_commit) => {
                let self_removed = staged_commit.self_removed();
                let removed: Vec<u32> = staged_commit
                    .remove_proposals()
                    .map(|p| p.remove_proposal().removed().u32())
                    .collect();
                let added: Vec<MlsMemberInfo> = staged_commit
                    .add_proposals()
                    .map(|p| {
                        let kp = p.add_proposal().key_package();
                        let leaf = kp.leaf_node();
                        let identity = BasicCredential::try_from(leaf.credential().clone())
                            .map(|bc| String::from_utf8_lossy(bc.identity()).into_owned())
                            .unwrap_or_default();
                        let enc_key = leaf
                            .encryption_key()
                            .tls_serialize_detached()
                            .map(|b| B64.encode(&b))
                            .unwrap_or_default();
                        MlsMemberInfo {
                            leaf_index: 0,
                            identity,
                            encryption_key: enc_key,
                            signature_key: B64.encode(leaf.signature_key().as_slice()),
                        }
                    })
                    .collect();
                group
                    .merge_staged_commit(provider, *staged_commit)
                    .map_err(|e| e.to_string())?;
                let epoch = group.epoch().as_u64();
                if let Some(buf) = pending_messages.get_mut(&group_id_bytes) {
                    buf.retain(|(msg_epoch, _)| *msg_epoch > epoch);
                }
                MlsProcessedMessage {
                    kind: "commit".into(),
                    plaintext: None,
                    self_removed,
                    added_members: added,
                    removed_leaf_indices: removed,
                    sender_identity,
                    epoch: Some(epoch),
                }
            }
            ProcessedMessageContent::ProposalMessage(queued_proposal) => {
                group
                    .store_pending_proposal(provider.storage(), *queued_proposal)
                    .map_err(|e| e.to_string())?;
                MlsProcessedMessage {
                    kind: "proposal".into(),
                    plaintext: None,
                    self_removed: false,
                    added_members: vec![],
                    removed_leaf_indices: vec![],
                    sender_identity,
                    epoch: None,
                }
            }
            ProcessedMessageContent::ExternalJoinProposalMessage(queued_proposal) => {
                group
                    .store_pending_proposal(provider.storage(), *queued_proposal)
                    .map_err(|e| e.to_string())?;
                MlsProcessedMessage {
                    kind: "proposal".into(),
                    plaintext: None,
                    self_removed: false,
                    added_members: vec![],
                    removed_leaf_indices: vec![],
                    sender_identity,
                    epoch: None,
                }
            }
        }
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(processed_msg)
}

pub fn remove_members(
    mls: &mut MlsState,
    group_id_b64: &str,
    key_handle: &str,
    leaf_indices: &[u32],
) -> Result<MlsCommitOut, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let signer = {
        let entry = get_signer_entry(mls, key_handle)?;
        build_signer_from_entry(entry)
    };
    let members: Vec<LeafNodeIndex> = leaf_indices.iter().map(|i| LeafNodeIndex::new(*i)).collect();
    let commit_out = {
        let MlsState {
            provider, groups, ..
        } = &mut *mls;
        let group = groups
            .get_mut(&group_id_bytes)
            .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
        let (commit_msg, welcome_opt, _group_info) = group
            .remove_members(provider, &signer, &members)
            .map_err(map_mls_error)?;
        // Staged, not merged - see add_members for why.
        let epoch = group.epoch().as_u64() + 1;
        let commit_bytes = commit_msg
            .tls_serialize_detached()
            .map_err(|e| e.to_string())?;
        let welcome = welcome_opt.map(serialize_welcome).transpose()?;
        MlsCommitOut {
            commit: B64.encode(&commit_bytes),
            welcome,
            epoch,
        }
    };
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(commit_out)
}

/// Renders a fingerprint as five-character groups, which is what makes it
/// readable aloud without losing your place. Uppercase hex over the SHA-256 of
/// the key, truncated to 80 bits.
fn format_fingerprint(bytes: &[u8]) -> String {
    let digest = Sha256::digest(bytes);
    digest
        .iter()
        .take(10)
        .map(|b| format!("{:02X}", b))
        .collect::<String>()
        .as_bytes()
        .chunks(5)
        .map(|c| String::from_utf8_lossy(c).into_owned())
        .collect::<Vec<_>>()
        .join("-")
}

/// The fingerprint for a signature public key, without needing a key package.
///
/// A device's *own* fingerprint is a pure function of its long-lived signing
/// key, which the caller already holds. Deriving it by minting a key package
/// just to inspect it would write a fresh init keypair into the engine's store
/// on every call - permanently, since nothing ever consumes it - and the store
/// is rewritten in full on every save, so that cost lands on every later
/// encrypt and decrypt too.
pub fn fingerprint_for_signature_key(signature_public_key_b64: &str) -> Result<String, String> {
    let key = B64
        .decode(signature_public_key_b64)
        .map_err(|e| e.to_string())?;
    Ok(format_fingerprint(&key))
}

/// Inspects a key package so a reviewer can check who it really belongs to
/// before vouching for it, and so the committing client can confirm the bytes
/// match what was approved.
pub fn inspect_key_package(
    mls: &MlsState,
    key_package_b64: &str,
) -> Result<MlsKeyPackageInfo, String> {
    let kp_bytes = B64.decode(key_package_b64).map_err(|e| e.to_string())?;
    let kp_in = KeyPackageIn::tls_deserialize(&mut &kp_bytes[..]).map_err(|e| e.to_string())?;

    // Validated, not merely parsed. A reviewer must never be shown an identity
    // lifted from a malformed or expired package that would then be rejected at
    // add time - or worse, be talked into approving one whose signature does not
    // actually check out.
    let key_package = kp_in
        .validate(mls.provider.crypto(), ProtocolVersion::Mls10)
        .map_err(map_mls_error)?;

    let leaf = key_package.leaf_node();
    let identity = BasicCredential::try_from(leaf.credential().clone())
        .map(|bc| String::from_utf8_lossy(bc.identity()).into_owned())
        .unwrap_or_default();

    let signature_key = leaf.signature_key().as_slice().to_vec();

    Ok(MlsKeyPackageInfo {
        identity,
        signature_public_key: B64.encode(&signature_key),
        signature_key_fingerprint: format_fingerprint(&signature_key),
        key_package_hash: Sha256::digest(&kp_bytes)
            .iter()
            .map(|b| format!("{:02x}", b))
            .collect(),
    })
}

pub fn get_members(mls: &MlsState, group_id_b64: &str) -> Result<Vec<MlsMemberInfo>, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let group = mls
        .groups
        .get(&group_id_bytes)
        .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
    Ok(group_members(group))
}

pub fn get_group_info(mls: &MlsState, group_id_b64: &str) -> Result<MlsGroupInfo, String> {
    let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
    let group = mls
        .groups
        .get(&group_id_bytes)
        .ok_or_else(|| "GroupNotFound: group not found".to_string())?;
    Ok(build_group_info(group))
}

/// Points the engine at `<dir>/mls_state.json` and restores whatever is there.
///
/// Returns `true` when state was restored, `false` when starting fresh. The
/// path is passed in rather than discovered: Flutter owns the app's directory
/// layout via `path_provider`, and the Rust side guessing at it would disagree
/// with wherever the rest of the app stores things.
///
/// `read_only` loads the state but leaves the engine with nowhere to save,
/// which is what an iOS notification-service extension needs. The extension is
/// a *separate process* from the app: it would load state at one moment and
/// write it back at another, and anything the app committed in between - a new
/// group, a merged commit - would be silently overwritten by the older copy.
/// Decrypting one notification is not worth that risk, and the plaintext it
/// produces is kept in the message cache anyway, so nothing is lost by throwing
/// the advanced ratchet away.
pub fn init_storage(mls: &mut MlsState, dir: &str, read_only: bool) -> Result<bool, String> {
    let dir_path = PathBuf::from(dir);
    std::fs::create_dir_all(&dir_path).map_err(|e| e.to_string())?;
    let state_path = dir_path.join("mls_state.json");

    // Already pointing here. A second Dart isolate in the same process - which is
    // exactly what Android's FCM background handler is - re-initialises on every
    // push, and re-reading the file over live state would drop anything the main
    // isolate has in memory but has not yet saved.
    if !read_only && mls.state_path.as_deref() == Some(state_path.as_path()) {
        return Ok(state_path.exists());
    }

    // Left unset until the load succeeds when read-only, so a failure part-way
    // cannot leave the extension able to write.
    mls.state_path = if read_only { None } else { Some(state_path.clone()) };

    if !state_path.exists() {
        return Ok(false);
    }

    let json = std::fs::read(&state_path).map_err(|e| e.to_string())?;
    let persisted: PersistedMlsState = serde_json::from_slice(&json).map_err(|e| e.to_string())?;

    {
        let mut values = mls.provider.storage().values.write().unwrap();
        for (k_b64, v_b64) in &persisted.storage {
            let k = B64.decode(k_b64).map_err(|e| e.to_string())?;
            let v = B64.decode(v_b64).map_err(|e| e.to_string())?;
            values.insert(k, v);
        }
    }

    for group_id_b64 in &persisted.group_ids {
        let group_id_bytes = B64.decode(group_id_b64).map_err(|e| e.to_string())?;
        let group_id = GroupId::from_slice(&group_id_bytes);
        match MlsGroup::load(mls.provider.storage(), &group_id) {
            Ok(Some(group)) => {
                mls.groups.insert(group_id_bytes, group);
            }
            Ok(None) => {
                return Err(format!(
                    "MlsError: group {} is listed in state but its data is missing from storage - state may be corrupted",
                    group_id_b64
                ));
            }
            Err(e) => {
                return Err(format!(
                    "MlsError: failed to load group {} from storage: {}",
                    group_id_b64, e
                ));
            }
        }
    }

    Ok(true)
}

pub fn clear_storage(mls: &mut MlsState) -> Result<(), String> {
    if let Some(path) = &mls.state_path {
        if path.exists() {
            std::fs::remove_file(path)
                .map_err(|e| format!("MlsError: failed to remove state file: {}", e))?;
        }
    }
    mls.groups.clear();
    mls.pending_messages.clear();
    mls.provider.storage().values.write().unwrap().clear();
    Ok(())
}

pub fn export_state(mls: &MlsState, encryption_key_b64: &str) -> Result<String, String> {
    let persisted = mls.to_persisted();
    let json = serde_json::to_vec(&persisted).map_err(|e| e.to_string())?;
    let key_bytes = B64.decode(encryption_key_b64).map_err(|e| e.to_string())?;
    let encrypted = encrypt_blob(&json, &key_bytes)?;
    Ok(B64.encode(&encrypted))
}

pub fn import_state(
    mls: &mut MlsState,
    encrypted_b64: &str,
    encryption_key_b64: &str,
) -> Result<(), String> {
    let encrypted = B64.decode(encrypted_b64).map_err(|e| e.to_string())?;
    let key_bytes = B64.decode(encryption_key_b64).map_err(|e| e.to_string())?;
    let json = decrypt_blob(&encrypted, &key_bytes)?;
    let persisted: PersistedMlsState = serde_json::from_slice(&json).map_err(|e| e.to_string())?;
    let decoded_storage: Vec<(Vec<u8>, Vec<u8>)> = persisted
        .storage
        .iter()
        .map(|(k, v)| {
            let k = B64.decode(k).map_err(|e| e.to_string())?;
            let v = B64.decode(v).map_err(|e| e.to_string())?;
            Ok((k, v))
        })
        .collect::<Result<_, String>>()?;
    let decoded_group_ids: Vec<Vec<u8>> = persisted
        .group_ids
        .iter()
        .map(|g| B64.decode(g).map_err(|e| e.to_string()))
        .collect::<Result<_, String>>()?;
    mls.groups.clear();
    mls.pending_messages.clear();
    {
        let mut values = mls.provider.storage().values.write().unwrap();
        values.clear();
        for (k, v) in decoded_storage {
            values.insert(k, v);
        }
    }
    for group_id_bytes in decoded_group_ids {
        let group_id = GroupId::from_slice(&group_id_bytes);
        if let Ok(Some(group)) = MlsGroup::load(mls.provider.storage(), &group_id) {
            mls.groups.insert(group_id_bytes, group);
        }
    }
    mls.save_to_disk()
        .map_err(|e| format!("MlsError: failed to persist state: {}", e))?;
    Ok(())
}
