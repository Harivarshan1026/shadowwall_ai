# Privacy Policy for ShadowWall AI

**Effective Date:** September 8, 2026  
**Last Updated:** September 8, 2026  
**Developer / Organization:** ShadowWall AI Team (`com.shadowwall.ai`)  
**Contact Email:** support@shadowwall.ai / harivarshan1026@gmail.com

---

## 1. Introduction

ShadowWall AI ("we", "our", or "us") is dedicated to protecting your privacy and security. This Privacy Policy explains how our mobile application collects, uses, processes, and protects your information when you download, install, and use the ShadowWall AI Android application.

ShadowWall AI is designed from the ground up with **Privacy-by-Design** principles. Where possible, threat detection, optical character recognition (OCR), and security auditing are executed **locally on your device**.

---

## 2. Information We Collect and Process

### A. Information You Provide Directly
* **Account Information**: When creating an account, we may collect your email address, display name, and authentication credentials via Firebase Authentication.
* **Threat Submissions & Community Reports**: If you choose to submit a suspicious URL, phone number, or scam report to the Scam Community feed, that data is shared with the community database via Cloud Firestore.
* **Custom API Keys**: If you override default security services by entering your own Google Gemini AI or VirusTotal API keys in the app settings, those keys are stored **exclusively in encrypted local storage on your device** and are never sent to our servers.

### B. Device & Technical Telemetry
* **Installed Application Auditing**: To power the **Permission Doctor** and **Device Security** features, the app inspects package names and permission lists of installed applications on your device. **This audit is performed entirely on-device in real-time memory**. We do not harvest, upload, or sell your installed app list.
* **Network & Wi-Fi Telemetry**: When using **Wi-Fi Guardian**, the app inspects local connection state (SSID, DNS latency, captive portal status, and public IP address) strictly to determine whether the Wi-Fi network is encrypted and secure.
* **Crash Logs & Diagnostics**: Standard crash diagnostics may be collected via Firebase Crashlytics to diagnose defects and improve app stability.

### C. Media, Files & Camera Usage
* **QR Guardian & Screenshot Threat Analyzer**: When you select an image or scan a QR code, images are processed **locally on your device** using Google ML Kit (on-device Barcode Scanning and Text Recognition). Your personal photos are **never uploaded to remote servers**.
* **Secret Locker**: Files, notes, and credentials saved in the Secret Locker are encrypted on-device with AES encryption and protected with biometric authentication. We do not possess the keys to decrypt your personal vault.

---

## 3. Third-Party Services & Cloud Processors

We utilize reputable industry-standard third-party services that adhere to stringent security standards:

* **Google Firebase (Auth, Firestore, Messaging)**: For secure account management and community feed delivery. [Google Privacy Policy](https://policies.google.com/privacy)
* **Google Gemini AI (Google AI Studio)**: For intelligent threat analysis prompts and interactive cyber safety advice. Prompts submitted are processed according to Google Cloud AI terms.
* **Google Safe Browsing API**: For verifying phishing and malicious domain status.
* **VirusTotal API**: For checking file hashes and URL threat intelligence.
* **FreeRASP (Talsec)**: For runtime application self-protection, root detection, and tamper verification.

---

## 4. Permissions Requested & Justification

| Permission | Technical Name | Purpose & Justification |
| :--- | :--- | :--- |
| **Internet Access** | `android.permission.INTERNET` | Required for AI threat queries, safe browsing lookups, and authentication. |
| **Network State** | `android.permission.ACCESS_NETWORK_STATE` | Required by Wi-Fi Guardian to detect connectivity type (cellular vs. Wi-Fi). |
| **Biometric Auth** | `android.permission.USE_BIOMETRIC` | Used by Secret Locker to lock and unlock encrypted files locally. |
| **Notifications** | `android.permission.POST_NOTIFICATIONS` | (Android 13+) Used by Background Guard to alert users of urgent security threats. |
| **Query Packages** | `android.permission.QUERY_ALL_PACKAGES` | (High Risk / Antivirus Policy) Required by Permission Doctor to scan installed apps for malware and high-risk permission abuses. |

---

## 5. Data Retention & Account Deletion

* We retain account information only for as long as your account remains active.
* **Right to Delete (GDPR / CCPA / Google Play Policy)**: You have the unconditional right to delete your account and all associated community submissions at any time. You can request immediate deletion directly inside the app under **Settings > Delete Account**, or by emailing **support@shadowwall.ai**.

---

## 6. Children's Privacy

ShadowWall AI does not knowingly collect personal data from children under 13 (or under 16 in the European Union). If we learn that we have inadvertently collected personal data from a child without parental consent, we will promptly delete it.

---

## 7. Security Safeguards

We implement strict administrative, physical, and technical safeguards:
* All network communication is strictly enforced over **HTTPS (TLS 1.3)**.
* Sensitive vault content is protected with **AES on-device encryption**.
* The application enforces `FLAG_SECURE` to prevent unauthorized background screen capture.

---

## 8. Changes to this Privacy Policy

We may update this Privacy Policy from time to time. Any changes will be posted within the application with an updated "Effective Date". Continued use of the application signifies acceptance of any revisions.

---

## 9. Contact Us

If you have questions, concerns, or requests regarding this Privacy Policy:
* **Email:** support@shadowwall.ai
* **Security Contact:** harivarshan1026@gmail.com
