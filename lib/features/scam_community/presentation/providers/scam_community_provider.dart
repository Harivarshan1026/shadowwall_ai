import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const ScamReportEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.user,
    required this.time,
    this.upvotes = 0,
    this.comments = 0,
    this.isVerified = false,
  });

  ScamReportEntity copyWith({
    int? upvotes,
    int? comments,
    bool? isVerified,
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
    );
  }
}

class ScamCommunityState {
  final List<ScamReportEntity> reports;
  final String searchQuery;
  final String selectedCategory; // 'Trending', 'Phishing', etc.

  const ScamCommunityState({
    required this.reports,
    this.searchQuery = '',
    this.selectedCategory = 'Trending',
  });

  ScamCommunityState copyWith({
    List<ScamReportEntity>? reports,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ScamCommunityState(
      reports: reports ?? this.reports,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  // Derived filtered list
  List<ScamReportEntity> get filteredReports {
    var filtered = reports;

    // Filter by Category
    if (selectedCategory != 'Trending') {
      filtered = filtered.where((r) => r.type == selectedCategory).toList();
    } else {
      // Trending logic: sort by upvotes
      filtered = List.from(filtered)..sort((a, b) => b.upvotes.compareTo(a.upvotes));
    }

    // Filter by Search Query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((r) => 
        r.title.toLowerCase().contains(query) || 
        r.description.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

class ScamCommunityNotifier extends StateNotifier<ScamCommunityState> {
  ScamCommunityNotifier() : super(_initialState());

  static ScamCommunityState _initialState() {
    return ScamCommunityState(
      reports: [
        ScamReportEntity(
          id: '1',
          title: 'Fake Banking SMS with link',
          description: 'Received an SMS claiming my bank account is locked. It has a suspicious bit.ly link.',
          type: 'Phishing',
          user: 'CyberHero_99',
          time: DateTime.now().subtract(const Duration(minutes: 45)),
          upvotes: 124,
          comments: 12,
          isVerified: true,
        ),
        ScamReportEntity(
          id: '2',
          title: 'WhatsApp Crypto Investment Scam',
          description: 'A stranger messaged me offering 500% returns on crypto in 24 hours. SCAM.',
          type: 'Crypto',
          user: 'AnonShield',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          upvotes: 89,
          comments: 5,
          isVerified: false,
        ),
        ScamReportEntity(
          id: '3',
          title: 'Electricity Bill Update Scam Call',
          description: 'Caller threatened to cut power in 30 minutes if I didn\'t pay via Zelle.',
          type: 'Calls/SMS',
          user: 'SafeNet21',
          time: DateTime.now().subtract(const Duration(hours: 5)),
          upvotes: 210,
          comments: 34,
          isVerified: true,
        ),
        ScamReportEntity(
          id: '4',
          title: 'Fake Job Offer on LinkedIn',
          description: 'Got an offer for a job I never applied to, asking for a \$50 "equipment fee" upfront.',
          type: 'Social Media',
          user: 'JobSeeker01',
          time: DateTime.now().subtract(const Duration(days: 1)),
          upvotes: 56,
          comments: 8,
          isVerified: false,
        ),
      ],
    );
  }

  void addReport(ScamReportEntity report) {
    state = state.copyWith(reports: [report, ...state.reports]);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void upvoteReport(String id) {
    final updated = state.reports.map((r) {
      if (r.id == id) return r.copyWith(upvotes: r.upvotes + 1);
      return r;
    }).toList();
    state = state.copyWith(reports: updated);
  }
}

final scamCommunityProvider = StateNotifierProvider<ScamCommunityNotifier, ScamCommunityState>((ref) {
  return ScamCommunityNotifier();
});
