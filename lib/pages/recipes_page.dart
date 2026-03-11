import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/recipes_provider.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // 随着 expandedHeight 减小，滚动阈值也相应调小
      if (_scrollController.offset > 40 && !_showTitle) {
        setState(() => _showTitle = true);
      } else if (_scrollController.offset <= 40 && _showTitle) {
        setState(() => _showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipesProvider = Provider.of<RecipesProvider>(context);
    final allRecipes = recipesProvider.recipes;

    // Filter logic
    final filteredRecipes = allRecipes.where((recipe) {
      final matchesSearch = _searchQuery.isEmpty ||
          recipe.title.contains(_searchQuery) ||
          recipe.description.contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;

      // Map localized filter names to tags or logic
      if (_selectedFilter == l10n.filterKeto) {
        return recipe.tags.contains('生酮');
      }
      if (_selectedFilter == l10n.filterVeggie) {
        return recipe.tags.contains('素食');
      }
      if (_selectedFilter == l10n.filterLowCal) {
        return recipe.tags.contains('低卡');
      }

      // Direct tag matching for others
      return recipe.tags.contains(_selectedFilter);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 110.0,
            floating: false,
            pinned: true,
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.background,
            // 当折叠到一定程度时，通过 AnimatedOpacity 渐显标题
            title: AnimatedOpacity(
              opacity: _showTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                l10n.recommendForYou,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.2,
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
              centerTitle: false,
              title: AnimatedOpacity(
                opacity: _showTitle ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.recommendForYou,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.recommendBasedOnPantry,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              background: Container(color: AppColors.background),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchRecipes,
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
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
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: filteredRecipes.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            '没有找到相关食谱',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final recipe = filteredRecipes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildRecipeCard(
                            context,
                            recipe.id,
                            recipe.title,
                            recipe.description,
                            recipe.time,
                            recipe.calories,
                            recipe.imageUrl,
                            recipe.tags,
                            isFavorite: recipe.isFavorite,
                            ingredients: recipe.ingredients,
                            steps: recipe.steps,
                          ),
                        );
                      },
                      childCount: filteredRecipes.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = _selectedFilter == label ||
        (_selectedFilter == 'All' && label == l10n.filterAll);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: 1,
          ),
        ),
        showCheckmark: false,
        elevation: isSelected ? 2 : 0,
        pressElevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    String id,
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
    final recipesProvider =
        Provider.of<RecipesProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(
              id: id,
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        recipesProvider.toggleFavorite(id);
                      },
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
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(tag,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)),
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
