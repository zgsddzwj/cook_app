import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'SnapCook'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @pantry.
  ///
  /// In zh, this message translates to:
  /// **'冰箱'**
  String get pantry;

  /// No description provided for @recipes.
  ///
  /// In zh, this message translates to:
  /// **'食谱'**
  String get recipes;

  /// No description provided for @me.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get me;

  /// No description provided for @aiAssistant.
  ///
  /// In zh, this message translates to:
  /// **'AI 智能助手'**
  String get aiAssistant;

  /// No description provided for @whatToEatToday.
  ///
  /// In zh, this message translates to:
  /// **'不知道今天吃什么？'**
  String get whatToEatToday;

  /// No description provided for @aiIntro.
  ///
  /// In zh, this message translates to:
  /// **'拍一张冰箱的照片，让 CookApp 为您推荐完美的食谱，减少浪费，享受烹饪。'**
  String get aiIntro;

  /// No description provided for @startIdentifying.
  ///
  /// In zh, this message translates to:
  /// **'开始识别食材'**
  String get startIdentifying;

  /// No description provided for @todayRecommendation.
  ///
  /// In zh, this message translates to:
  /// **'今日推荐'**
  String get todayRecommendation;

  /// No description provided for @viewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get viewAll;

  /// No description provided for @expiringSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将过期'**
  String get expiringSoon;

  /// No description provided for @managePantry.
  ///
  /// In zh, this message translates to:
  /// **'管理冰箱'**
  String get managePantry;

  /// No description provided for @viewAllPantry.
  ///
  /// In zh, this message translates to:
  /// **'查看全部库存'**
  String get viewAllPantry;

  /// No description provided for @inventoryList.
  ///
  /// In zh, this message translates to:
  /// **'库存列表'**
  String get inventoryList;

  /// No description provided for @sort.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get sort;

  /// No description provided for @pantryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'冰箱空空如也'**
  String get pantryEmpty;

  /// No description provided for @remainingDays.
  ///
  /// In zh, this message translates to:
  /// **'仅剩 {days} 天'**
  String remainingDays(String days);

  /// No description provided for @expiresInDays.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天后过期'**
  String expiresInDays(String days);

  /// No description provided for @recommendForYou.
  ///
  /// In zh, this message translates to:
  /// **'为您推荐'**
  String get recommendForYou;

  /// No description provided for @recommendBasedOnPantry.
  ///
  /// In zh, this message translates to:
  /// **'基于您冰箱里的食材生成的食谱'**
  String get recommendBasedOnPantry;

  /// No description provided for @searchRecipes.
  ///
  /// In zh, this message translates to:
  /// **'搜索食谱...'**
  String get searchRecipes;

  /// No description provided for @filterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get filterAll;

  /// No description provided for @filterKeto.
  ///
  /// In zh, this message translates to:
  /// **'生酮'**
  String get filterKeto;

  /// No description provided for @filterVeggie.
  ///
  /// In zh, this message translates to:
  /// **'素食'**
  String get filterVeggie;

  /// No description provided for @filterLowCal.
  ///
  /// In zh, this message translates to:
  /// **'低卡'**
  String get filterLowCal;

  /// No description provided for @cookingTime.
  ///
  /// In zh, this message translates to:
  /// **'{time} 分钟'**
  String cookingTime(Object time);

  /// No description provided for @calories.
  ///
  /// In zh, this message translates to:
  /// **'{kcal} 千卡'**
  String calories(Object kcal);

  /// No description provided for @smartIdentification.
  ///
  /// In zh, this message translates to:
  /// **'智能食材识别'**
  String get smartIdentification;

  /// No description provided for @cameraIntro.
  ///
  /// In zh, this message translates to:
  /// **'拍摄您的冰箱内部或上传照片，AI 将自动识别食材。'**
  String get cameraIntro;

  /// No description provided for @clickToUpload.
  ///
  /// In zh, this message translates to:
  /// **'点击拍摄或上传照片'**
  String get clickToUpload;

  /// No description provided for @supportFormats.
  ///
  /// In zh, this message translates to:
  /// **'支持 JPG, PNG 格式'**
  String get supportFormats;

  /// No description provided for @chooseFromAlbum.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get chooseFromAlbum;

  /// No description provided for @recognizing.
  ///
  /// In zh, this message translates to:
  /// **'大模型正在深度识别中...'**
  String get recognizing;

  /// No description provided for @countingIngredients.
  ///
  /// In zh, this message translates to:
  /// **'正在为您清点每一份食材'**
  String get countingIngredients;

  /// No description provided for @identificationResult.
  ///
  /// In zh, this message translates to:
  /// **'识别结果'**
  String get identificationResult;

  /// No description provided for @reUpload.
  ///
  /// In zh, this message translates to:
  /// **'重新上传'**
  String get reUpload;

  /// No description provided for @addToPantry.
  ///
  /// In zh, this message translates to:
  /// **'一键存入冰箱'**
  String get addToPantry;

  /// No description provided for @addedToPantrySuccess.
  ///
  /// In zh, this message translates to:
  /// **'已成功存入冰箱！'**
  String get addedToPantrySuccess;

  /// No description provided for @recipeCount.
  ///
  /// In zh, this message translates to:
  /// **'菜谱 {count}'**
  String recipeCount(Object count);

  /// No description provided for @workCount.
  ///
  /// In zh, this message translates to:
  /// **'作品 {count}'**
  String workCount(Object count);

  /// No description provided for @memberBanner.
  ///
  /// In zh, this message translates to:
  /// **'开通下厨房会员'**
  String get memberBanner;

  /// No description provided for @memberPrice.
  ///
  /// In zh, this message translates to:
  /// **'最低 0.3 元/天'**
  String get memberPrice;

  /// No description provided for @createRecipeAngel.
  ///
  /// In zh, this message translates to:
  /// **'创建菜谱的人是厨房里的天使'**
  String get createRecipeAngel;

  /// No description provided for @startCreateFirstRecipe.
  ///
  /// In zh, this message translates to:
  /// **'开始创建第一道菜谱'**
  String get startCreateFirstRecipe;

  /// No description provided for @pantryLocation.
  ///
  /// In zh, this message translates to:
  /// **'其他 • 2018 加入 • IP 属地：北京'**
  String get pantryLocation;

  /// No description provided for @pantryBio.
  ///
  /// In zh, this message translates to:
  /// **'添加个人简介，让厨友更了解你'**
  String get pantryBio;

  /// No description provided for @follow.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get follow;

  /// No description provided for @fans.
  ///
  /// In zh, this message translates to:
  /// **'粉丝'**
  String get fans;

  /// No description provided for @ingredients.
  ///
  /// In zh, this message translates to:
  /// **'食材清单'**
  String get ingredients;

  /// No description provided for @instructions.
  ///
  /// In zh, this message translates to:
  /// **'烹饪步骤'**
  String get instructions;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @email.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get email;

  /// No description provided for @editProfile.
  ///
  /// In zh, this message translates to:
  /// **'编辑个人资料'**
  String get editProfile;

  /// No description provided for @dietPreferences.
  ///
  /// In zh, this message translates to:
  /// **'饮食偏好'**
  String get dietPreferences;

  /// No description provided for @editPreferences.
  ///
  /// In zh, this message translates to:
  /// **'编辑偏好'**
  String get editPreferences;

  /// No description provided for @myActivity.
  ///
  /// In zh, this message translates to:
  /// **'我的活动'**
  String get myActivity;

  /// No description provided for @savedRecipes.
  ///
  /// In zh, this message translates to:
  /// **'收藏食谱'**
  String get savedRecipes;

  /// No description provided for @scanHistory.
  ///
  /// In zh, this message translates to:
  /// **'识别历史'**
  String get scanHistory;

  /// No description provided for @myIngredients.
  ///
  /// In zh, this message translates to:
  /// **'我的食材'**
  String get myIngredients;

  /// No description provided for @features.
  ///
  /// In zh, this message translates to:
  /// **'特色功能'**
  String get features;

  /// No description provided for @weeklyMealPlan.
  ///
  /// In zh, this message translates to:
  /// **'每周饮食计划'**
  String get weeklyMealPlan;

  /// No description provided for @shoppingList.
  ///
  /// In zh, this message translates to:
  /// **'购物清单'**
  String get shoppingList;

  /// No description provided for @aiChef.
  ///
  /// In zh, this message translates to:
  /// **'AI 私厨'**
  String get aiChef;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notifications;

  /// No description provided for @units.
  ///
  /// In zh, this message translates to:
  /// **'单位'**
  String get units;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  /// No description provided for @keto.
  ///
  /// In zh, this message translates to:
  /// **'生酮'**
  String get keto;

  /// No description provided for @vegan.
  ///
  /// In zh, this message translates to:
  /// **'纯素食'**
  String get vegan;

  /// No description provided for @vegetarian.
  ///
  /// In zh, this message translates to:
  /// **'蛋奶素'**
  String get vegetarian;

  /// No description provided for @glutenFree.
  ///
  /// In zh, this message translates to:
  /// **'无麸质'**
  String get glutenFree;

  /// No description provided for @lowCarb.
  ///
  /// In zh, this message translates to:
  /// **'低碳水'**
  String get lowCarb;

  /// No description provided for @dairyFree.
  ///
  /// In zh, this message translates to:
  /// **'无乳制品'**
  String get dairyFree;

  /// No description provided for @nutritionInfo.
  ///
  /// In zh, this message translates to:
  /// **'营养成分'**
  String get nutritionInfo;

  /// No description provided for @storageTips.
  ///
  /// In zh, this message translates to:
  /// **'存储建议'**
  String get storageTips;

  /// No description provided for @relatedRecipes.
  ///
  /// In zh, this message translates to:
  /// **'相关食谱'**
  String get relatedRecipes;

  /// No description provided for @protein.
  ///
  /// In zh, this message translates to:
  /// **'蛋白质'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In zh, this message translates to:
  /// **'碳水'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In zh, this message translates to:
  /// **'脂肪'**
  String get fat;

  /// No description provided for @caloriesPer100g.
  ///
  /// In zh, this message translates to:
  /// **'每 100g 热量'**
  String get caloriesPer100g;

  /// No description provided for @fridgeLife.
  ///
  /// In zh, this message translates to:
  /// **'冷藏建议'**
  String get fridgeLife;

  /// No description provided for @pantryLife.
  ///
  /// In zh, this message translates to:
  /// **'常温建议'**
  String get pantryLife;

  /// No description provided for @confirmIngredients.
  ///
  /// In zh, this message translates to:
  /// **'确认食材'**
  String get confirmIngredients;

  /// No description provided for @recognizedIngredients.
  ///
  /// In zh, this message translates to:
  /// **'识别出的食材'**
  String get recognizedIngredients;

  /// No description provided for @addManually.
  ///
  /// In zh, this message translates to:
  /// **'手动添加'**
  String get addManually;

  /// No description provided for @generateRecipe.
  ///
  /// In zh, this message translates to:
  /// **'✨ 生成食谱'**
  String get generateRecipe;

  /// No description provided for @addIngredient.
  ///
  /// In zh, this message translates to:
  /// **'添加食材'**
  String get addIngredient;

  /// No description provided for @ingredientNameHint.
  ///
  /// In zh, this message translates to:
  /// **'输入食材名称'**
  String get ingredientNameHint;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @preferences.
  ///
  /// In zh, this message translates to:
  /// **'偏好设置'**
  String get preferences;

  /// No description provided for @cookingTimePref.
  ///
  /// In zh, this message translates to:
  /// **'烹饪时间'**
  String get cookingTimePref;

  /// No description provided for @flavorPref.
  ///
  /// In zh, this message translates to:
  /// **'口味偏好'**
  String get flavorPref;

  /// No description provided for @equipmentPref.
  ///
  /// In zh, this message translates to:
  /// **'厨具限制'**
  String get equipmentPref;

  /// No description provided for @startAICreation.
  ///
  /// In zh, this message translates to:
  /// **'开始 AI 创作'**
  String get startAICreation;

  /// No description provided for @noRecipesFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关食谱'**
  String get noRecipesFound;

  /// No description provided for @noScanHistory.
  ///
  /// In zh, this message translates to:
  /// **'暂无识别记录'**
  String get noScanHistory;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @comingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将上线...'**
  String get comingSoon;

  /// No description provided for @error.
  ///
  /// In zh, this message translates to:
  /// **'选择或识别图片失败'**
  String get error;

  /// No description provided for @sortByCategory.
  ///
  /// In zh, this message translates to:
  /// **'按品类排序'**
  String get sortByCategory;

  /// No description provided for @sortByExpiryDate.
  ///
  /// In zh, this message translates to:
  /// **'按过期时间排序'**
  String get sortByExpiryDate;

  /// No description provided for @sortByQuantity.
  ///
  /// In zh, this message translates to:
  /// **'按数量排序'**
  String get sortByQuantity;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
