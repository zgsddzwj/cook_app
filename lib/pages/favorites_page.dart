import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/recipes_provider.dart';
import 'recipe_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipesProvider = Provider.of<RecipesProvider>(context);
    final favoriteItems = recipesProvider.favoriteRecipes;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedRecipes),
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    '暂无收藏食谱',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = favoriteItems[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailPage(
                          id: r.id,
                          title: r.title,
                          imageUrl: r.imageUrl,
                          tags: r.tags,
                          time: r.time,
                          calories: r.calories,
                          description: r.description,
                          ingredients: r.ingredients,
                          steps: r.steps,
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
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16)),
                          child: Image.network(
                            r.imageUrl,
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
                                r.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_outlined,
                                      color: AppColors.primary, size: 16),
                                  const SizedBox(width: 4),
                                  Text(l10n.cookingTime(r.time),
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 12),
                                  const Icon(
                                      Icons.local_fire_department_outlined,
                                      color: Colors.orange,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text(l10n.calories(r.calories),
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            recipesProvider.toggleFavorite(r.id);
                          },
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
