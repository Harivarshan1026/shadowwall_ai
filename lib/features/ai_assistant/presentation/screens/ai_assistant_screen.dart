/// AI Assistant chat screen — Integrated with Google AI Studio Gemini API & Extensive Cybersecurity Knowledge Engine.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
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
        // Fallback with an explanatory note if API call failed
        final fallback = _generateFallbackResponse(text);
        final err = result.errorMessage ?? 'API Connection failed';
        responseText = '$fallback\n\n*(Note: Live Gemini query encountered: $err. Showing offline cybersecurity intelligence).*';
      }
    } else {
      // 2. Offline Cybersecurity Knowledge Base
      responseText = _generateFallbackResponse(text);
    }

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

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: EnvConfig.geminiApiKey);
    String selectedModel = EnvConfig.geminiModel;
    bool isTesting = false;
    String? testResultMsg;
    bool? testSuccess;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
              ),
              title: Row(
                children: [
                  const Icon(Icons.key_rounded, color: AppColors.primaryCyan, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Google AI Studio API Key',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configure your Gemini API key to enable live AI threat intelligence and contextual chatbot queries.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller,
                      style: AppTypography.mono.copyWith(color: AppColors.darkOnSurface, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'AIzaSy...',
                        hintStyle: AppTypography.mono.copyWith(color: AppColors.darkOnSurfaceVariant.withValues(alpha: 0.5), fontSize: 12),
                        prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18, color: AppColors.primaryCyan),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => setDialogState(() => controller.clear()),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.darkSurfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (_) => setDialogState(() {
                        testResultMsg = null;
                        testSuccess = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Model Selection:',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedModel,
                          dropdownColor: AppColors.darkSurfaceVariant,
                          isExpanded: true,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface),
                          items: const [
                            DropdownMenuItem(
                              value: 'gemini-3.6-flash',
                              child: Text('gemini-3.6-flash (Fast & Accurate)'),
                            ),
                            DropdownMenuItem(
                              value: 'gemini-3.7-flash',
                              child: Text('gemini-3.7-flash (Next-Gen Flash)'),
                            ),
                            DropdownMenuItem(
                              value: 'gemini-flash-latest',
                              child: Text('gemini-flash-latest (Auto-Updating)'),
                            ),
                            DropdownMenuItem(
                              value: 'gemini-2.5-pro',
                              child: Text('gemini-2.5-pro (Deep Reasoning)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedModel = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Test connection button
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryCyan),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: isTesting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryCyan),
                                )
                              : const Icon(Icons.network_check_rounded, size: 16, color: AppColors.primaryCyan),
                          label: Text(
                            isTesting ? 'Testing...' : 'Test Key',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.primaryCyan),
                          ),
                          onPressed: isTesting
                              ? null
                              : () async {
                                  final candidate = controller.text.trim();
                                  if (candidate.isEmpty) {
                                    setDialogState(() {
                                      testSuccess = false;
                                      testResultMsg = 'Please enter an API key first.';
                                    });
                                    return;
                                  }

                                  setDialogState(() {
                                    isTesting = true;
                                    testResultMsg = null;
                                  });

                                  final isValid = await GeminiAiService.instance.testApiKey(candidate);

                                  setDialogState(() {
                                    isTesting = false;
                                    testSuccess = isValid;
                                    testResultMsg = isValid
                                        ? '✓ Connected to Google AI Studio!'
                                        : '✗ Invalid API key or network error.';
                                  });
                                },
                        ),
                        if (testResultMsg != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              testResultMsg!,
                              style: AppTypography.labelSmall.copyWith(
                                color: (testSuccess ?? false) ? AppColors.neonGreen : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Tip: You can also define GEMINI_API_KEY inside your .env file in the project directory.',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCyan),
                  onPressed: () async {
                    final newKey = controller.text.trim();
                    await EnvConfig.setGeminiApiKey(newKey);
                    await EnvConfig.setGeminiModel(selectedModel);

                    if (mounted) {
                      setState(() {});
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            EnvConfig.hasGeminiApiKey
                                ? '🔑 Gemini API Key & Model Saved!'
                                : 'Key cleared. Switched to offline knowledge base.',
                          ),
                          backgroundColor: EnvConfig.hasGeminiApiKey ? AppColors.neonGreen : AppColors.warning,
                        ),
                      );
                    }
                  },
                  child: const Text('Save & Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Extensive offline cybersecurity knowledge engine
  String _generateFallbackResponse(String prompt) {
    final query = prompt.toLowerCase();

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

    // 8. General Cybersecurity Assistant Fallback
    return '''🛡️ ShadowWall AI Security Guide:

I am your active cybersecurity companion! Ask me about any technical or defense topic:

• "How does Wi-Fi WPA2/WPA3 handshake cracking work?"
• "How do fake UPI payment screenshot scams deceive users?"
• "Explain man-in-the-middle (MITM) attacks on public Wi-Fi."
• "Why is APK sideloading dangerous on Android?"
• "What is the best way to store passwords and setup 2FA?"
• "How do zero-click exploits like Pegasus operate?"

*(Tip: Tap the 🔑 icon in the top right to configure your Google AI Studio API Key for unlimited live conversational Gemini answers!)*''';
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
    final hasKey = EnvConfig.hasGeminiApiKey;

    return Scaffold(
      appBar: CyberAppBar(
        title: 'ShadowWall AI',
        subtitle: hasKey ? 'Google Gemini Live AI' : 'Cybersecurity Assistant',
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(
              hasKey ? Icons.key_rounded : Icons.key_off_rounded,
              color: hasKey ? AppColors.neonGreen : AppColors.warning,
            ),
            onPressed: _showApiKeyDialog,
            tooltip: hasKey ? 'Gemini API Key Active' : 'Configure Gemini API Key',
          ),
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
            // Status Header Banner
            _buildStatusHeader(hasKey),

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

  Widget _buildStatusHeader(bool hasKey) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: hasKey
            ? AppColors.neonGreen.withValues(alpha: 0.08)
            : AppColors.warning.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: hasKey
                ? AppColors.neonGreen.withValues(alpha: 0.2)
                : AppColors.warning.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: hasKey ? AppColors.neonGreen : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasKey
                  ? 'Live AI Mode: ${EnvConfig.geminiModel} active'
                  : 'Offline Knowledge Engine (Tap 🔑 to connect Live Gemini AI)',
              style: AppTypography.labelSmall.copyWith(
                color: hasKey ? AppColors.neonGreen : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!hasKey)
            GestureDetector(
              onTap: _showApiKeyDialog,
              child: Text(
                'Connect Key →',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryCyan,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
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
                    SelectableText(
                      text,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkOnSurface,
                        height: 1.45,
                      ),
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
