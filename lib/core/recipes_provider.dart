import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe.dart';

class RecipesProvider extends ChangeNotifier {
  final List<Recipe> _builtinRecipes = [
    Recipe(
      id: '1',
      title: '奶油菠菜鸡胸肉',
      description: '利用冰箱里剩下的菠菜和奶油，做一道健康又美味的低碳水晚餐。',
      time: '25',
      calories: '320',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
      tags: ['生酮', '高蛋白', '低碳水'],
      isFavorite: true,
      ingredients: [
        {'name': '鸡胸肉', 'amount': '500g'},
        {'name': '橄榄油', 'amount': '2 汤匙'},
        {'name': '大蒜', 'amount': '2 瓣'},
        {'name': '菠菜', 'amount': '200g'},
        {'name': '淡奶油', 'amount': '100ml'},
      ],
      steps: [
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
    Recipe(
      id: '2',
      title: '田园蔬菜沙拉',
      description: '清爽解腻，只需简单的油醋汁调味即可。',
      time: '10',
      calories: '180',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&auto=format&fit=crop&q=60',
      tags: ['素食', '低卡', '快速简餐'],
      isFavorite: false,
      ingredients: [
        {'name': '生菜', 'amount': '200g'},
        {'name': '小番茄', 'amount': '10个'},
        {'name': '黄瓜', 'amount': '1根'},
        {'name': '橄榄油', 'amount': '1勺'},
        {'name': '醋', 'amount': '1勺'},
      ],
      steps: [
        '将蔬菜洗净切好。',
        '混合橄榄油和醋制成油醋汁。',
        '将所有材料混合均匀即可。',
      ],
    ),
    Recipe(
      id: '3',
      title: '香煎三文鱼',
      description: '富含优质蛋白和Omega-3，简单煎制即可美味。',
      time: '15',
      calories: '450',
      imageUrl:
          'https://images.unsplash.com/photo-1485921325833-c519f76c4927?w=500&auto=format&fit=crop&q=60',
      tags: ['生酮', '高蛋白', '低碳水'],
      isFavorite: false,
      ingredients: [
        {'name': '三文鱼', 'amount': '200g'},
        {'name': '柠檬', 'amount': '半个'},
        {'name': '迷迭香', 'amount': '1枝'},
        {'name': '黑胡椒', 'amount': '适量'},
      ],
      steps: [
        '三文鱼洗净擦干，撒上海盐和黑胡椒腌制10分钟。',
        '平底锅烧热放少许油，放入三文鱼皮朝下煎 3 分钟。',
        '翻面继续煎 2-3 分钟至熟。',
        '挤上柠檬汁，放入迷迭香装饰。',
      ],
    ),
    Recipe(
      id: '4',
      title: '牛油果全麦吐司',
      description: '完美的早餐选择，营养均衡，开启活力一天。',
      time: '5',
      calories: '280',
      imageUrl:
          'https://images.unsplash.com/photo-1588137372308-15f75323ca8d?w=500&auto=format&fit=crop&q=60',
      tags: ['素食', '快速简餐'],
      isFavorite: true,
      ingredients: [
        {'name': '全麦吐司', 'amount': '2片'},
        {'name': '牛油果', 'amount': '1个'},
        {'name': '鸡蛋', 'amount': '1个'},
        {'name': '黑胡椒', 'amount': '适量'},
      ],
      steps: [
        '全麦吐司烤至酥脆。',
        '牛油果捣成泥，涂抹在吐司上。',
        '煎一个太阳蛋放在上面。',
        '撒上黑胡椒调味。',
      ],
    ),
  ];

  final List<Recipe> _customRecipes = [];
  static const String _storageKey = 'custom_recipes';

  RecipesProvider() {
    _loadCustomRecipes();
  }

  List<Recipe> get recipes => [..._customRecipes, ..._builtinRecipes];
  List<Recipe> get favoriteRecipes =>
      recipes.where((r) => r.isFavorite).toList();

  Future<void> _loadCustomRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recipesJson = prefs.getString(_storageKey);
      if (recipesJson != null) {
        final List<dynamic> decoded = jsonDecode(recipesJson);
        _customRecipes.clear();
        _customRecipes.addAll(decoded.map((item) => Recipe.fromJson(item)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading custom recipes: $e');
    }
  }

  Future<void> _saveCustomRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(_customRecipes.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving custom recipes: $e');
    }
  }

  void toggleFavorite(String id) {
    // 检查是否是自定义食谱
    final customIndex = _customRecipes.indexWhere((r) => r.id == id);
    if (customIndex != -1) {
      _customRecipes[customIndex].isFavorite =
          !_customRecipes[customIndex].isFavorite;
      _saveCustomRecipes();
      notifyListeners();
      return;
    }

    // 检查是否是内置食谱
    final index = _builtinRecipes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _builtinRecipes[index].isFavorite = !_builtinRecipes[index].isFavorite;
      notifyListeners();
    }
  }

  bool isFavorite(String id) {
    return recipes.any((r) => r.id == id && r.isFavorite);
  }

  void addRecipe(Recipe recipe) {
    // 检查是否已经存在
    if (!recipes.any((r) => r.id == recipe.id)) {
      _customRecipes.insert(0, recipe);
      _saveCustomRecipes();
      notifyListeners();
    }
  }
}
