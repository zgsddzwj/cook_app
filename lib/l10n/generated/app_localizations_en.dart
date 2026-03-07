// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CookApp';

  @override
  String get home => 'Home';

  @override
  String get pantry => 'Pantry';

  @override
  String get recipes => 'Recipes';

  @override
  String get me => 'Me';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get whatToEatToday => 'Don\'t know what to eat?';

  @override
  String get aiIntro =>
      'Take a photo of your fridge, let CookApp recommend the perfect recipe, reduce waste, and enjoy cooking.';

  @override
  String get startIdentifying => 'Start Identifying';

  @override
  String get todayRecommendation => 'Today\'s Pick';

  @override
  String get viewAll => 'View All';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get managePantry => 'Manage Fridge';

  @override
  String get viewAllPantry => 'View All Inventory';

  @override
  String get inventoryList => 'Inventory List';

  @override
  String get sort => 'Sort';

  @override
  String get pantryEmpty => 'Your fridge is empty';

  @override
  String remainingDays(String days) {
    return '$days days left';
  }

  @override
  String expiresInDays(String days) {
    return 'Expires in $days days';
  }

  @override
  String get recommendForYou => 'Recommended';

  @override
  String get recommendBasedOnPantry => 'Recipes based on your fridge';

  @override
  String get searchRecipes => 'Search recipes...';

  @override
  String get filterAll => 'All';

  @override
  String get filterKeto => 'Keto';

  @override
  String get filterVeggie => 'Veggie';

  @override
  String get filterLowCal => 'Low-Cal';

  @override
  String cookingTime(Object time) {
    return '$time min';
  }

  @override
  String calories(Object kcal) {
    return '$kcal kcal';
  }

  @override
  String get smartIdentification => 'Smart Identification';

  @override
  String get cameraIntro =>
      'Take a photo or upload, AI will automatically identify ingredients.';

  @override
  String get clickToUpload => 'Click to take photo or upload';

  @override
  String get supportFormats => 'Supports JPG, PNG';

  @override
  String get chooseFromAlbum => 'Choose from album';

  @override
  String get recognizing => 'AI is identifying...';

  @override
  String get countingIngredients => 'Checking every ingredient for you';

  @override
  String get identificationResult => 'Result';

  @override
  String get reUpload => 'Re-upload';

  @override
  String get addToPantry => 'Add to Fridge';

  @override
  String get addedToPantrySuccess => 'Added successfully!';

  @override
  String recipeCount(Object count) {
    return 'Recipes $count';
  }

  @override
  String workCount(Object count) {
    return 'Works $count';
  }

  @override
  String get memberBanner => 'Join Membership';

  @override
  String get memberPrice => 'As low as \$0.05/day';

  @override
  String get createRecipeAngel => 'Recipe creators are angels in the kitchen';

  @override
  String get startCreateFirstRecipe => 'Create your first recipe';

  @override
  String get pantryLocation => 'Other • Joined 2018 • IP: Beijing';

  @override
  String get pantryBio => 'Add a bio to let others know you';

  @override
  String get follow => 'Following';

  @override
  String get fans => 'Followers';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get dietPreferences => 'Diet Preferences';

  @override
  String get editPreferences => 'Edit Preferences';

  @override
  String get myActivity => 'My Activity';

  @override
  String get savedRecipes => 'Saved Recipes';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get myIngredients => 'My Ingredients';

  @override
  String get features => 'Features';

  @override
  String get weeklyMealPlan => 'Weekly Meal Plan';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get aiChef => 'AI Chef';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get units => 'Units';

  @override
  String get language => 'Language';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get keto => 'Keto';

  @override
  String get vegan => 'Vegan';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get glutenFree => 'Gluten-Free';

  @override
  String get lowCarb => 'Low Carb';

  @override
  String get dairyFree => 'Dairy-Free';

  @override
  String get nutritionInfo => 'Nutrition Info';

  @override
  String get storageTips => 'Storage Tips';

  @override
  String get relatedRecipes => 'Related Recipes';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get caloriesPer100g => 'Calories per 100g';

  @override
  String get fridgeLife => 'Fridge Life';

  @override
  String get pantryLife => 'Pantry Life';
}
