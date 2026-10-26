import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadowwall_ai/core/services/audit_report_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuditReportService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('AuditReportService saves and retrieves genuine reports', () async {
      final service = AuditReportService.instance;
      
      final report = CyberAuditReport(
        id: 'TEST-AUD-001',
        title: 'Unit Test Device Audit',
        category: 'Device',
        securityScore: 92.0,
        itemsAudited: 20,
        vulnerabilitiesFound: 1,
        keyFindings: ['Test key finding'],
        executiveSummary: 'Test executive summary',
        timestamp: DateTime.now(),
      );

      await service.saveReport(report);
      final retrieved = await service.getReports();

      expect(retrieved.any((r) => r.id == 'TEST-AUD-001'), isTrue);
      expect(retrieved.firstWhere((r) => r.id == 'TEST-AUD-001').securityScore, equals(92.0));
    });

    test('AuditReport serialization roundtrip preserves all fields', () {
      final report = CyberAuditReport(
        id: 'TEST-002',
        title: 'APK Audit',
        category: 'APK',
        securityScore: 45.0,
        itemsAudited: 15,
        vulnerabilitiesFound: 3,
        keyFindings: ['Finding A', 'Finding B'],
        executiveSummary: 'Summary text',
        timestamp: DateTime.parse('2026-08-28T12:00:00.000Z'),
      );

      final map = report.toMap();
      final fromMap = CyberAuditReport.fromMap(map);

      expect(fromMap.id, equals(report.id));
      expect(fromMap.securityScore, equals(report.securityScore));
      expect(fromMap.keyFindings, equals(report.keyFindings));
    });
  });
}
