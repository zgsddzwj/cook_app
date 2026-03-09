import 'package:flutter/material.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import 'recipe_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      {
        'title': '奶油菠菜鸡胸肉',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
        'time': '25',
        'calories': '320',
        'tags': ['生酮', '高蛋白']
      },
      {
        'title': '田园蔬菜沙拉',
        'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&auto=format&fit=crop&q=60',
        'time': '10',
        'calories': '180',
        'tags': ['素食', '低卡']
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedRecipes),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final r = items[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailPage(
                    title: r['title'] as String,
                    imageUrl: r['image'] as String,
                    tags: (r['tags'] as List).cast<String>(),
                    time: r['time'] as String,
                    calories: r['calories'] as String,
                    description: '',
                    ingredients: const [],
                    steps: const [],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    child: Image.network(
                      r['image'] as String,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time_outlined, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(l10n.cookingTime(r['time'] as String), style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.local_fire_department_outlined, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(l10n.calories(r['calories'] as String), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
