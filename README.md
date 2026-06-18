# Tanjiquan iOS Upload

This repository uploads the HBuilderX-generated IPA to App Store Connect using GitHub Actions on macOS.

The IPA is committed only in encrypted form so the repository can be public and use free GitHub-hosted runners.

## Required GitHub Secrets

In the GitHub repository, open `Settings -> Secrets and variables -> Actions -> New repository secret` and add:

- `ASC_KEY_ID`: `Q4SMAPYNPY`
- `ASC_ISSUER_ID`: `f17b826e-39c5-48e8-a2ba-f8f2f6f04396`
- `ASC_PRIVATE_KEY`: the full contents of `AuthKey_Q4SMAPYNPY.p8`, including the `BEGIN PRIVATE KEY` and `END PRIVATE KEY` lines
- `IPA_DECRYPT_PASSWORD`: the password used to decrypt `ipa/__UNI__15CD4B6_0618111726.ipa.enc`

Do not commit `.p8`, API key JSON files, plaintext `.ipa` files, or Apple account passwords.

## Run Upload

After pushing this repository to GitHub:

1. Open the repository on GitHub.
2. Go to `Actions`.
3. Select `Upload iOS IPA`.
4. Click `Run workflow`.

The workflow decrypts `ipa/__UNI__15CD4B6_0618111726.ipa.enc` on the macOS runner and uploads it for bundle ID `com.aihirehumans.tanjiquan`.

## Update IPA Later

Set `IPA_DECRYPT_PASSWORD` locally, encrypt the new IPA, commit the `.ipa.enc` file, and push.

```powershell
$env:IPA_DECRYPT_PASSWORD = "the same password stored in GitHub Secrets"
& "C:\Ruby33-x64\bin\ruby.exe" scripts\encrypt_ipa.rb "C:\path\YourApp.ipa" "ipa\YourApp.ipa.enc"
```

Then update `IPA_ENC_PATH` and `IPA_PATH` in `.github/workflows/upload-ios.yml` if the filename changes.
