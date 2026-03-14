import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/recipes_provider.dart';

class RecipeDetailPage extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> tags;
  final String time;
  final String calories;
  final String description;
  final List<Map<String, String>> ingredients;
  final List<String> steps;

  const RecipeDetailPage({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.tags,
    required this.time,
    required this.calories,
    required this.description,
    required this.ingredients,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipesProvider = Provider.of<RecipesProvider>(context);
    final isFavorite = recipesProvider.isFavorite(id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: const SizedBox.shrink(), // Remove default leading
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Recipe image
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image,
                            size: 64, color: Colors.grey),
                      );
                    },
                  ),
                  // Back button with background
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    child: _CircularButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Favorite button with background
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: _CircularButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFavorite ? Colors.red : Colors.white,
                      onPressed: () {
                        recipesProvider.toggleFavorite(id);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                  color: AppColors.primary, fontSize: 12),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoItem(Icons.access_time, l10n.cookingTime(time)),
                    const SizedBox(width: 24),
                    _buildInfoItem(
                        Icons.local_fire_department, l10n.calories(calories)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.ingredients,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...ingredients.map((item) =>
                    _buildIngredientItem(item['name']!, item['amount']!)),
                const SizedBox(height: 32),
                Text(
                  l10n.instructions,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...steps
                    .asMap()
                    .entries
                    .map((entry) => _buildStepItem(entry.key + 1, entry.value)),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildIngredientItem(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular button with semi-transparent background
class _CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  const _CircularButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
