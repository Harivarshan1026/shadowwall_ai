# Google Play Store Zero-Rejection Submission Guide
## ShadowWall AI (`com.shadowwall.ai`)

This guide contains the exact forms, answers, and requirements needed to submit ShadowWall AI to Google Play Console with a **0% rejection rate**.

---

## 1. Release Keystore & App Signing Setup

Google Play Console requires an **Android App Bundle (`.aab`)** signed with an official upload certificate (NOT debug keys).

### A. Local Keystore Generation
Run this command in PowerShell or terminal inside your project directory (requires Java `keytool`):
```bash
keytool -genkeypair -v -keystore android/app/upload-keystore.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass "YourStrongPasswordHere" -keypass "YourStrongPasswordHere" \
  -dname "CN=ShadowWall AI, OU=Mobile Security, O=ShadowWall, L=City, ST=State, C=US"
```

### B. Create `android/key.properties`
Create `android/key.properties` (this file is already in `.gitignore` so it will never be leaked):
```properties
keyAlias=upload
keyPassword=YourStrongPasswordHere
storeFile=../app/upload-keystore.jks
storePassword=YourStrongPasswordHere
```

### C. Build Release AAB
```bash
flutter build appbundle --release
```
Your store-ready App Bundle will be located at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 2. Sensitive Permission Declaration: `QUERY_ALL_PACKAGES`

Google Play strictly enforces the **Package Visibility Policy**. Since ShadowWall AI includes **Permission Doctor** and **Device Security / Antivirus Auditing**, it falls under the permitted exception: **"Antivirus / Security Apps"**.

When filling out the declaration form in Google Play Console (Policy > App content > Sensitive app permissions):

### Question: Core purpose of your app
> **Select**: Antivirus / Device Security

### Question: Why does your app require broad package visibility?
> **Exact Response to Enter**:
> "ShadowWall AI is an intelligent mobile cyber safety and on-device antivirus companion. Its core features—'Permission Doctor', 'Device Security', and 'Background Guard'—actively audit all installed applications on the device to detect privilege escalation, unauthorized overlay permissions (SYSTEM_ALERT_WINDOW), dangerous accessibility service abuses (BIND_ACCESSIBILITY_SERVICE), and covert SMS/Call-log spy software.
>
> Without QUERY_ALL_PACKAGES, ShadowWall AI cannot inspect installed third-party packages to identify malicious trojans, spyware, or apps requesting excessive dangerous permissions. This inspection is performed entirely on-device to compute the user's real-time Device Safety Score and provide actionable security remediation."

### Video Demonstration Requirement (Crucial)
Google Play requires a short (30-60 second) unlisted YouTube video showing the feature in action:
1. Open the app on an Android device or emulator.
2. Navigate to **Permission Doctor** / **Device Security**.
3. Tap **Start Device Audit** / **Scan Installed Apps**.
4. Show the app scanning installed packages and displaying high-risk permissions detected on third-party apps.
5. Paste the unlisted YouTube link in the declaration form.

---

## 3. Data Safety Form Checklist

Google Play requires accurate disclosures under the **Data Safety** section. Fill out the questionnaire as follows:

| Data Category | Collected? | Shared? | Purpose | Ephemeral? | Encrypted in Transit? |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Personal Info (Email, Name)** | Yes | No | Account management (Firebase Auth) | No | Yes (HTTPS/TLS) |
| **App Info & Performance (Diagnostics/Crash logs)** | Yes | No | Analytics & bug fixing | No | Yes (HTTPS/TLS) |
| **Device or other IDs** | Yes | No | Push notifications & fraud prevention | No | Yes (HTTPS/TLS) |
| **Photos and Videos** | No | No | Processed **strictly on-device** via ML Kit OCR; never stored on remote servers. | Yes | N/A |
| **Files and Docs (APKs inspected)** | No | No | Inspected **strictly on-device** in memory; never uploaded. | Yes | N/A |
| **Financial / Health / Location data** | No | No | Not collected. | N/A | N/A |

### Key Questions:
* **Is data encrypted in transit?** -> **Yes** (All cloud traffic uses TLS 1.3 / HTTPS).
* **Do you provide a way for users to request deletion of their data?** -> **Yes** (Users can delete their account in Settings > Delete Account, which purges their Firebase user record).

---

## 4. App Access & Reviewer Credentials

Under **App Content > App Access**:
Google Play reviewers must be able to log into and test all features without encountering a paywall or login block.

* Choose **"All or some functionality is restricted"**
* Add testing instructions:
  * **Test Account Email**: `playstore.reviewer@shadowwall.ai` (create this user in your Firebase Auth Console)
  * **Test Password**: `ReviewerSafePass2026!`
  * **Instructions**: "Sign in with the provided test email and password to access the complete dashboard, scanner tools, and community feed."

---

## 5. Google Play Closed Testing (20-Tester Requirement)

For all personal developer accounts created after **November 13, 2023**:
1. You cannot publish directly to Production.
2. You must publish your `.aab` to the **Closed Testing track**.
3. Recruit at least **20 testers** who opt-in via Google Play on their Android devices.
4. Keep the test running continuously for **14 days**.
5. Ensure testers open the app periodically and leave feedback.
6. After 14 days, the **"Apply for Production"** button will unlock in your Play Console.

---

## 6. Store Listing Assets Checklist

Before submitting, upload the following graphic assets to the Main Store Listing:

- [ ] **App Name**: ShadowWall AI – Mobile Cyber Guard
- [ ] **Short Description** (up to 80 chars): Intelligent AI cyber companion for malware auditing, phishing & threat defense.
- [ ] **App Icon**: 512 x 512 px (32-bit PNG with alpha).
- [ ] **Feature Graphic**: 1024 x 500 px (JPG or PNG).
- [ ] **Phone Screenshots**: Minimum of 4 screenshots (1080 x 1920 px or 1080 x 2400 px, 16:9 or 9:16 aspect ratio).
- [ ] **Privacy Policy URL**: Link to `docs/PRIVACY_POLICY.md` hosted on GitHub Pages or a public website.
