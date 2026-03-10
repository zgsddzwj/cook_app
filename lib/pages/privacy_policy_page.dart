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
              '我们尊重并保护你的个人信息与隐私安全。\n\n'
              '1. 我们可能收集的信息\n'
              '• 账号信息：如用户名、邮箱（如你主动填写）。\n'
              '• 设备信息：用于提升稳定性与兼容性（如设备型号、系统版本）。\n'
              '• 使用数据：用于改进功能体验（如页面访问、功能点击）。\n\n'
              '2. 我们如何使用信息\n'
              '• 提供与优化核心功能（食谱推荐、食材管理、收藏等）。\n'
              '• 排查故障与提升性能。\n'
              '• 在获得授权的情况下提供个性化体验。\n\n'
              '3. 信息共享\n'
              '我们不会出售你的个人信息。仅在法律法规要求、或为提供服务所必需（如第三方基础服务）时，可能共享最小必要信息。\n\n'
              '4. 你的权利\n'
              '你可以随时查看、修改或删除你的个人信息（如应用内支持）。\n\n'
              '5. 联系我们\n'
              '如你对隐私政策有任何疑问，请通过应用内反馈与我们联系。',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: '权限说明',
            child: const Text(
              '相机/相册：用于拍照或选择图片进行食材识别。\n'
              '网络：用于获取图片资源与在线服务。\n',
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

