import 'package:flutter/material.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Card(
            title: l10n.privacyPolicy,
            child: const Text(
              'We respect and protect your personal information and privacy.\n\n'
              '1. Information We May Collect\n'
              '• Account Info: Username, email (if provided).\n'
              '• Device Info: For stability and compatibility (device model, OS version).\n'
              '• Usage Data: For improving features (page visits, clicks).\n\n'
              '2. How We Use Information\n'
              '• Provide and optimize core features (recipe recommendations, pantry management, favorites).\n'
              '• Troubleshoot and improve performance.\n'
              '• Personalize experience with your consent.\n\n'
              '3. Information Sharing\n'
              'We do not sell your personal information. We only share minimal necessary information when required by law or essential for service provision.\n\n'
              '4. Your Rights\n'
              'You can view, modify, or delete your personal information at any time via in-app support.\n\n'
              '5. Contact Us\n'
              'If you have questions about this privacy policy, contact us via in-app feedback.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Permissions',
            child: const Text(
              'Camera/Gallery: For taking photos or selecting images to identify ingredients.\n'
              'Network: For accessing image resources and online services.\n',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
