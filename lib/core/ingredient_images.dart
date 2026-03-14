import '../models/ingredient.dart';

String resolveIngredientAsset(Ingredient ingredient) {
  final name = ingredient.name.trim().toLowerCase();

  if (name.contains('milk')) return 'assets/ingredients/milk.svg';
  if (name.contains('spinach')) return 'assets/ingredients/spinach.svg';
  if (name.contains('steak') || name.contains('beef')) return 'assets/ingredients/steak.svg';
  if (name.contains('egg')) return 'assets/ingredients/egg.svg';
  if (name.contains('apple')) return 'assets/ingredients/apple.svg';
  if (name.contains('chicken')) return 'assets/ingredients/chicken.svg';
  if (name.contains('fish') || name.contains('salmon')) return 'assets/ingredients/fish.svg';
  if (name.contains('pork')) return 'assets/ingredients/pork.svg';
  if (name.contains('tomato')) return 'assets/ingredients/tomato.svg';
  if (name.contains('carrot')) return 'assets/ingredients/carrot.svg';
  if (name.contains('onion')) return 'assets/ingredients/onion.svg';
  if (name.contains('potato')) return 'assets/ingredients/potato.svg';
  if (name.contains('bread')) return 'assets/ingredients/bread.svg';
  if (name.contains('cheese')) return 'assets/ingredients/cheese.svg';
  if (name.contains('butter')) return 'assets/ingredients/butter.svg';

  switch (ingredient.category) {
    case 'Vegetables':
      return 'assets/ingredients/category_vegetable.svg';
    case 'Meat':
      return 'assets/ingredients/category_meat.svg';
    case 'Dairy':
      return 'assets/ingredients/category_dairy.svg';
    case 'Fruits':
      return 'assets/ingredients/category_fruit.svg';
    case 'Seasoning':
      return 'assets/ingredients/category_seasoning.svg';
    default:
      return 'assets/ingredients/category_other.svg';
  }
}
