# Upload Helper Tool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Windows helper that encrypts a new HBuilderX IPA, commits it, and pushes it for Codemagic upload.

**Architecture:** Add a PowerShell script for the actual workflow and a `.bat` launcher for double-click use. Add a lightweight PowerShell test script that verifies required safety behavior and paths are present without needing a real IPA upload.

**Tech Stack:** PowerShell 5+, Windows batch, Ruby encryption script already in the repository, Git.

---

### Task 1: Add Verification For Upload Helper

**Files:**
- Create: `scripts/test_upload_helper.ps1`

- [ ] **Step 1: Write the failing test**

Create a PowerShell test script that expects `upload-new-ipa.ps1` and `upload-new-ipa.bat` to exist, and checks the PowerShell script contains the fixed encrypted IPA output path, secure password prompt, Ruby encryption call, git commit, and git push.

- [ ] **Step 2: Run test to verify it fails**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test_upload_helper.ps1`

Expected: FAIL because the helper files do not exist yet.

### Task 2: Add Windows Upload Helper

**Files:**
- Create: `upload-new-ipa.ps1`
- Create: `upload-new-ipa.bat`
- Modify: `README.md`

- [ ] **Step 1: Implement helper scripts**

Create `upload-new-ipa.ps1` to accept an optional IPA path, prompt if absent, prompt securely for `IPA_DECRYPT_PASSWORD` if it is not already in the environment, run `scripts/encrypt_ipa.rb`, commit `ipa/__UNI__15CD4B6_0618111726.ipa.enc`, and push `main`.

Create `upload-new-ipa.bat` to launch PowerShell from the repository directory.

- [ ] **Step 2: Update documentation**

Add a short “One-click update” section to `README.md` explaining how to run `upload-new-ipa.bat`.

- [ ] **Step 3: Run verification**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test_upload_helper.ps1`

Expected: PASS.

- [ ] **Step 4: Verify repository safety**

Run: `git ls-files | Select-String -Pattern '\.ipa$|\.p8$|api_key|bad-backup|invalid-generated'`

Expected: no output.

- [ ] **Step 5: Commit and push**

Run:

```powershell
git add upload-new-ipa.ps1 upload-new-ipa.bat scripts/test_upload_helper.ps1 README.md docs/superpowers/plans/2026-06-18-upload-helper-tool.md
git commit -m "feat: add windows ipa upload helper"
git push origin main
```
