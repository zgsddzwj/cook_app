import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLastUpdated(),
          const SizedBox(height: 16),
          _buildIntroduction(),
          const SizedBox(height: 16),
          _buildSection(
            'Information We Collect',
            [
              _buildSubSection('Personal Information',
                  'We do not require you to create an account to use SnapCook. If you choose to set a profile, we store your display name and avatar locally on your device.'),
              _buildSubSection('Photos',
                  'When you use the ingredient recognition feature, photos you take or select are processed to identify ingredients. Photos are temporarily processed by our AI service and are not permanently stored.'),
              _buildSubSection('Usage Data',
                  'We collect anonymized usage statistics to improve app performance and user experience. This includes feature usage frequency and app crash reports.'),
              _buildSubSection('Device Information',
                  'We collect device type, operating system version, and app version to ensure compatibility and troubleshoot issues.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'How We Use Your Information',
            [
              _buildSubSection('Core Features',
                  'Photos are used solely for ingredient recognition to provide recipe recommendations. Your pantry inventory is stored locally on your device.'),
              _buildSubSection('AI Processing',
                  'Ingredient photos are sent to OpenAI for analysis. OpenAI processes this data in accordance with their privacy policy. We do not retain your photos after processing.'),
              _buildSubSection('Recipe Data',
                  'Recipe information is retrieved from TheMealDB, a third-party recipe database.'),
              _buildSubSection('App Improvement',
                  'Anonymized usage data helps us understand which features are popular and identify bugs.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Third-Party Services',
            [
              _buildSubSection('OpenAI',
                  'We use OpenAI\'s API for ingredient recognition. Images you upload are sent to OpenAI\'s servers in the United States for processing. OpenAI does not use your data to train their models. See OpenAI\'s Privacy Policy: openai.com/privacy'),
              _buildSubSection('TheMealDB',
                  'Recipe data is provided by TheMealDB (themealdb.com), hosted in the United Kingdom.'),
              _buildSubSection('Unsplash',
                  'Ingredient images are loaded from Unsplash (unsplash.com), hosted in the United States.'),
              _buildSubSection('Analytics',
                  'We may use Firebase Analytics or similar services to collect anonymized usage statistics.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Data Storage and Security',
            [
              _buildSubSection('Local Storage',
                  'Your pantry inventory, favorites, and preferences are stored locally on your device using secure storage mechanisms provided by iOS.'),
              _buildSubSection('Data Retention',
                  'Photos sent for ingredient recognition are processed in real-time and not retained on our servers. Scan history is stored locally on your device only.'),
              _buildSubSection('Security Measures',
                  'We use industry-standard encryption (HTTPS/TLS) for all data transmissions.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Your Rights',
            [
              _buildSubSection('Access and Control',
                  'You can view, edit, or delete your locally stored data at any time through the app settings.'),
              _buildSubSection('Data Deletion',
                  'To delete all your data, simply uninstall the app. All local data will be permanently removed.'),
              _buildSubSection('Opt-Out',
                  'You can disable analytics collection in the app settings. You can also choose to use Local AI mode for ingredient recognition, which processes images entirely on your device.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'California Privacy Rights (CCPA)',
            [
              _buildSubSection('Your CCPA Rights',
                  'If you are a California resident, you have the right to: (1) know what personal information is collected, (2) delete personal information, (3) opt-out of the sale of personal information. We do not sell personal information.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Children\'s Privacy',
            [
              _buildSubSection('COPPA Compliance',
                  'SnapCook is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Changes to This Policy',
            [
              _buildSubSection('Policy Updates',
                  'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy in the app. Changes are effective when posted.'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Contact Us',
            [
              _buildSubSection('Questions or Concerns',
                  'If you have any questions about this Privacy Policy or our data practices, please contact us at:\n\nEmail: support@snapcook.app\n\nWe aim to respond to all inquiries within 48 hours.'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Last Updated: March 14, 2025',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Text(
        'SnapCook ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.\n\nBy using SnapCook, you agree to the collection and use of information in accordance with this policy.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
