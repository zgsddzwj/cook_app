import '../models/ingredient.dart';

String resolveIngredientAsset(Ingredient ingredient) {
  final name = ingredient.name.trim();

  if (name.contains('牛奶')) return 'assets/ingredients/milk.svg';
  if (name.contains('菠菜')) return 'assets/ingredients/spinach.svg';
  if (name.contains('牛排')) return 'assets/ingredients/steak.svg';
  if (name.contains('鸡蛋') || name == '蛋') return 'assets/ingredients/egg.svg';
  if (name.contains('苹果')) return 'assets/ingredients/apple.svg';

  switch (ingredient.category) {
    case '蔬菜类':
      return 'assets/ingredients/category_vegetable.svg';
    case '肉类':
      return 'assets/ingredients/category_meat.svg';
    case '蛋奶类':
      return 'assets/ingredients/category_dairy.svg';
    case '水果类':
      return 'assets/ingredients/category_fruit.svg';
    case '调料':
      return 'assets/ingredients/category_seasoning.svg';
    default:
      return 'assets/ingredients/category_other.svg';
  }
}

