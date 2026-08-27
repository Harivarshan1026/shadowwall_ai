/// Scan History / Cyber Reports screen.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class CyberReportsScreen extends StatelessWidget {
  const CyberReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CyberAppBar(title: 'Scan History', showBack: true),
      body: Center(
        child: Text(
          'All Scan History',
          style: TextStyle(color: AppColors.darkOnSurface),
        ),
      ),
      backgroundColor: AppColors.darkSurface,
    );
  }
}
