# GitHub Actions iOS Upload Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal private GitHub repository that uploads the HBuilderX IPA to App Store Connect from a macOS GitHub Actions runner.

**Architecture:** Store the IPA in the repository and keep Apple API credentials in GitHub Actions secrets. The workflow creates a temporary `api_key.json` on the runner, installs fastlane, and uploads the IPA with `pilot`.

**Tech Stack:** GitHub Actions, macOS runner, RubyGems, fastlane, App Store Connect API key.

---

### Task 1: Repository Files

**Files:**
- Create: `.github/workflows/upload-ios.yml`
- Create: `.gitignore`
- Create: `README.md`
- Copy: `ipa/__UNI__15CD4B6_0618111726.ipa`

- [x] **Step 1: Create repository directories**

Run:

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\20859\Desktop\tanjiquan-ios-upload\.github\workflows"
New-Item -ItemType Directory -Force -Path "C:\Users\20859\Desktop\tanjiquan-ios-upload\ipa"
```

- [x] **Step 2: Copy the IPA**

Run:

```powershell
Copy-Item "C:\Users\20859\Desktop\app\__UNI__15CD4B6_0618111726.ipa" "C:\Users\20859\Desktop\tanjiquan-ios-upload\ipa\__UNI__15CD4B6_0618111726.ipa"
```

- [x] **Step 3: Add workflow**

The workflow uses `workflow_dispatch`, installs fastlane, writes `api_key.json` from secrets, and runs `fastlane pilot upload`.

- [x] **Step 4: Add docs and ignore rules**

The README documents the three required GitHub secrets and the manual workflow run steps. The `.gitignore` blocks `.p8` and API key JSON files.

### Task 2: Verification

**Files:**
- Verify: `.github/workflows/upload-ios.yml`
- Verify: `README.md`
- Verify: `.gitignore`

- [ ] **Step 1: Initialize git**

Run:

```powershell
git init
git add .
git status --short
```

Expected: workflow, README, `.gitignore`, plan, and IPA are staged. No `.p8` or API key JSON is staged.

- [ ] **Step 2: Commit**

Run:

```powershell
git commit -m "chore: add ios upload workflow"
```

Expected: commit succeeds.

- [ ] **Step 3: Push to a private GitHub repository**

Create an empty private repository on GitHub named `tanjiquan-ios-upload`, then run:

```powershell
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/tanjiquan-ios-upload.git
git push -u origin main
```

Expected: repository files appear on GitHub.

- [ ] **Step 4: Add GitHub secrets**

Add `ASC_KEY_ID`, `ASC_ISSUER_ID`, and `ASC_PRIVATE_KEY` in GitHub repository Actions secrets.

- [ ] **Step 5: Run workflow**

Open `Actions -> Upload iOS IPA -> Run workflow`.

Expected: GitHub Actions runs on macOS and uploads the IPA to App Store Connect.
