import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../ai_engine/services/gemini_ai_service.dart';

class ScamReportEntity {
  final String id;
  final String title;
  final String description;
  final String type;
  final String user;
  final DateTime time;
  final int upvotes;
  final int comments;
  final bool isVerified;
  final String? scammerContact;
  final String? maliciousUrl;
  final String? aiAnalysis;

  const ScamReportEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.user,
    required this.time,
    this.upvotes = 1,
    this.comments = 0,
    this.isVerified = true,
    this.scammerContact,
    this.maliciousUrl,
    this.aiAnalysis,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'user': user,
      'time': time.toIso8601String(),
      'upvotes': upvotes,
      'comments': comments,
      'isVerified': isVerified,
      'scammerContact': scammerContact,
      'maliciousUrl': maliciousUrl,
      'aiAnalysis': aiAnalysis,
    };
  }

  factory ScamReportEntity.fromMap(Map<String, dynamic> map) {
    return ScamReportEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'Phishing',
      user: map['user'] ?? 'Verified User',
      time: DateTime.tryParse(map['time'] ?? '') ?? DateTime.now(),
      upvotes: map['upvotes'] ?? 0,
      comments: map['comments'] ?? 0,
      isVerified: map['isVerified'] ?? true,
      scammerContact: map['scammerContact'],
      maliciousUrl: map['maliciousUrl'],
      aiAnalysis: map['aiAnalysis'],
    );
  }

  ScamReportEntity copyWith({
    int? upvotes,
    int? comments,
    bool? isVerified,
    String? aiAnalysis,
  }) {
    return ScamReportEntity(
      id: id,
      title: title,
      description: description,
      type: type,
      user: user,
      time: time,
      upvotes: upvotes ?? this.upvotes,
      comments: comments ?? this.comments,
      isVerified: isVerified ?? this.isVerified,
      scammerContact: scammerContact,
      maliciousUrl: maliciousUrl,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }
}

class ScamCommunityState {
  final List<ScamReportEntity> reports;
  final String searchQuery;
  final String selectedCategory; // 'Trending', 'Phishing', etc.
  final bool isLoading;

  const ScamCommunityState({
    required this.reports,
    this.searchQuery = '',
    this.selectedCategory = 'Trending',
    this.isLoading = false,
  });

  ScamCommunityState copyWith({
    List<ScamReportEntity>? reports,
    String? searchQuery,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return ScamCommunityState(
      reports: reports ?? this.reports,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<ScamReportEntity> get filteredReports {
    var filtered = reports;

    // Filter by Category
    if (selectedCategory != 'Trending') {
      filtered = filtered.where((r) => r.type == selectedCategory).toList();
    } else {
      // Trending: sort by upvotes
      filtered = List.from(filtered)..sort((a, b) => b.upvotes.compareTo(a.upvotes));
    }

    // Filter by Search Query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((r) =>
          r.title.toLowerCase().contains(query) ||
          r.description.toLowerCase().contains(query) ||
          (r.maliciousUrl?.toLowerCase().contains(query) ?? false) ||
          (r.scammerContact?.toLowerCase().contains(query) ?? false)).toList();
    }

    return filtered;
  }
}

class ScamCommunityNotifier extends StateNotifier<ScamCommunityState> {
  ScamCommunityNotifier() : super(const ScamCommunityState(reports: [], isLoading: true)) {
    loadUserReports();
  }

  static const String _storageKey = 'user_community_reports_v2';

  /// Load purely user-submitted reports from local persistent storage & Firestore
  Future<void> loadUserReports() async {
    state = state.copyWith(isLoading: true);
    final List<ScamReportEntity> loadedReports = [];

    // 1. Try local storage first for offline speed
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = json.decode(jsonStr);
        loadedReports.addAll(decoded.map((e) => ScamReportEntity.fromMap(Map<String, dynamic>.from(e))));
      }
    } catch (_) {}

    // 2. Try Firestore sync
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('community_reports')
          .orderBy('time', descending: true)
          .limit(50)
          .get()
          .timeout(const Duration(seconds: 4));

      if (snapshot.docs.isNotEmpty) {
        final remoteReports = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ScamReportEntity.fromMap(data);
        }).toList();

        // Merge without duplicates
        for (final r in remoteReports) {
          if (!loadedReports.any((item) => item.id == r.id)) {
            loadedReports.add(r);
          }
        }
      }
    } catch (_) {}

    state = state.copyWith(reports: loadedReports, isLoading: false);
  }

  Future<void> addReport(ScamReportEntity report) async {
    // Generate AI Verification & Threat Analysis
    String? aiVerification;
    try {
      final res = await GeminiAiService.instance.queryGeminiChat(
        conversationHistory: [],
        userPrompt: '''Perform a concise cybersecurity threat verification for this user scam report:
Title: ${report.title}
Category: ${report.type}
Description: ${report.description}
Indicators: ${report.maliciousUrl ?? ""} ${report.scammerContact ?? ""}

Verify the attack pattern, list warning flags, and provide 2 bullet points of immediate victim mitigation advice.''',
      );
      aiVerification = res.text;
    } catch (_) {}

    final finalizedReport = report.copyWith(aiAnalysis: aiVerification);
    final updatedList = [finalizedReport, ...state.reports];
    state = state.copyWith(reports: updatedList);

    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(updatedList.map((r) => r.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}

    // Push to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('community_reports')
          .doc(finalizedReport.id)
          .set(finalizedReport.toMap());
    } catch (_) {}
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> upvoteReport(String id) async {
    final updated = state.reports.map((r) {
      if (r.id == id) return r.copyWith(upvotes: r.upvotes + 1);
      return r;
    }).toList();
    state = state.copyWith(reports: updated);

    // Save
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(updated.map((r) => r.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }
}

final scamCommunityProvider = StateNotifierProvider<ScamCommunityNotifier, ScamCommunityState>((ref) {
  return ScamCommunityNotifier();
});
