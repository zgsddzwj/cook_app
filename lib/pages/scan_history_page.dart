import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/scan_history_provider.dart';
import 'ingredient_confirmation_page.dart';

class ScanHistoryPage extends StatelessWidget {
  const ScanHistoryPage({super.key});

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString();
    final m = _twoDigits(dt.month);
    final d = _twoDigits(dt.day);
    final h = _twoDigits(dt.hour);
    final min = _twoDigits(dt.minute);
    return '$y-$m-$d $h:$min';
  }

  String _formatIngredients(List<String> names) {
    if (names.isEmpty) return '';
    final take = names.take(3).toList();
    final text = take.join('、');
    if (names.length <= 3) return text;
    return '$text…';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = Provider.of<ScanHistoryProvider>(context).entries;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.scanHistory),
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(l10n.noScanHistory, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final ingredientNames = entry.ingredients.map((e) => e.name).toList();
                return Container(
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        entry.thumbnailBytes,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: Icon(Icons.image_outlined, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      '${l10n.recognizedIngredients} · ${entry.ingredients.length}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ingredientNames.isNotEmpty)
                            Text(
                              _formatIngredients(ingredientNames),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDateTime(entry.createdAt),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IngredientConfirmationPage(
                            imagePaths: [entry.imagePath],
                            initialIngredients: entry.ingredients,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      Provider.of<ScanHistoryProvider>(context, listen: false).removeById(entry.id);
                    },
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: entries.length,
            ),
    );
  }
}
