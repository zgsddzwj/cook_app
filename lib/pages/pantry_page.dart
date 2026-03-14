import 'package:cached_network_image/cached_network_image.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/ingredient_image_service.dart';
import '../core/pantry_provider.dart';
import '../models/ingredient.dart';
import 'ingredient_detail_page.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  void _showSortSheet(BuildContext context, PantryProvider pantry, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        Widget buildOption({
          required PantrySortType type,
          required IconData icon,
          required String title,
        }) {
          final selected = pantry.currentSortType == type;
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withOpacity(0.12) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 20),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.textPrimary : AppColors.textPrimary,
              ),
            ),
            trailing: selected ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () {
              pantry.setSortType(type);
              Navigator.pop(sheetContext);
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          l10n.sort,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  buildOption(type: PantrySortType.category, icon: Icons.category_outlined, title: l10n.sortByCategory),
                  Divider(height: 1, color: Colors.grey.shade100),
                  buildOption(type: PantrySortType.expiryDate, icon: Icons.event_outlined, title: l10n.sortByExpiryDate),
                  Divider(height: 1, color: Colors.grey.shade100),
                  buildOption(type: PantrySortType.quantity, icon: Icons.format_list_numbered_outlined, title: l10n.sortByQuantity),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.inventoryList,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Consumer<PantryProvider>(
            builder: (context, pantry, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () => _showSortSheet(context, pantry, l10n),
                  icon: const Icon(Icons.sort_outlined, size: 20),
                  label: Text(
                    l10n.sort,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PantryProvider>(
        builder: (context, pantry, child) {
          if (pantry.ingredients.isEmpty) {
            return Center(child: Text(l10n.pantryEmpty));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pantry.ingredients.length,
            itemBuilder: (context, index) {
              final item = pantry.ingredients[index];
              return _buildInventoryItem(context, item, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, Ingredient item, int index) {
    final l10n = AppLocalizations.of(context)!;
    
    // Calculate days until expiry
    String expiryText = '';
    Color itemColor = Colors.green;
    
    if (item.expiryDate != null) {
      final daysLeft = item.expiryDate!.difference(DateTime.now()).inDays;
      if (daysLeft <= 3) {
        itemColor = Colors.orange;
        expiryText = l10n.remainingDays(daysLeft.toString());
      } else {
        expiryText = l10n.expiresInDays(daysLeft.toString());
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('${item.name}_${item.expiryDate?.millisecondsSinceEpoch}_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          Provider.of<PantryProvider>(context, listen: false).removeIngredient(item);
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IngredientDetailPage(ingredient: item),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: IngredientImageService.getIngredientThumbnail(item),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.amount} | ${item.category}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      if (expiryText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: itemColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              expiryText,
                              style: TextStyle(color: itemColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
