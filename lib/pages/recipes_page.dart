import 'package:flutter/material.dart';
import 'package:cook_app/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import 'recipe_detail_page.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recommendForYou,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              l10n.recommendBasedOnPantry,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchRecipes,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(l10n.filterAll, true),
                _buildFilterChip(l10n.filterKeto, false),
                _buildFilterChip(l10n.filterVeggie, false),
                _buildFilterChip(l10n.filterLowCal, false),
                _buildFilterChip('高蛋白', false),
                _buildFilterChip('快速简餐', false),
                _buildFilterChip('低碳水', false),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRecipeCard(
                  context,
                  '奶油菠菜鸡胸肉',
                  '利用冰箱里剩下的菠菜和奶油，做一道健康又美味的低碳水晚餐。',
                  '25',
                  '320',
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
                  ['生酮', '高蛋白'],
                  isFavorite: true,
                ),
                _buildRecipeCard(
                  context,
                  '田园蔬菜沙拉',
                  '清爽解腻，只需简单的油醋汁调味即可。',
                  '10',
                  '180',
                  'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&auto=format&fit=crop&q=60',
                  ['素食', '低卡'],
                  isFavorite: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isSelected ? AppColors.primary : Colors.grey[100],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    String title,
    String description,
    String time,
    String calories,
    String imageUrl,
    List<String> tags, {
    required bool isFavorite,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(
              title: title,
              imageUrl: imageUrl,
              tags: tags,
              time: time,
              calories: calories,
              description: description,
              ingredients: const [
                {'name': '鸡胸肉', 'amount': '500g'},
                {'name': '橄榄油', 'amount': '2 汤匙'},
                {'name': '大蒜', 'amount': '2 瓣'},
                {'name': '菠菜', 'amount': '200g'},
                {'name': '淡奶油', 'amount': '100ml'},
              ],
              steps: const [
                '用盐和黑胡椒腌制鸡胸肉。',
                '平底锅中热油，中火加热。',
                '加入鸡胸肉，煎至两面金黄且熟透，每面约 6-7 分钟。',
                '将鸡胸肉盛出备用。',
                '在同一个锅中，炒香大蒜。',
                '加入菠菜炒至变软。',
                '倒入淡奶油，小火煮 2-3 分钟。',
                '将鸡胸肉放回锅中，即可享用。',
              ],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Row(
                      children: tags.map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.cookingTime(time), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(width: 16),
                        const Icon(Icons.local_fire_department_outlined, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.calories(calories), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
