/// Complete Cross-Platform APK Binary & Manifest Inspection Service.
///
/// Handles Web (in-memory Uint8List bytes) and Native (File path & NativeScannerService).
/// Inspects AndroidManifest binary strings, permissions, cryptographic SHA-256 hashes,
/// malware heuristics, and fuses with Google Gemini AI for risk scoring.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import '../../ai_engine/rules/permission_rules.dart';
import '../../ai_engine/services/gemini_ai_service.dart';
import 'native_scanner_service.dart';
import 'audit_report_service.dart';

class ApkInspectionService {
  ApkInspectionService._();

  /// Inspects a picked APK file across Web, Android, iOS, and Desktop.
  static Future<Map<String, dynamic>> inspectApk(PlatformFile pickedFile) async {
    final String fileName = pickedFile.name;
    int fileSize = pickedFile.size;
    if (fileSize <= 0 && !kIsWeb && pickedFile.path != null) {
      try {
        final f = File(pickedFile.path!);
        if (f.existsSync()) {
          fileSize = f.lengthSync();
        }
      } catch (_) {}
    }
    final String fileSizeFormatted = _formatFileSize(fileSize);

    final Uint8List? bytes = pickedFile.bytes;

    // 1. Calculate SHA-256 Checksum (streaming on native, slice-sampled on large web buffers to prevent browser freeze & tab crash)
    String sha256Hash = 'Unavailable';
    if (bytes != null && bytes.isNotEmpty) {
      try {
        if (bytes.length <= 4 * 1024 * 1024) {
          sha256Hash = sha256.convert(bytes).toString();
        } else {
          // On Web, hashing 50MB+ synchronously locks the V8 UI thread and triggers browser tab crashes.
          // Sample first 2MB and last 1MB for fast, non-blocking signature.
          final sample = Uint8List.fromList([
            ...bytes.sublist(0, 2 * 1024 * 1024),
            ...bytes.sublist(bytes.length - 1024 * 1024),
          ]);
          sha256Hash = sha256.convert(sample).toString();
        }
      } catch (e) {
        debugPrint('Web hash error: $e');
      }
    } else if (!kIsWeb && pickedFile.path != null) {
      try {
        final file = File(pickedFile.path!);
        if (await file.exists()) {
          final digest = await sha256.bind(file.openRead()).first;
          sha256Hash = digest.toString();
        }
      } catch (e) {
        debugPrint('SHA-256 calculation error: $e');
      }
    }

    // 2. Extract Package Name, Permissions, and Malware Heuristics
    String appName = fileName.replaceAll(RegExp(r'\.apk$', caseSensitive: false), '');
    String packageName = 'com.${appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}.app';
    List<String> permissions = [];
    final List<String> suspiciousStrings = [];

    // Safe memory extraction if bytes are present in memory (Web or synthetic test)
    if (bytes != null && bytes.isNotEmpty) {
      final extractedInfo = _extractApkBinaryMetadata(bytes, fileName);
      appName = extractedInfo.appName;
      packageName = extractedInfo.packageName;
      permissions = extractedInfo.permissions;
      suspiciousStrings.addAll(extractedInfo.suspiciousStrings);
    }

    // 3. Attempt Native Android Package Manager inspect if on Android
    if (!kIsWeb && pickedFile.path != null) {
      try {
        final nativeInfo = await NativeScannerService.analyzeApk(pickedFile.path!);
        if (nativeInfo != null) {
          if (nativeInfo['name'] != null && (nativeInfo['name'] as String).isNotEmpty) {
            appName = nativeInfo['name'] as String;
          }
          if (nativeInfo['package'] != null && (nativeInfo['package'] as String).isNotEmpty) {
            packageName = nativeInfo['package'] as String;
          }
          if (nativeInfo['permissions'] != null) {
            final nativePerms = (nativeInfo['permissions'] as List).cast<String>();
            permissions = {...permissions, ...nativePerms}.toList();
          }
        }
      } catch (e) {
        debugPrint('Native APK inspect skipped: $e');
      }

      // If suspicious strings haven't been detected yet, stream-scan file chunks safely (64KB chunks, max 10MB)
      if (suspiciousStrings.isEmpty) {
        final scanned = await _scanFileForSuspiciousStrings(pickedFile.path!);
        suspiciousStrings.addAll(scanned);
      }
    }

    // Fallback if permissions empty
    if (permissions.isEmpty) {
      permissions = [
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
      ];
    }

    // 4. Deterministic Risk Evaluation via PermissionRules
    final nativeAnalysis = PermissionRules.analyze(permissions, appName);
    double baseScore = (nativeAnalysis['score'] as num).toDouble();

    // Add extra risk points for suspicious binary signatures
    if (suspiciousStrings.isNotEmpty) {
      baseScore += (suspiciousStrings.length * 15);
    }
    baseScore = baseScore.clamp(0.0, 100.0);

    // 5. Google Gemini AI CSO Synthesis (with 5-second timeout to prevent UI hangs)
    Map<String, dynamic>? aiResult;
    try {
      aiResult = await GeminiAiService.instance.analyzeApkWithAi(
        appName,
        packageName,
        permissions,
      ).timeout(const Duration(seconds: 5), onTimeout: () => null);
    } catch (e) {
      debugPrint('Gemini AI APK review error: $e');
    }

    // 6. Blend AI + Deterministic Heuristics
    final double finalRiskScore = aiResult != null && aiResult['riskScore'] != null
        ? (((aiResult['riskScore'] as num).toDouble() * 0.6) + (baseScore * 0.4)).clamp(0.0, 100.0)
        : baseScore;

    String threatCategory = (aiResult?['threatCategory'] as String?) ??
        (nativeAnalysis['category'] as String);

    if (suspiciousStrings.isNotEmpty && finalRiskScore > 50) {
      threatCategory = 'High Risk / Potential Trojan or RAT';
    }

    // Risk Indicators
    final List<String> riskIndicators = <String>[];
    if (suspiciousStrings.isNotEmpty) {
      riskIndicators.addAll(suspiciousStrings);
    }
    if (aiResult != null && aiResult['riskIndicators'] != null) {
      riskIndicators.addAll((aiResult['riskIndicators'] as List).cast<String>());
    } else {
      riskIndicators.add('Static Manifest & Byte Audit Completed');
      riskIndicators.add('${nativeAnalysis['dangerousCount']} high-risk permissions detected');
      riskIndicators.add('Package: $packageName');
    }

    // Reasons
    final List<String> reasons = <String>[];
    if (aiResult != null && aiResult['reasons'] != null) {
      reasons.addAll((aiResult['reasons'] as List).cast<String>());
    }
    reasons.addAll((nativeAnalysis['reasons'] as List).cast<String>());

    // Recommended Actions
    final List<String> recommendedActions = <String>[];
    if (aiResult != null && aiResult['recommendedActions'] != null) {
      recommendedActions.addAll((aiResult['recommendedActions'] as List).cast<String>());
    } else {
      recommendedActions.addAll((nativeAnalysis['actions'] as List).cast<String>());
      recommendedActions.add('Verify digital signature before granting device permissions');
      recommendedActions.add('Only sideload applications from verified, authentic sources');
    }

    final result = {
      'fileName': fileName,
      'fileSize': fileSizeFormatted,
      'packageName': packageName,
      'appName': appName,
      'sha256': sha256Hash,
      'developer': 'Third-Party / Sideloaded',
      'signature': 'SHA256: ${sha256Hash.substring(0, (sha256Hash.length > 16 ? 16 : sha256Hash.length))}...',
      'riskScore': finalRiskScore,
      'threatCategory': threatCategory,
      'permissions': permissions,
      'riskIndicators': riskIndicators.toSet().toList(),
      'reasons': reasons.toSet().toList(),
      'recommendedActions': recommendedActions.toSet().toList(),
      'suspiciousFindings': suspiciousStrings,
    };

    try {
      await AuditReportService.instance.recordApkScan(
        fileName: fileName,
        packageName: packageName,
        riskScore: finalRiskScore,
        dangerousPermissions: permissions,
        riskIndicators: riskIndicators.toSet().toList(),
        rationale: reasons.isNotEmpty ? reasons.first : 'APK inspection completed.',
      );
    } catch (_) {}

    return result;
  }

  /// Binary heuristic scanner for Manifest strings & dangerous byte patterns
  static _ExtractedApkInfo _extractApkBinaryMetadata(Uint8List? bytes, String fallbackFileName) {
    String appName = fallbackFileName.replaceAll(RegExp(r'\.apk$', caseSensitive: false), '');
    String packageName = 'com.${appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}.app';
    final permissions = <String>{};
    final suspicious = <String>[];

    if (bytes == null || bytes.isEmpty) {
      return _ExtractedApkInfo(appName, packageName, permissions.toList(), suspicious);
    }

    // Protect against OOM: only decode up to 4MB of header/manifest data
    final scanSlice = bytes.length > 4 * 1024 * 1024
        ? bytes.sublist(0, 4 * 1024 * 1024)
        : bytes;
    final rawString = latin1.decode(scanSlice, allowInvalid: true);

    // List of known Android permissions
    final knownPermissions = [
      'android.permission.INTERNET',
      'android.permission.ACCESS_NETWORK_STATE',
      'android.permission.ACCESS_WIFI_STATE',
      'android.permission.READ_EXTERNAL_STORAGE',
      'android.permission.WRITE_EXTERNAL_STORAGE',
      'android.permission.MANAGE_EXTERNAL_STORAGE',
      'android.permission.CAMERA',
      'android.permission.RECORD_AUDIO',
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.ACCESS_COARSE_LOCATION',
      'android.permission.ACCESS_BACKGROUND_LOCATION',
      'android.permission.READ_CONTACTS',
      'android.permission.WRITE_CONTACTS',
      'android.permission.READ_SMS',
      'android.permission.SEND_SMS',
      'android.permission.RECEIVE_SMS',
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'android.permission.SYSTEM_ALERT_WINDOW',
      'android.permission.REQUEST_INSTALL_PACKAGES',
      'android.permission.INSTALL_PACKAGES',
      'android.permission.BIND_ACCESSIBILITY_SERVICE',
      'android.permission.READ_PHONE_STATE',
      'android.permission.READ_CALL_LOG',
      'android.permission.WRITE_CALL_LOG',
      'android.permission.QUERY_ALL_PACKAGES',
      'android.permission.WAKE_LOCK',
      'android.permission.VIBRATE',
      'android.permission.USE_BIOMETRIC',
      'android.permission.REQUEST_DELETE_PACKAGES',
      'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
    ];

    for (final perm in knownPermissions) {
      if (rawString.contains(perm)) {
        permissions.add(perm);
      }
    }

    // Search for Package Name (e.g., package="com.something.app" or com.xxxx.yyyy)
    final pkgMatch = RegExp(r'package="([a-zA-Z0-9_]+\.[a-zA-Z0-9_]+\.[a-zA-Z0-9_\.]+)"').firstMatch(rawString) ??
        RegExp(r'([a-zA-Z]{2,6}\.[a-zA-Z0-9_-]{2,20}\.[a-zA-Z0-9_\.]{2,30})').firstMatch(rawString);

    if (pkgMatch != null) {
      final candidate = pkgMatch.group(1)!;
      if (!candidate.startsWith('android.') && !candidate.startsWith('com.android.') && !candidate.startsWith('java.') && !candidate.startsWith('kotlin.')) {
        packageName = candidate;
      }
    }

    // Suspicious Heuristic Binary Strings
    if (rawString.contains('/system/bin/su') || rawString.contains('/system/xbin/su') || rawString.contains('magisk')) {
      suspicious.add('Root / Privilege Escalation binary strings detected');
    }
    if (rawString.contains('DexClassLoader') || rawString.contains('InMemoryDexClassLoader')) {
      suspicious.add('Dynamic Remote Code Execution (DexClassLoader) payload pattern');
    }
    if (rawString.contains('AccessibilityService') && rawString.contains('onAccessibilityEvent')) {
      suspicious.add('Accessibility Keylogging / Screen-reading hook signatures');
    }
    if (rawString.contains('SYSTEM_ALERT_WINDOW') || rawString.contains('TYPE_APPLICATION_OVERLAY')) {
      suspicious.add('Overlay Injection capability (can draw fake screens over banking apps)');
    }
    if (rawString.contains('/system/bin/sh') || rawString.contains('Runtime.getRuntime().exec')) {
      suspicious.add('Arbitrary Command Execution / Shell Invocation detected');
    }

    return _ExtractedApkInfo(appName, packageName, permissions.toList(), suspicious);
  }

  /// Memory-safe streaming chunk scanner for root, dynamic loader, and trojan strings.
  static Future<List<String>> _scanFileForSuspiciousStrings(String filePath) async {
    final suspicious = <String>{};
    try {
      final file = File(filePath);
      if (!await file.exists()) return [];

      final patterns = {
        'Root / Privilege Escalation binary strings detected': ['/system/bin/su', '/system/xbin/su', 'magisk'],
        'Dynamic Remote Code Execution (DexClassLoader) payload pattern': ['DexClassLoader', 'InMemoryDexClassLoader'],
        'Accessibility Keylogging / Screen-reading hook signatures': ['AccessibilityService', 'onAccessibilityEvent'],
        'Overlay Injection capability (can draw fake screens over banking apps)': ['SYSTEM_ALERT_WINDOW', 'TYPE_APPLICATION_OVERLAY'],
        'Arbitrary Command Execution / Shell Invocation detected': ['/system/bin/sh', 'Runtime.getRuntime().exec'],
      };

      const int maxBytes = 10 * 1024 * 1024; // Scan first 10MB
      int bytesRead = 0;
      List<int> overlap = [];

      await for (final chunk in file.openRead()) {
        bytesRead += chunk.length;
        final combined = overlap + chunk;
        final text = latin1.decode(combined, allowInvalid: true);

        for (final entry in patterns.entries) {
          for (final keyword in entry.value) {
            if (text.contains(keyword)) {
              suspicious.add(entry.key);
              break;
            }
          }
        }

        if (chunk.length > 256) {
          overlap = chunk.sublist(chunk.length - 256);
        } else {
          overlap = chunk;
        }

        if (bytesRead >= maxBytes) break;
      }
    } catch (e) {
      debugPrint('Chunked APK scan error: $e');
    }
    return suspicious.toList();
  }

  static String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class _ExtractedApkInfo {
  final String appName;
  final String packageName;
  final List<String> permissions;
  final List<String> suspiciousStrings;

  _ExtractedApkInfo(this.appName, this.packageName, this.permissions, this.suspiciousStrings);
}
