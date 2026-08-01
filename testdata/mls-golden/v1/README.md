# Cross-client MLS golden vectors, v1

Contract §F. `venta_mls/rust/Cargo.toml` pins `openmls 0.8.1` with the comment *"Bump both together
or neither"*. This directory turns that comment into an assertion.

`fixture.json` is produced by **one** client's Rust engine and checked into **both** repos byte for
byte. Each repo asserts that its own engine consumes the other's output, so a ciphersuite, protocol
version or TLS-codec drift fails a test here instead of surfacing as *"my friend texts me from
desktop and I cannot read it on mobile"*.

## Shape

| Field | Meaning |
|---|---|
| `producedBy` | `alpine` or `venta-mobile` - which engine wrote it |
| `ciphersuite`, `openmls` | what it was produced under; a consumer that differs should fail loudly |
| `groupIdB64` | the group the commit and message belong to |
| `bob.keyPackageB64` | a KeyPackage, for the `inspect`/`validate` path |
| `bob.signingPublicKey` / `signingPrivateKey` | Bob's Ed25519 pair, base64 |
| `bob.engine` | Bob's `PersistedMlsState` **before** joining - holds the private half of his key package, without which the Welcome cannot be opened by anyone |
| `welcomeB64` | Welcome addressed to Bob (Alice's add-Bob commit, epoch 1) |
| `commitB64` | Alice's add-Charlie commit, applicable by Bob once he has joined (epoch 2) |
| `applicationMessageB64` | Alice's application message at epoch 2 |
| `applicationPlaintextB64` | what it must decrypt to |

All base64 is **standard with padding**, matching `base64::engine::general_purpose::STANDARD` in
both engines.

## Consuming it

Restore `bob.engine` into a fresh provider store, load `bob`'s signing key, join from
`welcomeB64` (expect 2 members), apply `commitB64` (expect 1 added member), then decrypt
`applicationMessageB64` and compare against `applicationPlaintextB64`.

Alpine's side is `this_engine_consumes_the_golden_key_package_welcome_commit_and_message` in
`src-tauri/src/crypto/mls.rs`.

## Regenerating

Only when the format changes - a fixture regenerated on every run would have each engine consuming
bytes it had just produced, which proves nothing.

```
cd src-tauri
cargo test --lib -- --ignored generate_golden_fixture
```

Then copy the file into the other repo unchanged and run its consumer test.

## Both directions

`fixture.json` is Alpine's, consumed here by
`this_engine_consumes_alpines_golden_key_package_welcome_commit_and_message` in
`packages/venta_mls/rust/src/tests.rs`.

`fixture-venta-mobile.json` is this engine's, in the identical shape, for Alpine
to add the mirror-image consumer test against. Regenerate with:

```
cargo test --manifest-path packages/venta_mls/rust/Cargo.toml -- --ignored generate_golden_fixture
```

Only when the format changes — see above.
