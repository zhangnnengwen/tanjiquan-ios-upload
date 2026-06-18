# Tanjiquan iOS Upload

This repository uploads the HBuilderX-generated IPA to App Store Connect from a macOS CI runner.

The IPA is committed only in encrypted form. The plaintext IPA, `.p8` private key, and generated API key JSON files must never be committed.

## Recommended: Codemagic

Use Codemagic when GitHub Actions is blocked by billing.

1. Sign in to Codemagic.
2. Add this GitHub repository as an app.
3. Open the app settings and go to `Environment variables`.
4. Add these variables into a group named `appstore_credentials`.
5. Mark every sensitive value as secret.

- `ASC_KEY_ID`: `Q4SMAPYNPY`
- `ASC_ISSUER_ID`: `f17b826e-39c5-48e8-a2ba-f8f2f6f04396`
- `ASC_PRIVATE_KEY`: the full contents of `AuthKey_Q4SMAPYNPY.p8`, including the `BEGIN PRIVATE KEY` and `END PRIVATE KEY` lines
- `IPA_DECRYPT_PASSWORD`: the password used to decrypt `ipa/__UNI__15CD4B6_0618111726.ipa.enc`

Then start workflow `Upload iOS IPA to App Store Connect` from Codemagic.

## GitHub Actions Backup

The `.github/workflows/upload-ios.yml` workflow does the same upload on GitHub Actions. Use it only if the GitHub account can start macOS runners.

Required GitHub repository secrets:

- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `ASC_PRIVATE_KEY`
- `IPA_DECRYPT_PASSWORD`

## Upload Behavior

Both CI workflows decrypt `ipa/__UNI__15CD4B6_0618111726.ipa.enc` on a macOS runner and upload it for bundle ID `com.aihirehumans.tanjiquan`.

## Update IPA Later

Set `IPA_DECRYPT_PASSWORD` locally, encrypt the new IPA, commit the `.ipa.enc` file, and push.

```powershell
$env:IPA_DECRYPT_PASSWORD = "the same password stored in GitHub Secrets"
& "C:\Ruby33-x64\bin\ruby.exe" scripts\encrypt_ipa.rb "C:\path\YourApp.ipa" "ipa\YourApp.ipa.enc"
```

Then update `IPA_ENC_PATH` and `IPA_PATH` in `codemagic.yaml` and `.github/workflows/upload-ios.yml` if the filename changes.
