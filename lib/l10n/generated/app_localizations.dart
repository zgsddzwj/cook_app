import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SnapCook'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @pantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantry;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @whatToEatToday.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know what to eat?'**
  String get whatToEatToday;

  /// No description provided for @aiIntro.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your fridge, let SnapCook recommend the perfect recipe, reduce waste, and enjoy cooking.'**
  String get aiIntro;

  /// No description provided for @startIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Start Identifying'**
  String get startIdentifying;

  /// No description provided for @todayRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Pick'**
  String get todayRecommendation;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get expiringSoon;

  /// No description provided for @managePantry.
  ///
  /// In en, this message translates to:
  /// **'Manage Pantry'**
  String get managePantry;

  /// No description provided for @viewAllPantry.
  ///
  /// In en, this message translates to:
  /// **'View All Inventory'**
  String get viewAllPantry;

  /// No description provided for @inventoryList.
  ///
  /// In en, this message translates to:
  /// **'Inventory List'**
  String get inventoryList;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your fridge is empty'**
  String get pantryEmpty;

  /// No description provided for @remainingDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String remainingDays(String days);

  /// No description provided for @expiresInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String expiresInDays(String days);

  /// No description provided for @recommendForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendForYou;

  /// No description provided for @recommendBasedOnPantry.
  ///
  /// In en, this message translates to:
  /// **'Recipes based on your fridge'**
  String get recommendBasedOnPantry;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipes;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get filterKeto;

  /// No description provided for @filterVeggie.
  ///
  /// In en, this message translates to:
  /// **'Veggie'**
  String get filterVeggie;

  /// No description provided for @filterLowCal.
  ///
  /// In en, this message translates to:
  /// **'Low-Cal'**
  String get filterLowCal;

  /// No description provided for @cookingTime.
  ///
  /// In en, this message translates to:
  /// **'{time} min'**
  String cookingTime(Object time);

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String calories(Object kcal);

  /// No description provided for @smartIdentification.
  ///
  /// In en, this message translates to:
  /// **'Smart Identification'**
  String get smartIdentification;

  /// No description provided for @cameraIntro.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or upload, AI will automatically identify ingredients.'**
  String get cameraIntro;

  /// No description provided for @clickToUpload.
  ///
  /// In en, this message translates to:
  /// **'Click to take photo or upload'**
  String get clickToUpload;

  /// No description provided for @supportFormats.
  ///
  /// In en, this message translates to:
  /// **'Supports JPG, PNG'**
  String get supportFormats;

  /// No description provided for @chooseFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Choose from Album'**
  String get chooseFromAlbum;

  /// No description provided for @recognizing.
  ///
  /// In en, this message translates to:
  /// **'AI is identifying...'**
  String get recognizing;

  /// No description provided for @countingIngredients.
  ///
  /// In en, this message translates to:
  /// **'Checking every ingredient for you'**
  String get countingIngredients;

  /// No description provided for @identificationResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get identificationResult;

  /// No description provided for @reUpload.
  ///
  /// In en, this message translates to:
  /// **'Re-upload'**
  String get reUpload;

  /// No description provided for @addToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add to Fridge'**
  String get addToPantry;

  /// No description provided for @addedToPantrySuccess.
  ///
  /// In en, this message translates to:
  /// **'Added successfully!'**
  String get addedToPantrySuccess;

  /// No description provided for @recipeCount.
  ///
  /// In en, this message translates to:
  /// **'Recipes {count}'**
  String recipeCount(Object count);

  /// No description provided for @workCount.
  ///
  /// In en, this message translates to:
  /// **'Works {count}'**
  String workCount(Object count);

  /// No description provided for @memberBanner.
  ///
  /// In en, this message translates to:
  /// **'Join Membership'**
  String get memberBanner;

  /// No description provided for @memberPrice.
  ///
  /// In en, this message translates to:
  /// **'As low as \$0.05/day'**
  String get memberPrice;

  /// No description provided for @createRecipeAngel.
  ///
  /// In en, this message translates to:
  /// **'Recipe creators are angels in the kitchen'**
  String get createRecipeAngel;

  /// No description provided for @startCreateFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create your first recipe'**
  String get startCreateFirstRecipe;

  /// No description provided for @pantryLocation.
  ///
  /// In en, this message translates to:
  /// **'Other • Joined 2018 • IP: Beijing'**
  String get pantryLocation;

  /// No description provided for @pantryBio.
  ///
  /// In en, this message translates to:
  /// **'Add a bio to let others know you'**
  String get pantryBio;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get follow;

  /// No description provided for @fans.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get fans;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @dietPreferences.
  ///
  /// In en, this message translates to:
  /// **'Diet Preferences'**
  String get dietPreferences;

  /// No description provided for @editPreferences.
  ///
  /// In en, this message translates to:
  /// **'Edit Preferences'**
  String get editPreferences;

  /// No description provided for @myActivity.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivity;

  /// No description provided for @savedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Saved Recipes'**
  String get savedRecipes;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @myIngredients.
  ///
  /// In en, this message translates to:
  /// **'My Ingredients'**
  String get myIngredients;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @weeklyMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly Meal Plan'**
  String get weeklyMealPlan;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @aiChef.
  ///
  /// In en, this message translates to:
  /// **'AI Chef'**
  String get aiChef;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @keto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get keto;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @glutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-Free'**
  String get glutenFree;

  /// No description provided for @lowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get lowCarb;

  /// No description provided for @dairyFree.
  ///
  /// In en, this message translates to:
  /// **'Dairy-Free'**
  String get dairyFree;

  /// No description provided for @nutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Info'**
  String get nutritionInfo;

  /// No description provided for @storageTips.
  ///
  /// In en, this message translates to:
  /// **'Storage Tips'**
  String get storageTips;

  /// No description provided for @relatedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Related Recipes'**
  String get relatedRecipes;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @caloriesPer100g.
  ///
  /// In en, this message translates to:
  /// **'Calories per 100g'**
  String get caloriesPer100g;

  /// No description provided for @fridgeLife.
  ///
  /// In en, this message translates to:
  /// **'Fridge Life'**
  String get fridgeLife;

  /// No description provided for @pantryLife.
  ///
  /// In en, this message translates to:
  /// **'Pantry Life'**
  String get pantryLife;

  /// No description provided for @confirmIngredients.
  ///
  /// In en, this message translates to:
  /// **'Confirm Ingredients'**
  String get confirmIngredients;

  /// No description provided for @recognizedIngredients.
  ///
  /// In en, this message translates to:
  /// **'Recognized Ingredients'**
  String get recognizedIngredients;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManually;

  /// No description provided for @generateRecipe.
  ///
  /// In en, this message translates to:
  /// **'✨ Generate Recipe'**
  String get generateRecipe;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @ingredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter ingredient name'**
  String get ingredientNameHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @cookingTimePref.
  ///
  /// In en, this message translates to:
  /// **'Cooking Time'**
  String get cookingTimePref;

  /// No description provided for @flavorPref.
  ///
  /// In en, this message translates to:
  /// **'Flavor Profile'**
  String get flavorPref;

  /// No description provided for @equipmentPref.
  ///
  /// In en, this message translates to:
  /// **'Kitchenware'**
  String get equipmentPref;

  /// No description provided for @startAICreation.
  ///
  /// In en, this message translates to:
  /// **'Start AI Creation'**
  String get startAICreation;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No relevant recipes found'**
  String get noRecipesFound;

  /// No description provided for @noScanHistory.
  ///
  /// In en, this message translates to:
  /// **'No scan history yet'**
  String get noScanHistory;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon...'**
  String get comingSoon;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick or recognize image'**
  String get error;

  /// No description provided for @sortByCategory.
  ///
  /// In en, this message translates to:
  /// **'Sort by Category'**
  String get sortByCategory;

  /// No description provided for @sortByExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by Expiry Date'**
  String get sortByExpiryDate;

  /// No description provided for @sortByQuantity.
  ///
  /// In en, this message translates to:
  /// **'Sort by Quantity'**
  String get sortByQuantity;

  /// No description provided for @noFavoriteRecipes.
  ///
  /// In en, this message translates to:
  /// **'No favorite recipes yet'**
  String get noFavoriteRecipes;

  /// No description provided for @addDietPreferences.
  ///
  /// In en, this message translates to:
  /// **'Add Diet Preferences'**
  String get addDietPreferences;

  /// No description provided for @generateRecipes.
  ///
  /// In en, this message translates to:
  /// **'Generate Recipes'**
  String get generateRecipes;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @generatedRecipesForYou.
  ///
  /// In en, this message translates to:
  /// **'Generated Recipes for You'**
  String get generatedRecipesForYou;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Make your fridge smarter, cooking easier'**
  String get appTagline;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @continueAdding.
  ///
  /// In en, this message translates to:
  /// **'Continue Adding'**
  String get continueAdding;

  /// No description provided for @clearAndRetake.
  ///
  /// In en, this message translates to:
  /// **'Clear & Retake'**
  String get clearAndRetake;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @generateRecipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate recipe: {error}'**
  String generateRecipeFailed(String error);

  /// No description provided for @iGotIt.
  ///
  /// In en, this message translates to:
  /// **'I Got It'**
  String get iGotIt;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
