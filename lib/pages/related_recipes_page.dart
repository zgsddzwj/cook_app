import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/recipes_provider.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'recipe_detail_page.dart';

class RelatedRecipesPage extends StatelessWidget {
  final Ingredient ingredient;
  final List<Recipe> recipes;

  const RelatedRecipesPage({
    super.key,
    required this.ingredient,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${ingredient.name} - ${l10n.relatedRecipes}'),
      ),
      body: recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRecipesFound,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return _buildRecipeCard(context, recipe, l10n);
              },
            ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe, AppLocalizations l10n) {
    final recipesProvider = Provider.of<RecipesProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailPage(
              id: recipe.id,
              title: recipe.title,
              imageUrl: recipe.imageUrl,
              tags: recipe.tags,
              time: recipe.time,
              calories: recipe.calories,
              description: recipe.description,
              ingredients: recipe.ingredients,
              steps: recipe.steps,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          l10n.cookingTime(recipe.time),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          l10n.calories(recipe.calories),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Favorite button
            GestureDetector(
              onTap: () {
                recipesProvider.toggleFavorite(recipe.id);
                // Force rebuild to update icon
                (context as Element).markNeedsBuild();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  recipesProvider.isFavorite(recipe.id) ? Icons.favorite : Icons.favorite_border,
                  color: recipesProvider.isFavorite(recipe.id) ? Colors.red : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
