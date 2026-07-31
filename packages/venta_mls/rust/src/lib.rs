//! C ABI for the MLS engine.
//!
//! One entry point taking `(command, args-json)` and returning `{"ok": …}` or
//! `{"error": "Kind: message"}`, rather than a symbol per operation.
//!
//! Alpine reaches this same logic through Tauri's IPC, which already gives it
//! JSON in and JSON out. Matching that shape means the Dart layer is a
//! transliteration of `mls.service.ts` instead of a reinterpretation of it, and
//! adding an operation later touches two match arms rather than a hand-written
//! FFI signature, a Dart typedef, and a lookup.

mod mls;
#[cfg(test)]
mod tests;

use std::ffi::{c_char, CStr, CString};
use std::panic::{catch_unwind, AssertUnwindSafe};

use serde::Deserialize;
use serde_json::{json, Value};

/// Every field any command needs. One flat optional bag rather than a variant
/// per command: the alternative is ~20 tiny structs whose only job is to be
/// deserialized once, and a missing field surfaces identically either way.
#[derive(Deserialize, Default)]
#[serde(rename_all = "camelCase", default)]
struct Args {
    signing_public_key_b64: Option<String>,
    signing_private_key_b64: Option<String>,
    identity: Option<String>,
    key_handle: Option<String>,
    count: Option<u32>,
    group_id_b64: Option<String>,
    key_packages_b64: Option<Vec<String>>,
    key_package_b64: Option<String>,
    welcome_b64: Option<String>,
    group_info_b64: Option<String>,
    message_b64: Option<String>,
    plaintext_b64: Option<String>,
    leaf_indices: Option<Vec<u32>>,
    dir: Option<String>,
    read_only: Option<bool>,
    encryption_key_b64: Option<String>,
    encrypted_b64: Option<String>,
}

impl Args {
    fn need(field: Option<String>, name: &str) -> Result<String, String> {
        field.ok_or_else(|| format!("MlsError: missing required argument '{}'", name))
    }
}

fn encode<T: serde::Serialize>(value: T) -> Result<Value, String> {
    serde_json::to_value(value).map_err(|e| format!("MlsError: {}", e))
}

fn dispatch(command: &str, args: Args) -> Result<Value, String> {
    mls::with_state(|state| match command {
        "loadSigningKey" => {
            let handle = mls::load_signing_key(
                state,
                &Args::need(args.signing_public_key_b64, "signingPublicKeyB64")?,
                &Args::need(args.signing_private_key_b64, "signingPrivateKeyB64")?,
                Args::need(args.identity, "identity")?,
            )?;
            Ok(json!(handle))
        }
        "unloadSigningKey" => {
            mls::unload_signing_key(state, &Args::need(args.key_handle, "keyHandle")?)?;
            Ok(Value::Null)
        }
        "generateKeyPackages" => {
            let batch = mls::generate_key_packages(
                state,
                Args::need(args.identity, "identity")?,
                args.count.unwrap_or(0),
            )?;
            encode(batch)
        }
        "generateKeyPackagesWithHandle" => {
            let packages = mls::generate_key_packages_with_handle(
                state,
                &Args::need(args.key_handle, "keyHandle")?,
                args.count.unwrap_or(0),
            )?;
            encode(packages)
        }
        "createGroup" => {
            let info = mls::create_group(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
            )?;
            encode(info)
        }
        "addMembers" => {
            let out = mls::add_members(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
                &args.key_packages_b64.unwrap_or_default(),
            )?;
            encode(out)
        }
        "joinGroup" => {
            let info = mls::join_group(
                state,
                &Args::need(args.welcome_b64, "welcomeB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
            )?;
            encode(info)
        }
        "leaveGroup" => {
            let out = mls::leave_group(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
            )?;
            encode(out)
        }
        "commitPendingProposals" => {
            let out = mls::commit_pending_proposals(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
            )?;
            encode(out)
        }
        "mergePendingCommit" => {
            let epoch =
                mls::merge_pending_commit(state, &Args::need(args.group_id_b64, "groupIdB64")?)?;
            Ok(json!(epoch))
        }
        "clearPendingCommit" => {
            mls::clear_pending_commit(state, &Args::need(args.group_id_b64, "groupIdB64")?)?;
            Ok(Value::Null)
        }
        "exportGroupInfo" => {
            let info = mls::export_group_info(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
            )?;
            Ok(json!(info))
        }
        "rejoinGroup" => {
            let out = mls::rejoin_group(
                state,
                &Args::need(args.group_info_b64, "groupInfoB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
            )?;
            encode(out)
        }
        "deleteGroup" => {
            mls::delete_group(state, &Args::need(args.group_id_b64, "groupIdB64")?)?;
            Ok(Value::Null)
        }
        "sendMessage" => {
            let out = mls::send_message(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
                &Args::need(args.plaintext_b64, "plaintextB64")?,
            )?;
            encode(out)
        }
        "processMessage" => {
            let out = mls::process_message(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.message_b64, "messageB64")?,
            )?;
            encode(out)
        }
        "removeMembers" => {
            let out = mls::remove_members(
                state,
                &Args::need(args.group_id_b64, "groupIdB64")?,
                &Args::need(args.key_handle, "keyHandle")?,
                &args.leaf_indices.unwrap_or_default(),
            )?;
            encode(out)
        }
        "fingerprintForSignatureKey" => {
            let fingerprint = mls::fingerprint_for_signature_key(&Args::need(
                args.signing_public_key_b64,
                "signingPublicKeyB64",
            )?)?;
            Ok(json!(fingerprint))
        }
        "inspectKeyPackage" => {
            let info = mls::inspect_key_package(
                state,
                &Args::need(args.key_package_b64, "keyPackageB64")?,
            )?;
            encode(info)
        }
        "getMembers" => {
            let members = mls::get_members(state, &Args::need(args.group_id_b64, "groupIdB64")?)?;
            encode(members)
        }
        "getGroupInfo" => {
            let info = mls::get_group_info(state, &Args::need(args.group_id_b64, "groupIdB64")?)?;
            encode(info)
        }
        "initStorage" => {
            let restored = mls::init_storage(
                state,
                &Args::need(args.dir, "dir")?,
                args.read_only.unwrap_or(false),
            )?;
            Ok(json!(restored))
        }
        "clearStorage" => {
            mls::clear_storage(state)?;
            Ok(Value::Null)
        }
        "exportState" => {
            let blob = mls::export_state(
                state,
                &Args::need(args.encryption_key_b64, "encryptionKeyB64")?,
            )?;
            Ok(json!(blob))
        }
        "importState" => {
            mls::import_state(
                state,
                &Args::need(args.encrypted_b64, "encryptedB64")?,
                &Args::need(args.encryption_key_b64, "encryptionKeyB64")?,
            )?;
            Ok(Value::Null)
        }
        other => Err(format!("MlsError: unknown command '{}'", other)),
    })
}

/// Runs one command. Never returns null except on allocation failure, and never
/// unwinds across the FFI boundary - a panic comes back as an `MlsError`.
///
/// # Safety
/// Both arguments must be valid NUL-terminated UTF-8. The returned pointer is
/// owned by the caller and must be released with [`venta_mls_free`].
#[no_mangle]
pub unsafe extern "C" fn venta_mls_call(
    command: *const c_char,
    args_json: *const c_char,
) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| {
        if command.is_null() {
            return json!({"error": "MlsError: null command"});
        }
        let command = match CStr::from_ptr(command).to_str() {
            Ok(s) => s.to_owned(),
            Err(e) => return json!({ "error": format!("MlsError: command is not UTF-8: {}", e) }),
        };
        let args_str = if args_json.is_null() {
            "{}".to_owned()
        } else {
            match CStr::from_ptr(args_json).to_str() {
                Ok("") => "{}".to_owned(),
                Ok(s) => s.to_owned(),
                Err(e) => {
                    return json!({ "error": format!("MlsError: args are not UTF-8: {}", e) })
                }
            }
        };
        let args: Args = match serde_json::from_str(&args_str) {
            Ok(a) => a,
            Err(e) => return json!({ "error": format!("MlsError: bad args JSON: {}", e) }),
        };
        match dispatch(&command, args) {
            Ok(value) => json!({ "ok": value }),
            Err(message) => json!({ "error": message }),
        }
    }));

    let payload = match result {
        Ok(value) => value,
        Err(panic) => {
            let detail = panic
                .downcast_ref::<&str>()
                .map(|s| (*s).to_owned())
                .or_else(|| panic.downcast_ref::<String>().cloned())
                .unwrap_or_else(|| "panic with no message".to_owned());
            json!({ "error": format!("MlsError: engine panicked: {}", detail) })
        }
    };

    match CString::new(payload.to_string()) {
        Ok(c) => c.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Releases a string returned by [`venta_mls_call`].
///
/// # Safety
/// `ptr` must be a pointer previously returned by [`venta_mls_call`] and not
/// already freed.
#[no_mangle]
pub unsafe extern "C" fn venta_mls_free(ptr: *mut c_char) {
    if !ptr.is_null() {
        drop(CString::from_raw(ptr));
    }
}

/// Referenced from the iOS side so the linker keeps the symbols above when the
/// crate is linked as a static library. Without a reference from Swift/ObjC,
/// dead-code stripping removes them and `DynamicLibrary.process()` finds
/// nothing at runtime.
#[no_mangle]
pub extern "C" fn venta_mls_dummy_keep_symbols() -> i64 {
    0
}

