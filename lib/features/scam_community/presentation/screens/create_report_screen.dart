import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../providers/scam_community_provider.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedCategory = 'Phishing';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Phishing',
    'Fake Banking',
    'Calls/SMS',
    'Social Media',
    'Crypto Scam',
    'Malware APK',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _urlController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out the incident title and narrative.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final newReport = ScamReportEntity(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _selectedCategory,
      user: 'Verified Defender',
      time: DateTime.now(),
      upvotes: 1,
      comments: 0,
      isVerified: true,
      maliciousUrl: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
      scammerContact: _contactController.text.trim().isNotEmpty ? _contactController.text.trim() : null,
    );

    await ref.read(scamCommunityProvider.notifier).addReport(newReport);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    context.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🛡️ Scam incident published to Community Watch with AI verification!'),
        backgroundColor: AppColors.neonGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(title: 'Report Cyber Scam', subtitle: 'Warn fellow defenders', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Protect Fellow Users', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
              const SizedBox(height: 6),
              Text(
                'Submit an authentic scam or attack you encountered. Our AI engine will verify indicators and alert the community.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
              ),
              const SizedBox(height: 20),

              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Threat Category
                    Text('Attack Category', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: AppColors.darkSurface,
                          style: const TextStyle(color: AppColors.darkOnSurface, fontSize: 14),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Incident Title
                    Text('Incident Title', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                      decoration: InputDecoration(
                        hintText: 'e.g. Fake Bank SMS with KYC Suspension Link',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryCyan),
                        ),
                        filled: true,
                        fillColor: AppColors.darkSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Narrative
                    Text('Encounter Details & Narrative', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                      decoration: InputDecoration(
                        hintText: 'Describe exactly how the scam happened, what the attackers demanded, and warning flags you noticed...',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryCyan),
                        ),
                        filled: true,
                        fillColor: AppColors.darkSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Malicious URL (IoC)
                    Text('Malicious URL / Domain (Optional)', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                      decoration: InputDecoration(
                        hintText: 'e.g. https://secure-bank-update.xyz/login',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryCyan),
                        ),
                        filled: true,
                        fillColor: AppColors.darkSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scammer Contact (IoC)
                    Text('Scammer Phone / Email / Handle (Optional)', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contactController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                      decoration: InputDecoration(
                        hintText: 'e.g. +1 555-019-2834 or @fake_support_bot',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryCyan),
                        ),
                        filled: true,
                        fillColor: AppColors.darkSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    GradientButton(
                      label: _isSubmitting ? 'Submitting to AI Engine...' : 'Publish Scam Incident',
                      icon: Icons.shield_outlined,
                      gradient: AppColors.primaryGradient,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submitReport,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
