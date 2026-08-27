import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../providers/scam_community_provider.dart';
import 'dart:math';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Phishing';

  final List<String> _categories = [
    'Phishing',
    'Calls/SMS',
    'Social Media',
    'Crypto',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields'), backgroundColor: AppColors.danger)
      );
      return;
    }

    final newReport = ScamReportEntity(
      id: Random().nextInt(10000).toString(), // Mock ID
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _selectedCategory,
      user: 'You',
      time: DateTime.now(),
      upvotes: 1, // Start with own upvote
      comments: 0,
      isVerified: false, // New reports are unverified
    );

    ref.read(scamCommunityProvider.notifier).addReport(newReport);
    context.pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scam report submitted!'), backgroundColor: AppColors.neonGreen)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(title: 'Report Scam', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Help protect the community', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
              const SizedBox(height: 8),
              Text('Share details about a scam you encountered.', style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant)),
              const SizedBox(height: 24),

              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                      decoration: InputDecoration(
                        hintText: 'e.g. Fake Bank Security Alert',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryCyan),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Category', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: AppColors.darkSurfaceVariant,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedCategory = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Description', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 5,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                      decoration: InputDecoration(
                        hintText: 'Describe how the scam works, what they asked for, and how to spot it...',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryCyan),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Submit Report',
                      icon: Icons.send_rounded,
                      onPressed: _submitReport,
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
