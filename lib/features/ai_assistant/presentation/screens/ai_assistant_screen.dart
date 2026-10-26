/// AI Assistant chat screen — Integrated with Google AI Studio Gemini API & Extensive Cybersecurity Knowledge Engine.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/cyber_markdown_view.dart';
import '../../../../core/config/env_config.dart';
import '../../../../ai_engine/services/gemini_ai_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Hello! I am ShadowWall AI, your intelligent cybersecurity and mobile defense companion. Ask me anything about cyber defense, Wi-Fi security, hacking mechanics, password safety, or device protection!',
      'time': DateTime.now(),
    },
  ];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedPrompts = [
    '🔒 Wi-Fi Handshake & Defense',
    '🎣 How to identify Phishing SMS',
    '📱 Is APK sideloading dangerous?',
    '💳 Fake UPI Payment Scams',
    '🔑 Password Manager vs Browser Save',
    '🦠 Ransomware Protection Guide',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) async {
    final text = (presetText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': DateTime.now(),
      });
      if (presetText == null) {
        _messageController.clear();
      }
      _isTyping = true;
    });

    _scrollToBottom();

    String responseText;

    if (EnvConfig.hasGeminiApiKey) {
      // 1. Live Google AI Studio Gemini API with multi-turn conversation memory
      final result = await GeminiAiService.instance.queryGeminiChat(
        conversationHistory: _messages,
        userPrompt: text,
      );

      if (result.isSuccess && result.text != null && result.text!.isNotEmpty) {
        responseText = result.text!;
      } else {
        // Fallback seamlessly and cleanly to offline intelligence with zero debug notes
        responseText = _generateFallbackResponse(text);
      }
    } else {
      // 2. Offline Cybersecurity Knowledge Base
      responseText = _generateFallbackResponse(text);
    }

    // Clean any stray markdown symbols
    responseText = GeminiAiService.sanitizeAiOutput(responseText);

    if (!mounted) return;

    setState(() {
      _messages.add({
        'isUser': false,
        'text': responseText,
        'time': DateTime.now(),
      });
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text('Clear Conversation?', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
        content: Text('This will reset your current chat history.', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _messages.add({
                  'isUser': false,
                  'text': 'Conversation cleared. How can I help you stay secure today?',
                  'time': DateTime.now(),
                });
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.darkSurfaceVariant,
      ),
    );
  }

  /// Extensive offline cybersecurity knowledge engine
  String _generateFallbackResponse(String prompt) {
    final query = prompt.toLowerCase().trim();
    final cleanQuery = query.replaceAll(RegExp(r'[!.,?/\\]'), '').trim();

    // 0. Greetings & Natural Chat
    if (['hi', 'hii', 'hiii', 'hello', 'hey', 'heyy', 'hola', 'sup', 'howdy', 'good morning', 'good evening', 'good afternoon'].contains(cleanQuery) ||
        cleanQuery.startsWith('hi ') || cleanQuery.startsWith('hello ') || cleanQuery.startsWith('hey ')) {
      return 'Hey there! 👋 How can I help you with your device security, scam checks, or cyber safety today?';
    }

    if (cleanQuery == 'how are you' || cleanQuery == 'how are you doing' || cleanQuery == 'how are u') {
      return 'I am doing great and ready to protect your device! 🛡️ What cybersecurity topic or question would you like to explore?';
    }

    if (cleanQuery == 'who are you' || cleanQuery == 'what are you' || cleanQuery == 'what is shadowwall') {
      return 'I am ShadowWall AI, your personal cybersecurity and mobile defense companion 🛡️. I help analyze suspicious links, audit Wi-Fi security, inspect APK files, and answer any cyber defense questions.';
    }

    if (cleanQuery == 'thank you' || cleanQuery == 'thanks' || cleanQuery == 'thx' || cleanQuery == 'thank u') {
      return 'You are very welcome! 😊 Stay safe and feel free to ask anytime if you need more security advice.';
    }

    if (cleanQuery == 'bye' || cleanQuery == 'goodbye' || cleanQuery == 'see you') {
      return 'Stay vigilant and stay safe online! 🛡️ Reach out whenever you need security assistance.';
    }

    // 1. Wi-Fi & Wireless Security
    if (query.contains('wifi') || query.contains('wi-fi') || query.contains('router') || query.contains('wpa') || query.contains('handshake') || query.contains('wps') || query.contains('bssid')) {
      return '''🔒 Wi-Fi Hacking Mechanics & Defensive Hardening:

1. Educational Attack Mechanics:
• 4-Way WPA Handshake Capture: When a device authenticates with an Access Point (AP), it exchanges cryptographic EAPOL frames. Attackers send de-authentication frames to force reconnection, intercept the MIC (Message Integrity Code), and perform dictionary/hashcat brute-force attacks offline without touching the router again.
• Evil Twin / Rogue AP: Attackers broadcast an identical SSID with higher signal power to capture captive portal credentials.
• WPS PIN Vulnerabilities: Legacy WPS utilizes an 8-digit PIN split into two halves, vulnerable to brute forcing in < 4 hours.

2. Defensive Countermeasures:
✔️ Upgrade Router Encryption to WPA3-SAE (Simultaneous Authentication of Equals) with Protected Management Frames (PMF).
✔️ Disable WPS (Wi-Fi Protected Setup) in the router administration panel.
✔️ Use passphrases with 16+ characters (high entropy).
✔️ Isolate IoT devices on a dedicated Guest Wi-Fi VLAN.''';
    }

    // 2. Phishing, Smishing & Vishing
    if (query.contains('phish') || query.contains('smish') || query.contains('vish') || query.contains('fake link') || query.contains('suspicious link') || query.contains('spoof')) {
      return '''🎣 Phishing, Smishing & Deceptive Link Defense:

1. Threat Indicators:
• Lookalike/Typosquatting Domains: Cyrillic homoglyphs or subtle character swaps (e.g. `arnazon.com` instead of `amazon.com`).
• High-Pressure Urgency: "Your account will be suspended in 2 hours", "Urgent tax refund pending".
• Unusual TLDs & URL Shorteners: Excessive redirects masking final domain destination.

2. Defensive Actions:
✔️ Never tap links inside unsolicited SMS/emails.
✔️ Always verify the domain SLD (Second-Level Domain) in the browser URL bar.
✔️ Paste suspicious links into the ShadowWall AI "URL Threat Scanner" before opening.
✔️ Report phishing numbers directly to telecom anti-spam registries.''';
    }

    // 3. Fake UPI & Payment Scams
    if (query.contains('upi') || query.contains('payment') || query.contains('qr code') || query.contains('banking') || query.contains('fake screenshot') || query.contains('paytm') || query.contains('gpay')) {
      return '''💳 Payment & Fake UPI Screenshot Scams:

1. Common Modus Operandi:
• Fake Payment Apps: Fraudsters use simulator apps to generate authentic-looking payment success screens and audio notifications without transferring funds.
• Reverse Payment QR Scams: Sending a QR code claiming "Scan to receive money". Remember: YOU NEVER ENTER A UPI PIN TO RECEIVE MONEY.
• Fraudulent Chargeback Requests: Attackers claim accidental transfers and demand instant cash return.

2. Defense Protocol:
✔️ Always check your actual bank SMS / balance directly in your banking app before handing over goods or receipts.
✔️ Never scan QR codes or enter PINs to receive cashback or refunds.
✔️ Use ShadowWall AI "Screenshot Analyzer" to detect forged payment receipts and watermarks.''';
    }

    // 4. Passwords, 2FA, MFA & Passkeys
    if (query.contains('password') || query.contains('2fa') || query.contains('mfa') || query.contains('authenticator') || query.contains('passkey') || query.contains('entropy') || query.contains('hash')) {
      return '''🔑 Password & Authentication Best Practices:

1. Cryptographic Security Standards:
• Password Entropy: Replace single complex words with 4-word random passphrases (e.g. `correct-horse-battery-staple`).
• Avoid SMS OTPs: SMS messages are susceptible to SIM swapping and SS7 interception.
• Prefer Hardware / TOTP 2FA: Use Google Authenticator, Aegis, YubiKeys, or FIDO2 WebAuthn Passkeys.

2. Recommended Actions:
✔️ Use an open-source/encrypted password manager (Bitwarden / 1Password).
✔️ Enable biometric app locks and passkeys wherever supported.
✔️ Never repeat master credentials across multiple portals.''';
    }

    // 5. APK Sideloading, Android Malware & Spyware
    if (query.contains('apk') || query.contains('sideload') || query.contains('permission') || query.contains('trojan') || query.contains('spyware') || query.contains('malware') || query.contains('ransomware') || query.contains('virus') || query.contains('keylog')) {
      return '''🦠 APK Sideloading & Android Malware Protection:

1. Sideloading Risks:
• Overlay Attacks: Malware requests `SYSTEM_ALERT_WINDOW` to draw fake login overlays over legitimate banking apps.
• Accessibility Abuse: Malicious apps exploit `BIND_ACCESSIBILITY_SERVICE` to automate screen clicks and steal OTPs silently.
• Sideloaded Trojans: Modded APKs often package remote access trojans (RATs) like CraxsRAT or SpyNote.

2. Defensive Protocol:
✔️ Disable "Install from Unknown Sources" in Android Settings.
✔️ Audit requested permissions carefully before installing any APK.
✔️ Use ShadowWall AI "APK Analyzer" to inspect permissions and signatures before running APK files.''';
    }

    // 6. Pegasus, Zero-Clicks & Advanced Spyware
    if (query.contains('pegasus') || query.contains('zero click') || query.contains('spyware') || query.contains('imsi') || query.contains('sim swap')) {
      return '''🛡️ Zero-Click Exploits & Advanced Spyware Defense:

1. How Advanced Spyware Operates:
• Zero-Click Exploits: Exploit vulnerabilities in media parsing engines (e.g. iMessage/WhatsApp image decoders) requiring zero user interaction.
• Kernel Escalation: Exploits sandbox escape bugs to gain root/system-level device control.

2. Hardening Measures:
✔️ Enable iOS Lockdown Mode / Android Developer Restriction Mode if at high threat risk.
✔️ Keep your mobile OS patched immediately on every security bulletin release.
✔️ Reboot your phone daily (forces non-persistent spyware out of volatile memory).
✔️ Contact your telecom carrier to activate a SIM PIN and Port-Out Lock.''';
    }

    // 7. Public Wi-Fi & VPNs
    if (query.contains('public wifi') || query.contains('hotspot') || query.contains('vpn') || query.contains('mitm') || query.contains('sniffing') || query.contains('dns')) {
      return '''🌐 Public Wi-Fi & Network Security Guide:

1. Risks on Untrusted Networks:
• Man-in-the-Middle (MITM): Interception of unencrypted packets on open Wi-Fi.
• DNS Spoofing: Forcing domain lookups to redirect to malicious server IPs.
• Packet Sniffing: Broadcast traffic capture by neighboring network clients.

2. Safety Checklist:
✔️ Always connect through a trusted WireGuard/OpenVPN VPN when on public Wi-Fi.
✔️ Verify HTTPS padlock and DNS-over-HTTPS (DoH) / DNS-over-TLS (DoT).
✔️ Disable "Auto-Connect to Open Networks" in device Wi-Fi settings.''';
    }

    // 8. WhatsApp / Telegram / OTP & SIM Swap Frauds
    if (query.contains('otp') || query.contains('whatsapp') || query.contains('telegram') || query.contains('sim swap') || query.contains('call forward') || query.contains('*401*')) {
      return '''📱 OTP, Social Account & SIM Hijack Defense:

1. How Attackers Exploit You:
• Call Forwarding Traps (*401* / *21*): Scammers trick you into dialing numbers that forward your phone calls and voice OTPs to their burner phones.
• WhatsApp Impersonation: Attackers pose as family or friends asking for a "6-digit code sent by mistake".
• SIM Swapping: Fraudsters forge identity documents at carrier stores to transfer your phone number to their SIM.

2. Immediate Safeguards:
✔️ Never share any 6-digit verification code or OTP over phone, chat, or email.
✔️ Enable Two-Step Verification (with a custom PIN) inside WhatsApp and Telegram Settings -> Account.
✔️ If your phone suddenly loses cellular signal and shows "No Service", contact your carrier immediately from another device.''';
    }

    // 9. Crypto, Task & Investment Scams
    if (query.contains('crypto') || query.contains('bitcoin') || query.contains('task') || query.contains('investment') || query.contains('work from home') || query.contains('part time') || query.contains('like video')) {
      return '''💰 Investment, Task & Crypto Fraud Defense:

1. Deceptive Tactics:
• "Prepaid Task Scams": Fraudsters add you to Telegram groups offering money for YouTube likes or hotel reviews, then demand advance deposits to unlock "VIP profits".
• Fake Crypto Trading Exchanges: Manipulated charts show rapid profits, but withdrawals are blocked demanding "clearance taxes".
• Ponzi Telegram Bots: Automated bots promising guaranteed daily returns.

2. Golden Safety Rules:
✔️ Any job asking you to pay money to receive earnings is 100% a scam.
✔️ Only trade cryptocurrencies on regulated, licensed global or national exchanges.
✔️ Never deposit funds into unknown individual bank accounts or crypto wallet addresses.''';
    }

    // 10. Social Media Hacking & Account Recovery (Instagram, Facebook, Google)
    if (query.contains('instagram') || query.contains('hacked') || query.contains('facebook') || query.contains('account recovery') || query.contains('stolen') || query.contains('compromised')) {
      return '''🛡️ Compromised Account Emergency Recovery Playbook:

1. Immediate Emergency Actions:
✔️ Go to official account recovery portals (e.g. instagram.com/hacked or myaccount.google.com/security).
✔️ Request a password reset to your trusted recovery email and phone number.
✔️ If 2FA was hijacked, use your stored Offline Backup Codes or submit a selfie video verification request to the platform support team.

2. Post-Recovery Hardening:
✔️ Revoke all authorized apps and terminate active sessions under "Settings -> Security -> Where You're Logged In".
✔️ Change master passwords to high-entropy passphrases (16+ characters).
✔️ Activate TOTP Authenticator app (Google Authenticator / Aegis) instead of SMS.''';
    }

    // 11. Courier / Delivery / Electricity Bill SMS Scams
    if (query.contains('courier') || query.contains('fedex') || query.contains('speed post') || query.contains('delivery') || query.contains('electricity') || query.contains('bill update') || query.contains('pan update')) {
      return '''📦 Courier & Utility Bill Deceptive SMS Defense:

1. How the Scam Operates:
• "Your package address is incomplete, update here" or "Your electricity power will be disconnected tonight, call officer immediately".
• Links lead to fake portals prompting a nominal payment (e.g. ₹5 or \$1), which secretly captures your banking credentials or installs remote support software (AnyDesk / TeamViewer).

2. Defense Protocol:
✔️ Never call numbers mentioned inside SMS warnings.
✔️ Verify parcel status directly by visiting the official courier website and entering your tracking ID.
✔️ Never install remote desktop apps (AnyDesk, RustDesk, QuickSupport) at the request of an unknown caller.''';
    }

    // 12. Device Overheating, Spyware & Mic/Camera Indicators
    if (query.contains('hot') || query.contains('battery') || query.contains('spy') || query.contains('camera') || query.contains('mic') || query.contains('listening') || query.contains('slow')) {
      return '''📱 Spyware & Device Anomaly Detection Guide:

1. Indicators of Hidden Background Spyware:
• Rapid battery drain and unexpected device overheating while idling.
• Persistent green or orange dot in your phone's status bar indicating active microphone/camera usage.
• Unsolicited popups and sudden high background mobile data usage.

2. Remediation Steps:
✔️ Open Android Settings -> Privacy -> Permission Manager -> Check which apps have background Camera & Microphone permissions.
✔️ Check Android Settings -> Apps -> Special App Access -> Device Admin Apps & Display Over Other Apps.
✔️ Run a full scan using the ShadowWall AI "Device Security" and "APK Analyzer" modules.''';
    }

    // 13. General Cybersecurity Assistant Fallback
    return '''🛡️ ShadowWall AI Security Guide:

I am your active cybersecurity companion! Ask me about any technical or defense topic:

• "How do fake UPI payment screenshot scams deceive users?"
• "How does Wi-Fi WPA2/WPA3 handshake cracking work?"
• "Explain man-in-the-middle (MITM) attacks on public Wi-Fi."
• "Why is APK sideloading dangerous on Android?"
• "What is the best way to store passwords and setup 2FA?"
• "How do zero-click exploits like Pegasus operate?"
• "How do I protect my WhatsApp and Instagram accounts from being hacked?"''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CyberAppBar(
        title: 'ShadowWall AI',
        subtitle: 'Intelligent Security Companion',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.darkOnSurfaceVariant),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  final msg = _messages[index];
                  return _buildMessageBubble(
                    text: msg['text'] as String,
                    isUser: msg['isUser'] as bool,
                  );
                },
              ),
            ),

            // Suggested prompt chips (shown when 1 message or user hasn't typed)
            if (_messages.length <= 2 && !_isTyping) _buildSuggestedChips(),

            // Input Area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = _suggestedPrompts[index];
          return ActionChip(
            backgroundColor: AppColors.darkSurfaceVariant,
            side: BorderSide(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
            label: Text(
              prompt,
              style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurface),
            ),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primaryCyan.withValues(alpha: 0.18) : AppColors.darkSurfaceVariant,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: Border.all(
                    color: isUser ? AppColors.primaryCyan.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUser)
                      SelectableText(
                        text,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          height: 1.45,
                        ),
                      )
                    else
                      CyberMarkdownView(
                        text: text,
                        accentColor: AppColors.primaryCyan,
                      ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () => _copyToClipboard(text),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: AppColors.darkOnSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.2, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 200)),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask any cybersecurity question...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.darkSurfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
