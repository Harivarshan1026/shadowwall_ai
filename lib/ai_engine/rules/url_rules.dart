/// URL analysis rules — rule-based URL threat detection.
///
/// Provides comprehensive URL analysis including SSL checks,
/// typosquatting detection, suspicious keyword identification,
/// and structural analysis.
library;

class UrlRules {
  UrlRules._();

  /// Analyze a URL and return a risk assessment map.
  static Map<String, dynamic> analyze(String url) {
    final lowerTrimmed = url.trim().toLowerCase();
    if (lowerTrimmed.startsWith('upi://') ||
        lowerTrimmed.startsWith('paytmmp://') ||
        lowerTrimmed.startsWith('phonepe://') ||
        lowerTrimmed.startsWith('gpay://') ||
        (lowerTrimmed.contains('upi://') && lowerTrimmed.contains('pa='))) {
      return _analyzeUpiPayment(url.trim());
    }

    double score = 0;
    final reasons = <String>[];
    final actions = <String>[];
    String category = 'Safe';

    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) {
      return {
        'score': 50.0,
        'category': 'Invalid URL',
        'reasons': ['Could not parse the provided URL'],
        'actions': ['Double-check the URL format'],
      };
    }

    final host = uri.host.toLowerCase();
    final fullUrl = url.toLowerCase();

    // ──── SSL Check ────
    if (!url.startsWith('https://')) {
      score += 15;
      reasons.add('⚠️ No HTTPS: Connection is not encrypted');
      actions.add('Look for the padlock icon and https:// prefix');
    }

    // ──── IP-based URL ────
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      score += 25;
      reasons.add('🔴 IP-based URL: Legitimate sites use domain names, not IP addresses');
      category = 'Phishing';
    }

    // ──── Excessive subdomains ────
    final parts = host.split('.');
    if (parts.length > 4) {
      score += 15;
      reasons.add('⚠️ Excessive subdomains: ${parts.length} domain levels detected');
    }

    // ──── Typosquatting Detection ────
    final typosquatResult = _checkTyposquatting(host);
    if (typosquatResult != null) {
      score += 30;
      reasons.add('🔴 Typosquatting detected: Similar to "${typosquatResult['target']}" (looks like a fake)');
      category = 'Phishing';
      actions.add('Verify the domain by typing it manually in your browser');
    }

    // ──── Suspicious Keywords ────
    final keywordHits = _checkSuspiciousKeywords(fullUrl);
    if (keywordHits.isNotEmpty) {
      score += keywordHits.length * 8;
      for (final kw in keywordHits) {
        reasons.add('⚠️ Suspicious keyword in URL: "$kw"');
      }
      if (keywordHits.length >= 2) category = 'Phishing';
    }

    // ──── URL Shortener ────
    if (_isUrlShortener(host)) {
      score += 10;
      reasons.add('ℹ️ URL shortener detected: Real destination is hidden');
      actions.add('Use a URL expander tool to see the real destination');
    }

    // ──── Suspicious TLD ────
    final tld = parts.isNotEmpty ? parts.last : '';
    if (_suspiciousTlds.contains(tld)) {
      score += 12;
      reasons.add('⚠️ Suspicious TLD: .$tld is commonly used for malicious sites');
    }

    // ──── Long URL ────
    if (url.length > 200) {
      score += 8;
      reasons.add('ℹ️ Unusually long URL: May contain hidden parameters');
    }

    // ──── Special characters ────
    if (fullUrl.contains('@') || fullUrl.contains('//') && fullUrl.indexOf('//', 8) > 0) {
      score += 15;
      reasons.add('🔴 Deceptive URL structure: Contains misleading characters');
      category = 'Phishing';
    }

    // ──── Determine final category ────
    if (score <= 10) {
      category = 'Safe';
      if (reasons.isEmpty) {
        reasons.add('✅ No suspicious indicators found');
      }
      actions.add('This URL appears safe to visit');
    } else if (score <= 30) {
      if (category == 'Safe') category = 'Low Risk';
      actions.add('Exercise caution when entering personal information');
    } else if (score <= 60) {
      if (category == 'Safe') category = 'Medium Risk';
      actions.add('Verify the website through official channels before proceeding');
    } else {
      if (category == 'Safe') category = 'High Risk';
      actions.add('Do NOT enter any personal information');
      actions.add('Close this website immediately');
    }

    score = score.clamp(0, 100);

    return {
      'score': score,
      'category': category,
      'reasons': reasons,
      'actions': actions,
    };
  }

  /// Check for typosquatting against known domains.
  static Map<String, String>? _checkTyposquatting(String host) {
    final targets = {
      'google': 'google.com',
      'facebook': 'facebook.com',
      'amazon': 'amazon.com',
      'paypal': 'paypal.com',
      'apple': 'apple.com',
      'microsoft': 'microsoft.com',
      'netflix': 'netflix.com',
      'instagram': 'instagram.com',
      'whatsapp': 'whatsapp.com',
      'twitter': 'twitter.com',
      'linkedin': 'linkedin.com',
      'youtube': 'youtube.com',
      'github': 'github.com',
      'wikipedia': 'wikipedia.org',
      'reddit': 'reddit.com',
      'spotify': 'spotify.com',
      'dropbox': 'dropbox.com',
      'yahoo': 'yahoo.com',
    };

    // Remove TLD for comparison
    final hostBase = host.replaceAll(RegExp(r'\.(com|org|net|io|co)$'), '');
    final hostParts = hostBase.split('.');
    final domainPart = hostParts.isNotEmpty ? hostParts.last : hostBase;

    for (final entry in targets.entries) {
      final brand = entry.key;
      final official = entry.value;

      // Skip if it IS the official domain
      if (host == official || host.endsWith('.$official')) continue;

      // Check Levenshtein distance
      final distance = _levenshtein(domainPart, brand);
      if (distance > 0 && distance <= 2) {
        return {'target': official, 'brand': brand};
      }

      // Check if brand name is embedded
      if (domainPart.contains(brand) && domainPart != brand) {
        return {'target': official, 'brand': brand};
      }
    }

    return null;
  }

  /// Levenshtein distance between two strings.
  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> previousRow = List.generate(b.length + 1, (i) => i);
    List<int> currentRow = List.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      currentRow[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        currentRow[j + 1] = [
          currentRow[j] + 1,
          previousRow[j + 1] + 1,
          previousRow[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[b.length];
  }

  /// Check for suspicious keywords in the URL.
  static List<String> _checkSuspiciousKeywords(String url) {
    final hits = <String>[];
    const keywords = [
      'login', 'signin', 'verify', 'account', 'update',
      'secure', 'banking', 'confirm', 'password', 'credential',
      'suspend', 'restrict', 'unusual', 'unauthorized', 'expire',
      'wallet', 'payment', 'invoice', 'reward', 'prize',
      'free', 'gift', 'offer', 'urgent', 'limited',
      'click-here', 'act-now', 'claim',
    ];

    for (final kw in keywords) {
      if (url.contains(kw)) hits.add(kw);
    }
    return hits;
  }

  /// Check if the host is a known URL shortener.
  static bool _isUrlShortener(String host) {
    const shorteners = [
      'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly',
      'is.gd', 'v.gd', 'buff.ly', 'j.mp', 'rb.gy',
      'cutt.ly', 'short.io', 'bl.ink', 'clck.ru', 's.id',
    ];
    return shorteners.contains(host);
  }

  /// Suspicious TLDs commonly used for phishing.
  static const _suspiciousTlds = [
    'tk', 'ml', 'ga', 'cf', 'gq', 'xyz', 'top', 'work',
    'click', 'link', 'buzz', 'surf', 'rest', 'icu',
  ];

  /// Specialized UPI Payment QR analysis & safety validation
  static Map<String, dynamic> _analyzeUpiPayment(String url) {
    double score = 0;
    final reasons = <String>[];
    final actions = <String>[];
    String category = 'Safe';

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return {
        'score': 40.0,
        'category': 'Medium Risk',
        'reasons': ['Malformed payment QR code format'],
        'actions': ['Do not scan or pay with unverified payment codes'],
      };
    }

    final queryParams = uri.queryParameters;
    final pa = queryParams['pa'] ?? '';
    final pn = queryParams['pn'] ?? '';
    final am = queryParams['am'];

    if (pa.isEmpty) {
      score += 45;
      category = 'Suspicious Payment';
      reasons.add('⚠️ Missing Payee VPA: Payment address is absent in QR');
      actions.add('Do not proceed with this unverified payment QR code');
    } else if (!pa.contains('@')) {
      score += 40;
      category = 'Suspicious Payment';
      reasons.add('⚠️ Invalid Payee Address: VPA format ($pa) does not match UPI standards');
      actions.add('Verify payee with the store or merchant before transferring funds');
    } else {
      reasons.add('✅ Valid UPI Payee VPA: $pa');
      if (pn.isNotEmpty) {
        reasons.add('✅ Merchant/Payee Name: $pn');
      }
      if (am != null && am.isNotEmpty) {
        reasons.add('💰 Requested Amount: ₹$am');
      }
      actions.add('Verify that recipient "$pn" matches the expected store before authorizing');
    }

    // Check for suspicious script injection or hidden phishing redirect in note
    final tn = queryParams['tn'] ?? '';
    if (tn.contains('http://') || tn.contains('https://') || tn.contains('.apk')) {
      score += 50;
      category = 'Phishing';
      reasons.add('🔴 Malicious link embedded inside payment note parameter');
      actions.add('Cancel payment immediately');
    }

    if (score == 0) {
      category = 'Safe';
      actions.add('Safe to proceed to payment app');
    }

    return {
      'score': score,
      'category': category,
      'reasons': reasons,
      'actions': actions,
    };
  }
}
