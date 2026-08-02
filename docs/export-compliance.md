# Export compliance

Venta ships its own cryptography, so it is **not** covered by Apple's encryption
exemptions. This is the paperwork that makes that fine, and where to do it.

Nothing here is restricted-grade or needs anyone's permission, and there is no
application to file. What remains is one annual email.

## Why we are not exempt

The exemptions cover encryption you don't ship: HTTPS/TLS through the OS,
`CryptoKit`, Keychain, encryption used only for authentication, and DRM. Two
things in this app fall outside that:

- `packages/venta_mls` statically links OpenMLS (RFC 9420) for end-to-end
  message encryption.
- `WebRTC.framework` carries BoringSSL for DTLS-SRTP on calls — true since
  before MLS existed.

Everything both use is **standard published cryptography** — HPKE (RFC 9180),
X25519, Ed25519, AES-GCM, ChaCha20-Poly1305, HKDF-SHA256. That matters: standard
algorithms mean self-classification, not a BIS classification request.

Classification: **ECCN 5D992.c** (mass market), authorization
**§740.17(b)(1)**.

## There is no encryption registration. Do not go looking for one.

Older guidance — including most of what a search turns up — tells you to file an
encryption registration in BIS's SNAP-R portal and receive an ERN (`R#####`).
**That requirement was deleted by the September 2016 rule**, which folded the
registration questions into the annual self-classification report. There is no
"Encryption Registration" work item type in SNAP-R because there is no such
filing.

A SNAP-R account is needed only for a formal classification request (CCATS) or a
licence application. Neither is on our path — 5D992.c mass market items need no
licence, which is the whole point. If you find yourself on a form asking for an
EIN, or asking whether to mark Export in Block 5, you are on a licence
application and in the wrong place.

## 1. Info.plist — done

`ios/Runner/Info.plist` carries `ITSAppUsesNonExemptEncryption` = **`true`**,
with **no** `ITSEncryptionExportComplianceCode`. That combination stops App
Store Connect asking the questionnaire on every upload.

It said `false` until 2026-08-01 — a false declaration, not a clever trick —
then was omitted entirely for 1.0.55/1.0.56, which is why every one of those
uploads had to be answered by hand.

**Why no compliance code is needed.** Apple's reference table maps our case to
exactly one document:

| Encryption | Document |
|---|---|
| Only Apple OS crypto | none |
| **Industry standard algorithm, not provided by the Apple OS** | **French encryption declaration¹** |
| Proprietary algorithms | CCATS **and** French declaration¹ |

> ¹ French encryption declaration form is only required if you're distributing
> your app on the App Store in France.

Every primitive here is published — HPKE, X25519, Ed25519, AES-GCM,
ChaCha20-Poly1305, HKDF — so we are row two, not row three, and CCATS does not
apply. Row two's only document is France-gated, and Venta is not distributed in
France. No document, therefore no code, therefore a bare `true` is complete.

Source: <https://developer.apple.com/help/app-store-connect/reference/export-compliance-documentation-for-encryption>

**This is load-bearing on App Store availability.** A bare `true` was tried on
2026-08-01 and altool rejected it:

```
[altool] Invalid Export Compliance Code. The export compliance key value []
in the app's Info.plist doesn't match the key value of the app's export
compliance documentation. (90592)
```

The likeliest cause is that availability still included France — the default is
every territory — which makes the declaration mandatory and the code with it.

**So if France is ever added under Pricing and Availability**, this key stops
being sufficient. Then either file the French declaration and pin the returned
code beside the `true`, or drop the key and go back to answering per build.
Never resolve a 90592 by flipping this to `false`.

## 2. Annual self-classification report

The only recurring obligation. Due **1 February**, covering exports in the
previous calendar year (1 Jan – 31 Dec). Our first one covers 2026 and is due
**1 February 2027**.

- **CSV only.** The regulation is explicit that no other format is accepted.
- Emailed as an attachment to BIS and to the ENC Encryption Request Coordinator
  at NSA. Take the two addresses from
  <https://www.bis.gov/learn-support/encryption-controls/annual-self-classification>
  rather than from here — BIS moved from `bis.doc.gov` to `bis.gov` and the
  published addresses are the authority.
- Twelve columns: PRODUCT NAME, MODEL NUMBER, MANUFACTURER, ECCN,
  AUTHORIZATION TYPE, ITEM TYPE, SUBMITTER NAME, TELEPHONE NUMBER, E-MAIL
  ADDRESS, MAILING ADDRESS, NON-U.S. COMPONENTS, NON-U.S. MANUFACTURING
  LOCATIONS.

Our row: Venta / (build number) / AlpineBits / `5D992.c` / `740.17(b)(1)` /
mass market messaging application for iOS and Android — MLS (RFC 9420)
end-to-end message encryption and DTLS-SRTP for calls, standard algorithms
only. Non-US components: OpenMLS and BoringSSL. Non-US manufacturing:
Switzerland.

Two escape hatches worth knowing:

- **No exports in the calendar year → no report at all.**
- **Nothing changed since last year → an email saying so** (or a resend of the
  previous report) is sufficient. No need to regenerate it.

## 3. App Store Connect questionnaire

App Store Connect → the app → **TestFlight** (or **Distribution**) → the build →
**Manage** next to Export Compliance. The flow:

| Question | Answer |
| --- | --- |
| Does your app use encryption? | Yes |
| Does it qualify for the Category 5 Part 2 exemptions? | No |
| Proprietary or non-standard algorithms? | No |
| Year-end self-classification report submitted? | Not yet due — first is 1 Feb 2027 |
| Available in France? | Answer honestly; Apple prompts if anything is needed |

The resulting code is what goes in `ITSEncryptionExportComplianceCode`.

## Two things worth knowing

**We may not be subject to the EAR at all.** `AlpineBits-ch/venta-mobile` is a
public repository. Under §740.13(e), publicly available encryption *source code*
— and per §734.7(b) the object code compiled from it — is not subject to the EAR
once a notification email with the repo URL goes to BIS and NSA. That would
replace even the annual report. Two catches: it binds compliance to the repo
staying public, and "the entire shipped App Store binary is publicly available
source" is a boundary claim worth a lawyer's signature. Raise it with counsel;
until then the 5D992.c path above is valid either way.

**A shortcut that doesn't apply to us.** Distribution limited to the US and
Canada is exempt from the report entirely. Venta ships to the EU, so it doesn't
help — but re-check if distribution ever narrows.

**Being Swiss doesn't take us out of the EAR.** Distribution runs through
Apple's US infrastructure, which counts as export from the US. Separately, EU/CH
dual-use rules (Regulation 2021/821, Annex I `5D002`, and the mass market note
that lands standard crypto in `5D992`) generally require no licence for a mass
market app — worth confirming with counsel rather than assuming.
