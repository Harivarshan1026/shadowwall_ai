/// Cyber Defense Academy Learning Provider & Comprehensive Course Database.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = 'Review course concepts for the security rationale.',
  });
}

class LessonEntity {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String attackScenario;
  final List<String> defenseChecklist;
  final String keyTakeaway;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.attackScenario,
    required this.defenseChecklist,
    required this.keyTakeaway,
  });
}

class CourseEntity {
  final String id;
  final String title;
  final String description;
  final String level; // Beginner, Intermediate, Advanced
  final String duration; // e.g. "25 mins"
  final String iconName;
  final List<LessonEntity> lessons;
  final List<QuizQuestion> finalQuiz;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.duration,
    required this.iconName,
    required this.lessons,
    required this.finalQuiz,
  });
}

class LearningState {
  final int totalXp;
  final Map<String, int> completedLessonsPerCourse; // courseId -> number of completed lessons
  final Set<String> completedCourses; // courseIds that have passed the quiz

  const LearningState({
    this.totalXp = 0,
    this.completedLessonsPerCourse = const {},
    this.completedCourses = const {},
  });

  LearningState copyWith({
    int? totalXp,
    Map<String, int>? completedLessonsPerCourse,
    Set<String>? completedCourses,
  }) {
    return LearningState(
      totalXp: totalXp ?? this.totalXp,
      completedLessonsPerCourse: completedLessonsPerCourse ?? this.completedLessonsPerCourse,
      completedCourses: completedCourses ?? this.completedCourses,
    );
  }
}

// ──────────────────────── 8 COMPREHENSIVE COURSES ────────────────────────
final List<CourseEntity> availableCourses = [
  // ── 1. Advanced Phishing Defense ──
  CourseEntity(
    id: 'c1',
    title: 'Advanced Phishing, Smishing & Quishing Defense',
    description: 'Master the technical mechanics of deceptive emails, homograph attacks, QR code payloads, and reverse-proxy MFA bypasses.',
    level: 'Intermediate',
    duration: '35 mins',
    iconName: 'phishing',
    lessons: [
      const LessonEntity(
        id: 'c1_l1',
        title: 'Phishing Mechanics & Psychological Triggers',
        subtitle: 'How cybercriminals bypass human cognitive defenses',
        content: '''Phishing is not merely deceptive email; it is a weaponized exploitation of human cognitive heuristics. Threat actors engineer messages that deliberately trigger acute emotional states—panic, authority deference, greed, or time urgency.

When your brain perceives urgency (e.g., "Your bank account will be terminated in 15 minutes"), cognitive load shifts from the analytical prefrontal cortex to the emotional amygdala. Attackers exploit this cognitive shortcut to prompt immediate credential submission before you can scrutinize the sender's origin headers, SPF/DKIM records, or top-level domain anomalies.''',
        attackScenario: '''Case Study: In 2025, attackers targeted corporate finance teams by sending simulated CEO emails requesting urgent wire transfer approvals during late-night hours. By mimicking signature blocks and deploying lookalike domains, attackers stole \$2.4M before the morning shift verified the request.''',
        defenseChecklist: [
          'Pause immediately whenever a message demands urgent action or payment.',
          'Verify sender email headers beyond the display name (check actual domain in angle brackets).',
          'Enforce strict out-of-band communication (phone call on verified internal number) for all financial or credential requests.',
        ],
        keyTakeaway: 'Urgency is the primary signature of social engineering. Never allow an email or text message to dictate your reaction time.',
      ),
      const LessonEntity(
        id: 'c1_l2',
        title: 'Domain Typosquatting & IDN Homograph Attacks',
        subtitle: 'Decoding visual spoofing in modern URLs',
        content: '''Attackers register lookalike domains using techniques such as:
1. **Typosquatting**: Registering misspellings of popular brands (e.g., `netfIix.com` using a capital `I` instead of `l`, or `paypaI-security.com`).
2. **IDN Homograph Exploits**: Utilizing Internationalized Domain Names where Cyrillic, Greek, or Latin characters look visually identical to standard ASCII (e.g., Cyrillic 'а' `U+0430` vs Latin 'a' `U+0061`). Browsers represent these internally via Punycode (`xn--...`).
3. **Subdomain Masking**: Formatting the URL so the legitimate brand is merely a subdomain (e.g., `https://paypal.com.secure-login-portal.xyz/signin`). Here, the actual domain is `secure-login-portal.xyz`.''',
        attackScenario: '''Victims received an SMS claiming their package was held at customs. The link `https://dhl.com-tracking-status.site/pay` appeared legitimate at first glance, but routed users to an offshore credential harvesting server.''',
        defenseChecklist: [
          'Look for the primary registered domain immediately preceding the first single slash `/`.',
          'Inspect the browser address bar for Punycode indicators (`xn--`).',
          'Always use the ShadowWall AI URL Scanner before tapping unverified links.',
        ],
        keyTakeaway: 'Subdomains can say anything. The domain immediately left of the first single forward slash is the actual server you are connecting to.',
      ),
      const LessonEntity(
        id: 'c1_l3',
        title: 'QR Code Poisoning ("Quishing") & Dynamic Redirects',
        subtitle: 'How physical barcodes hide malicious digital payloads',
        content: '''Quick Response (QR) codes are two-dimensional matrix barcodes that encode arbitrary text or URLs. Because human eyes cannot read optical pixel grids, QR codes naturally blindfold the user.

In Quishing attacks, threat actors:
1. Stick malicious QR stickers over real parking meters, restaurant menus, or transit kiosks.
2. Embed QR codes inside email PDFs to bypass corporate email security gateways (which scan plain text URLs but historically ignored embedded raster images).
3. Use dynamic URL shorteners behind the QR code that rotate landing pages based on victim device user-agents (serving benign pages to security bots and malicious APK droppers to mobile phones).''',
        attackScenario: '''Fraudulent parking meter QR stickers in metropolitan areas redirected drivers to a spoofed municipal payment portal that skimmed credit cards and CVVs without completing parking registration.''',
        defenseChecklist: [
          'Never scan physical QR stickers placed over existing hardware signs.',
          'Use the ShadowWall AI QR Guardian to inspect and sandbox QR destinations before opening them in a browser.',
          'Verify that parking or ticketing domains match the municipality\'s official public URL.',
        ],
        keyTakeaway: 'Never scan naked QR codes in public places without previewing and verifying the destination URL.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'In the URL "https://apple.id.security-verify.net/account", what is the actual destination domain?',
        options: ['apple.id', 'security-verify.net', 'apple.com', 'account'],
        correctAnswerIndex: 1,
        explanation: 'The actual domain is "security-verify.net". "apple.id" is merely an arbitrary subdomain crafted to deceive the user.',
      ),
      const QuizQuestion(
        question: 'Why do attackers embed QR codes inside PDF email attachments?',
        options: ['To speed up download times', 'To bypass text-based automated email gateway filters', 'Because QR codes encrypt the email payload', 'It is required by RFC protocols'],
        correctAnswerIndex: 1,
        explanation: 'Email security scanners historically parsed plaintext HTML links. Embedding links inside QR images bypassed these automated perimeter filters.',
      ),
    ],
  ),

  // ── 2. Mobile Malware & Spyware Anatomy ──
  CourseEntity(
    id: 'c2',
    title: 'Mobile Malware, Spyware & Remote Access Trojans',
    description: 'Anatomy of Android & iOS threats: Accessibility hijacking, malicious overlays, SMS grabbers, and persistence mechanisms.',
    level: 'Advanced',
    duration: '40 mins',
    iconName: 'phone_android',
    lessons: [
      const LessonEntity(
        id: 'c2_l1',
        title: 'Accessibility Service Abuse & Screen Overlays',
        subtitle: 'How rogue apps hijack mobile OS privileges',
        content: '''Android Accessibility Services were engineered to assist users with disabilities by allowing apps to read screen contents, simulate touch inputs, and interact with the UI.

Modern mobile banking trojans (such as Godfather, TeaBot, and GoldPickaxe) trick users into granting Accessibility permissions. Once enabled, the malware can:
1. **Read Entire Screen Text**: Silently extract 2FA codes, unmasked passwords, and chat messages.
2. **Draw Invisible Overlays (`SYSTEM_ALERT_WINDOW`)**: Place a transparent phishing overlay on top of legitimate banking apps to harvest PINs and CVVs.
3. **Simulate User Taps (Automated Transfer Systems - ATS)**: Open your banking app in the background and transfer funds without user confirmation.''',
        attackScenario: '''A fake battery optimizer app requested Accessibility privileges to "save battery." Once granted, it launched an overlay whenever the user opened a cryptocurrency wallet, capturing their seed phrase.''',
        defenseChecklist: [
          'Never grant Accessibility privileges to utility apps, flashlights, or games.',
          'Regularly audit Settings -> Accessibility to ensure only vetted system tools are active.',
          'Run the ShadowWall AI Permission Doctor to identify privilege escalation risks.',
        ],
        keyTakeaway: 'Accessibility permission grants full programmatic control over your phone screen and inputs. Treat it as root-level access.',
      ),
      const LessonEntity(
        id: 'c2_l2',
        title: 'SMS Interception & SIM Swapping Dynamics',
        subtitle: 'The vulnerabilities of SMS-based two-factor authentication',
        content: '''SMS was designed in the 1980s as a plain-text telecom protocol without encryption or cryptographic authentication. Relying on SMS for 2FA introduces severe attack vectors:
1. **SMS Stealer Malware**: Android apps requesting `RECEIVE_SMS` and `READ_SMS` upload your one-time passwords directly to attacker servers.
2. **SIM Swapping**: Scammers socially engineer mobile carrier support reps into transferring your phone number to an attacker-controlled SIM card.
3. **SS7 Network Exploitation**: Sophisticated adversaries intercept cellular routing tables at the international signaling level.''',
        attackScenario: '''An attacker gathered a victim's birthdate and address from public social media, called customer support pretending to have lost their phone, and ported the number to an eSIM, resetting banking logins within minutes.''',
        defenseChecklist: [
          'Set a mandatory verbal PIN/passcode with your mobile carrier on SIM transfer requests.',
          'Migrate all accounts from SMS 2FA to hardware Passkeys or Authenticator Apps (TOTP).',
          'Audit apps with SMS permissions in ShadowWall AI.',
        ],
        keyTakeaway: 'SMS is an unencrypted legacy transmission. Replace SMS 2FA with hardware keys or Passkeys whenever possible.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'What dangerous capability does Android Accessibility permission grant to a malicious app?',
        options: ['It changes the phone ringtone', 'It can read all on-screen text and simulate touch inputs across all apps', 'It only allows Bluetooth pairing', 'It formats the SD card without notice'],
        correctAnswerIndex: 1,
        explanation: 'Accessibility services grant full UI inspection and touch simulation, enabling trojans to read passwords and execute background money transfers.',
      ),
    ],
  ),

  // ── 3. Wi-Fi Security & Network Exploits ──
  CourseEntity(
    id: 'c3',
    title: 'Wi-Fi Network Security, Evil Twins & MITM Exploits',
    description: 'Understand 802.11 wireless protocols, Rogue APs, ARP poisoning, SSL stripping, and VPN encapsulation.',
    level: 'Intermediate',
    duration: '30 mins',
    iconName: 'wifi',
    lessons: [
      const LessonEntity(
        id: 'c3_l1',
        title: 'The "Evil Twin" Attack on Public Wi-Fi',
        subtitle: 'How attackers broadcast duplicate SSIDs in cafes & airports',
        content: '''Your mobile devices are configured to automatically reconnect to known Wi-Fi networks by matching the SSID (network name).

In an Evil Twin attack:
1. An attacker sets up a portable rogue Wi-Fi hotspot with the exact same SSID as a venue (e.g., `Starbucks_Guest_WiFi`).
2. They broadcast deauthentication frames to force your phone to disconnect from the real router.
3. Your device connects to the attacker's stronger signal.
4. All your internet traffic now passes through the attacker's gateway, where they analyze DNS queries, capture unencrypted packets, and deploy captive portal phishing screens.''',
        attackScenario: '''An attacker at an international airport terminal broadcasted "Free_Airport_HighSpeed_WiFi." Over 100 passengers connected and entered their corporate email credentials on a fake captive portal login.''',
        defenseChecklist: [
          'Disable "Auto-Connect to Open Wi-Fi" in your device wireless settings.',
          'Always verify Wi-Fi credentials with staff before connecting.',
          'Use ShadowWall AI Wi-Fi Guard to inspect gateway encryption, DNS latency, and MITM posture.',
        ],
        keyTakeaway: 'Never trust an open Wi-Fi network simply because the SSID looks familiar. Anyone can broadcast any network name.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'What does an Evil Twin Wi-Fi attack rely on?',
        options: ['Cracking the router power supply', 'Broadcasting a rogue hotspot with the identical SSID of a legitimate network', 'Cutting the physical fiber optic cable', 'Sending spam SMS messages'],
        correctAnswerIndex: 1,
        explanation: 'Evil Twin attacks clone the SSID of a trusted network so victim devices automatically connect to the malicious interception gateway.',
      ),
    ],
  ),

  // ── 4. Identity & Zero-Trust ──
  CourseEntity(
    id: 'c4',
    title: 'Zero-Trust Architecture & Passkey Authentication',
    description: 'Learn why perimeter security is obsolete and how public-key cryptography (FIDO2/WebAuthn) eliminates credential theft.',
    level: 'Advanced',
    duration: '35 mins',
    iconName: 'psychology',
    lessons: [
      const LessonEntity(
        id: 'c4_l1',
        title: 'The Principle of Zero-Trust: "Never Trust, Always Verify"',
        subtitle: 'Moving beyond perimeter-based corporate firewalls',
        content: '''Traditional security operated on a "castle-and-moat" perimeter model: anyone inside the local corporate network was implicitly trusted.

Zero-Trust Architecture (ZTA) assumes that attackers already breach the perimeter. Its core tenets are:
1. **Explicit Verification**: Every access request is authenticated, authorized, and encrypted based on user identity, device posture, and geolocation.
2. **Least Privilege Access**: Grant users only the exact permissions needed for their immediate task (JIT - Just-In-Time access).
3. **Assume Breach**: Segment networks into micro-perimeters so compromising one workstation does not grant access to the entire server fleet.''',
        attackScenario: '''A contractor workstation on a corporate LAN was infected with malware. Because the company used legacy perimeter security without micro-segmentation, the malware traversed laterally into core databases.''',
        defenseChecklist: [
          'Implement multi-factor authentication on every resource, not just the front door.',
          'Enforce device compliance checks before granting access to sensitive portals.',
          'Segment home smart devices (IoT) onto a separate guest Wi-Fi subnet.',
        ],
        keyTakeaway: 'Zero-Trust means continuous verification. Never grant implicit trust based on network location or IP address.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'What is the core philosophy of Zero-Trust Architecture?',
        options: ['Trust everyone inside the office building', 'Never trust, always verify every access request continuously', 'Use one master password for all servers', 'Disable all encryption on internal networks'],
        correctAnswerIndex: 1,
        explanation: 'Zero-Trust enforces continuous verification of identity, device health, and context for every transaction without implicit trust.',
      ),
    ],
  ),

  // ── 5. Ransomware Defense ──
  CourseEntity(
    id: 'c5',
    title: 'Ransomware Mechanics & Incident Response',
    description: 'Double extortion playbooks, lateral movement tactics, and the immutable 3-2-1 backup strategy.',
    level: 'Intermediate',
    duration: '30 mins',
    iconName: 'book',
    lessons: [
      const LessonEntity(
        id: 'c5_l1',
        title: 'The Double Extortion Paradigm',
        subtitle: 'Why encryption is only half the ransomware threat',
        content: '''Modern ransomware syndicates (e.g., LockBit, BlackCat, Akira) no longer simply encrypt local files with AES-256/RSA. They deploy **Double and Triple Extortion**:
1. **Phase 1 (Exfiltration)**: Attackers silently siphon confidential customer data, emails, and source code over weeks.
2. **Phase 2 (Encryption)**: They deploy high-speed multi-threaded encryption routines to lock file systems and hypervisors.
3. **Phase 3 (Extortion)**: If the victim restores from backups without paying, attackers threaten to publish the stolen data on public darknet leak sites or contact affected clients directly.''',
        attackScenario: '''A regional healthcare provider restored systems from backups after an attack, but attackers released patient medical records on Telegram when the extortion demand was rejected.''',
        defenseChecklist: [
          'Maintain offline, immutable backups that cannot be modified over the local network (3-2-1 rule).',
          'Deploy endpoint detection and response (EDR) to identify data exfiltration before encryption triggers.',
          'Enforce strict egress filtering to prevent mass outbound data uploads.',
        ],
        keyTakeaway: 'Preventing data exfiltration is as critical as preventing file encryption in modern ransomware defense.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'What constitutes "Double Extortion" in modern ransomware operations?',
        options: ['Charging twice for the decryption key', 'Encrypting files AND exfiltrating proprietary data to threaten public release', 'Attacking two computers simultaneously', 'Demanding ransom in two different cryptocurrencies'],
        correctAnswerIndex: 1,
        explanation: 'Double extortion combines file encryption with data exfiltration and public leak threats to maximize leverage over victims.',
      ),
    ],
  ),

  // ── 6. Social Engineering & Deepfakes ──
  CourseEntity(
    id: 'c6',
    title: 'Social Engineering, Deepfakes & AI Voice Cloning',
    description: 'How generative neural networks synthesize executive voices, bypass vocal biometrics, and execute CEO fraud.',
    level: 'Beginner',
    duration: '25 mins',
    iconName: 'psychology',
    lessons: [
      const LessonEntity(
        id: 'c6_l1',
        title: 'AI Voice Cloning in Modern Vishing Attacks',
        subtitle: 'Synthesizing familial and executive voices in real time',
        content: '''Generative adversarial networks (GANs) and diffusion audio models can clone any human voice with as little as 3 seconds of reference audio harvested from YouTube videos, TikToks, or voicemail greetings.

Attackers use cloned voice AI to:
1. **Execute CEO Fraud**: Call financial controllers posing as the company CEO, demanding an emergency confidential supplier wire transfer.
2. **Family Emergency Scams**: Call parents posing as a child in distress claiming to be arrested or in a hospital accident, demanding bail via wire or gift cards.''',
        attackScenario: '''A multinational branch manager in Hong Kong attended a video conference call with their "CFO" and colleagues—all of whom were real-time deepfake avatars—and transferred \$25M to fraudulent accounts.''',
        defenseChecklist: [
          'Establish a secret family or corporate "Safe Word" known only to trusted members.',
          'Always hang up and call back on a verified direct phone number.',
          'Never execute emergency funds transfers based solely on voice or video calls.',
        ],
        keyTakeaway: 'Audio and video are no longer proof of identity. Always establish an out-of-band verification challenge before acting.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'What is the most effective defense against an AI voice cloning scam calling for urgent funds?',
        options: ['Listen closely for robotic artifacts', 'Hang up and call back on a pre-verified number, or ask for a private safe word', 'Ask the caller what their name is', 'Send half the requested money to test them'],
        correctAnswerIndex: 1,
        explanation: 'Always verify out-of-band via a pre-established contact number or challenge the caller with a private safe word that cannot be scraped online.',
      ),
    ],
  ),

  // ── 7. Cloud Privacy & Data Hygiene ──
  CourseEntity(
    id: 'c7',
    title: 'Cloud Privacy, App Sandboxing & Data Hygiene',
    description: 'Manage data broker exfiltration, photo EXIF metadata leakage, and cloud storage permission hygiene.',
    level: 'Beginner',
    duration: '20 mins',
    iconName: 'book',
    lessons: [
      const LessonEntity(
        id: 'c7_l1',
        title: 'EXIF Metadata & Location Leakage in Photos',
        subtitle: 'How innocent image uploads reveal your physical address',
        content: '''Exchangeable Image File Format (EXIF) metadata is embedded into every photo captured on your smartphone.

EXIF records include:
- Exact GPS latitude and longitude coordinates
- Camera sensor model, serial number, and firmware version
- Timestamp down to the millisecond
- Altitude and compass direction

Uploading raw photos to online forums, marketplaces, or messaging apps that do not strip EXIF metadata allows stalkers to determine your home address and daily routines.''',
        attackScenario: '''A seller posted photos of merchandise taken inside their living room to an online marketplace. Attackers extracted the EXIF GPS coordinates and burglarized the residence that evening.''',
        defenseChecklist: [
          'Disable GPS location tagging in your camera app settings.',
          'Use metadata stripping tools or screenshot photos before public sharing.',
          'Review photo permissions for third-party apps in ShadowWall AI.',
        ],
        keyTakeaway: 'Photos contain invisible GPS breadcrumbs. Strip EXIF metadata before sharing images online.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'What sensitive data is frequently embedded inside raw smartphone photo files (EXIF)?',
        options: ['Bank account numbers', 'Precise GPS latitude/longitude coordinates and camera serial numbers', 'Device lock screen passwords', 'Cellular tower frequency keys'],
        correctAnswerIndex: 1,
        explanation: 'EXIF metadata includes exact GPS coordinates, timestamps, and device hardware details.',
      ),
    ],
  ),

  // ── 8. Modern Cryptography ──
  CourseEntity(
    id: 'c8',
    title: 'Modern Cryptography & End-to-End Encryption',
    description: 'Asymmetric key exchanges, Perfect Forward Secrecy (PFS), AES-256 GCM, and post-quantum algorithms.',
    level: 'Advanced',
    duration: '35 mins',
    iconName: 'book',
    lessons: [
      const LessonEntity(
        id: 'c8_l1',
        title: 'End-to-End Encryption (E2EE) & Signal Protocol',
        subtitle: 'Why server-side encryption is insufficient for privacy',
        content: '''In "Encryption in Transit" (standard HTTPS), data is encrypted between your device and the cloud server, meaning the company owning the server holds the decryption keys and can inspect or subpoena your messages.

In **End-to-End Encryption (E2EE)** (such as the Signal Protocol):
1. Cryptographic key pairs are generated directly on client endpoints.
2. Messages are encrypted with the recipient's public key before leaving your phone.
3. Only the recipient's private hardware key can decrypt the message.
4. Even if the service provider servers or intermediate network nodes are compromised, they observe only mathematically undecipherable ciphertext.''',
        attackScenario: '''A cloud email provider suffered a server compromise. Because emails were only encrypted in transit, attackers dumped millions of plain-text customer communications.''',
        defenseChecklist: [
          'Choose messaging platforms that enforce true E2EE with open-source audited protocols.',
          'Verify safety numbers or cryptographic fingerprints with contacts in person.',
          'Enable disappearing messages to limit forward exposure.',
        ],
        keyTakeaway: 'If the service provider holds the decryption keys, your data is not private. True privacy requires client-side E2EE.',
      ),
    ],
    finalQuiz: [
      const QuizQuestion(
        question: 'What distinguishes true End-to-End Encryption (E2EE) from standard HTTPS server encryption?',
        options: ['E2EE is faster', 'In E2EE, only communicating endpoints hold the decryption keys—the intermediate server cannot decrypt the data', 'E2EE does not use mathematical keys', 'E2EE only works on Wi-Fi'],
        correctAnswerIndex: 1,
        explanation: 'In E2EE, decryption keys exist strictly on user endpoints, preventing server operators or network eavesdroppers from accessing plaintext.',
      ),
    ],
  ),
];

class LearningNotifier extends StateNotifier<LearningState> {
  LearningNotifier() : super(const LearningState());

  void completeLesson(String courseId) {
    final current = state.completedLessonsPerCourse[courseId] ?? 0;
    final course = availableCourses.firstWhere((c) => c.id == courseId);

    if (current < course.lessons.length) {
      final updatedMap = Map<String, int>.from(state.completedLessonsPerCourse);
      updatedMap[courseId] = current + 1;
      state = state.copyWith(
        completedLessonsPerCourse: updatedMap,
        totalXp: state.totalXp + 25,
      );
    }
  }

  void completeCourseQuiz(String courseId, double scorePercentage) {
    if (scorePercentage >= 60) {
      final updatedCourses = Set<String>.from(state.completedCourses)..add(courseId);
      state = state.copyWith(
        completedCourses: updatedCourses,
        totalXp: state.totalXp + 100,
      );
    }
  }

  String getCourseStatus(String courseId) {
    if (state.completedCourses.contains(courseId)) return 'Completed';
    final completed = state.completedLessonsPerCourse[courseId] ?? 0;
    final course = availableCourses.firstWhere((c) => c.id == courseId, orElse: () => availableCourses.first);
    if (completed == 0) return 'Not Started';
    if (completed >= course.lessons.length) return 'Ready for Quiz';
    return '$completed / ${course.lessons.length} Lessons';
  }
}

final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  return LearningNotifier();
});
