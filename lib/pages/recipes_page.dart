import 'package:flutter/material.dart';
import 'package:cook_app/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import 'recipe_detail_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Define recipes data
    final allRecipes = [
      {
        'title': '奶油菠菜鸡胸肉',
        'description': '利用冰箱里剩下的菠菜和奶油，做一道健康又美味的低碳水晚餐。',
        'time': '25',
        'calories': '320',
        'imageUrl':
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
        'tags': ['生酮', '高蛋白', '低碳水'],
        'isFavorite': true,
        'ingredients': [
          {'name': '鸡胸肉', 'amount': '500g'},
          {'name': '橄榄油', 'amount': '2 汤匙'},
          {'name': '大蒜', 'amount': '2 瓣'},
          {'name': '菠菜', 'amount': '200g'},
          {'name': '淡奶油', 'amount': '100ml'},
        ],
        'steps': [
          '用盐和黑胡椒腌制鸡胸肉。',
          '平底锅中热油，中火加热。',
          '加入鸡胸肉，煎至两面金黄且熟透，每面约 6-7 分钟。',
          '将鸡胸肉盛出备用。',
          '在同一个锅中，炒香大蒜。',
          '加入菠菜炒至变软。',
          '倒入淡奶油，小火煮 2-3 分钟。',
          '将鸡胸肉放回锅中，即可享用。',
        ],
      },
      {
        'title': '田园蔬菜沙拉',
        'description': '清爽解腻，只需简单的油醋汁调味即可。',
        'time': '10',
        'calories': '180',
        'imageUrl':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&auto=format&fit=crop&q=60',
        'tags': ['素食', '低卡', '快速简餐'],
        'isFavorite': false,
        'ingredients': [
          {'name': '生菜', 'amount': '200g'},
          {'name': '小番茄', 'amount': '10个'},
          {'name': '黄瓜', 'amount': '1根'},
          {'name': '橄榄油', 'amount': '1勺'},
          {'name': '醋', 'amount': '1勺'},
        ],
        'steps': [
          '将蔬菜洗净切好。',
          '混合橄榄油和醋制成油醋汁。',
          '将所有材料混合均匀即可。',
        ],
      },
      {
        'title': '香煎三文鱼',
        'description': '富含优质蛋白和Omega-3，简单煎制即可美味。',
        'time': '15',
        'calories': '450',
        'imageUrl':
            'https://images.unsplash.com/photo-1485921325833-c519f76c4927?w=500&auto=format&fit=crop&q=60',
        'tags': ['生酮', '高蛋白', '低碳水'],
        'isFavorite': false,
        'ingredients': [
          {'name': '三文鱼', 'amount': '200g'},
          {'name': '柠檬', 'amount': '半个'},
          {'name': '迷迭香', 'amount': '1枝'},
          {'name': '黑胡椒', 'amount': '适量'},
        ],
        'steps': [
          '三文鱼洗净擦干，撒上海盐和黑胡椒腌制10分钟。',
          '平底锅烧热放少许油，放入三文鱼皮朝下煎3分钟。',
          '翻面继续煎2-3分钟至熟。',
          '挤上柠檬汁，放入迷迭香装饰。',
        ],
      },
      {
        'title': '牛油果全麦吐司',
        'description': '完美的早餐选择，营养均衡，开启活力一天。',
        'time': '5',
        'calories': '280',
        'imageUrl':
            'https://images.unsplash.com/photo-1588137372308-15f75323ca8d?w=500&auto=format&fit=crop&q=60',
        'tags': ['素食', '快速简餐'],
        'isFavorite': true,
        'ingredients': [
          {'name': '全麦吐司', 'amount': '2片'},
          {'name': '牛油果', 'amount': '1个'},
          {'name': '鸡蛋', 'amount': '1个'},
          {'name': '黑胡椒', 'amount': '适量'},
        ],
        'steps': [
          '全麦吐司烤至酥脆。',
          '牛油果捣成泥，涂抹在吐司上。',
          '煎一个太阳蛋放在上面。',
          '撒上黑胡椒调味。',
        ],
      },
    ];

    // Filter logic
    final filteredRecipes = allRecipes.where((recipe) {
      final matchesSearch = _searchQuery.isEmpty ||
          (recipe['title'] as String).contains(_searchQuery) ||
          (recipe['description'] as String).contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;

      // Map localized filter names to tags or logic
      if (_selectedFilter == l10n.filterKeto)
        return (recipe['tags'] as List).contains('生酮');
      if (_selectedFilter == l10n.filterVeggie)
        return (recipe['tags'] as List).contains('素食');
      if (_selectedFilter == l10n.filterLowCal)
        return (recipe['tags'] as List).contains('低卡');

      // Direct tag matching for others
      return (recipe['tags'] as List).contains(_selectedFilter);
    }).toList();

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
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
                _buildFilterChip(l10n.filterAll),
                _buildFilterChip(l10n.filterKeto),
                _buildFilterChip(l10n.filterVeggie),
                _buildFilterChip(l10n.filterLowCal),
                _buildFilterChip('高蛋白'),
                _buildFilterChip('快速简餐'),
                _buildFilterChip('低碳水'),
              ],
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: Text('没有找到相关食谱',
                        style: TextStyle(color: Colors.grey[600])))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return _buildRecipeCard(
                        context,
                        recipe['title'] as String,
                        recipe['description'] as String,
                        recipe['time'] as String,
                        recipe['calories'] as String,
                        recipe['imageUrl'] as String,
                        recipe['tags'] as List<String>,
                        isFavorite: recipe['isFavorite'] as bool,
                        ingredients:
                            recipe['ingredients'] as List<Map<String, String>>,
                        steps: recipe['steps'] as List<String>,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label ||
        (_selectedFilter == 'All' &&
            label == AppLocalizations.of(context)!.filterAll);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Container(
          constraints: const BoxConstraints(minWidth: 48), // 给定最小宽度
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        showCheckmark: false,
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
    required List<Map<String, String>> ingredients,
    required List<String> steps,
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
              ingredients: ingredients,
              steps: steps,
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
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
                      children: tags
                          .map((tag) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(tag,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                ),
                              ))
                          .toList(),
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.cookingTime(time),
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(width: 16),
                        const Icon(Icons.local_fire_department_outlined,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.calories(calories),
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 20),
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
