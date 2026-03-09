import 'package:flutter/material.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';

class ScanHistoryPage extends StatelessWidget {
  const ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <Map<String, String>>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanHistory),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('暂无识别记录', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['time'] ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: items.length,
            ),
    );
  }
}
