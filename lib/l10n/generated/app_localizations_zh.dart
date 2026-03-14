// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'SnapCook';

  @override
  String get home => '首页';

  @override
  String get pantry => '冰箱';

  @override
  String get recipes => '食谱';

  @override
  String get me => '我的';

  @override
  String get aiAssistant => 'AI 智能助手';

  @override
  String get whatToEatToday => '不知道今天吃什么？';

  @override
  String get aiIntro => '拍一张冰箱的照片，让 CookApp 为您推荐完美的食谱，减少浪费，享受烹饪。';

  @override
  String get startIdentifying => '开始识别食材';

  @override
  String get todayRecommendation => '今日推荐';

  @override
  String get viewAll => '查看全部';

  @override
  String get expiringSoon => '即将过期';

  @override
  String get managePantry => '管理冰箱';

  @override
  String get viewAllPantry => '查看全部库存';

  @override
  String get inventoryList => '库存列表';

  @override
  String get sort => '排序';

  @override
  String get pantryEmpty => '冰箱空空如也';

  @override
  String remainingDays(String days) {
    return '仅剩 $days 天';
  }

  @override
  String expiresInDays(String days) {
    return '$days 天后过期';
  }

  @override
  String get recommendForYou => '为您推荐';

  @override
  String get recommendBasedOnPantry => '基于您冰箱里的食材生成的食谱';

  @override
  String get searchRecipes => '搜索食谱...';

  @override
  String get filterAll => '全部';

  @override
  String get filterKeto => '生酮';

  @override
  String get filterVeggie => '素食';

  @override
  String get filterLowCal => '低卡';

  @override
  String cookingTime(Object time) {
    return '$time 分钟';
  }

  @override
  String calories(Object kcal) {
    return '$kcal 千卡';
  }

  @override
  String get smartIdentification => '智能食材识别';

  @override
  String get cameraIntro => '拍摄您的冰箱内部或上传照片，AI 将自动识别食材。';

  @override
  String get clickToUpload => '点击拍摄或上传照片';

  @override
  String get supportFormats => '支持 JPG, PNG 格式';

  @override
  String get chooseFromAlbum => '从相册选择';

  @override
  String get recognizing => '大模型正在深度识别中...';

  @override
  String get countingIngredients => '正在为您清点每一份食材';

  @override
  String get identificationResult => '识别结果';

  @override
  String get reUpload => '重新上传';

  @override
  String get addToPantry => '一键存入冰箱';

  @override
  String get addedToPantrySuccess => '已成功存入冰箱！';

  @override
  String recipeCount(Object count) {
    return '菜谱 $count';
  }

  @override
  String workCount(Object count) {
    return '作品 $count';
  }

  @override
  String get memberBanner => '开通下厨房会员';

  @override
  String get memberPrice => '最低 0.3 元/天';

  @override
  String get createRecipeAngel => '创建菜谱的人是厨房里的天使';

  @override
  String get startCreateFirstRecipe => '开始创建第一道菜谱';

  @override
  String get pantryLocation => '其他 • 2018 加入 • IP 属地：北京';

  @override
  String get pantryBio => '添加个人简介，让厨友更了解你';

  @override
  String get follow => '关注';

  @override
  String get fans => '粉丝';

  @override
  String get ingredients => '食材清单';

  @override
  String get instructions => '烹饪步骤';

  @override
  String get username => '用户名';

  @override
  String get email => '邮箱';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get dietPreferences => '饮食偏好';

  @override
  String get editPreferences => '编辑偏好';

  @override
  String get myActivity => '我的活动';

  @override
  String get savedRecipes => '收藏食谱';

  @override
  String get scanHistory => '识别历史';

  @override
  String get myIngredients => '我的食材';

  @override
  String get features => '特色功能';

  @override
  String get weeklyMealPlan => '每周饮食计划';

  @override
  String get shoppingList => '购物清单';

  @override
  String get aiChef => 'AI 私厨';

  @override
  String get settings => '设置';

  @override
  String get notifications => '通知';

  @override
  String get units => '单位';

  @override
  String get language => '语言';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get about => '关于';

  @override
  String get logout => '退出登录';

  @override
  String get keto => '生酮';

  @override
  String get vegan => '纯素食';

  @override
  String get vegetarian => '蛋奶素';

  @override
  String get glutenFree => '无麸质';

  @override
  String get lowCarb => '低碳水';

  @override
  String get dairyFree => '无乳制品';

  @override
  String get nutritionInfo => '营养成分';

  @override
  String get storageTips => '存储建议';

  @override
  String get relatedRecipes => '相关食谱';

  @override
  String get protein => '蛋白质';

  @override
  String get carbs => '碳水';

  @override
  String get fat => '脂肪';

  @override
  String get caloriesPer100g => '每 100g 热量';

  @override
  String get fridgeLife => '冷藏建议';

  @override
  String get pantryLife => '常温建议';

  @override
  String get confirmIngredients => '确认食材';

  @override
  String get recognizedIngredients => '识别出的食材';

  @override
  String get addManually => '手动添加';

  @override
  String get generateRecipe => '✨ 生成食谱';

  @override
  String get addIngredient => '添加食材';

  @override
  String get ingredientNameHint => '输入食材名称';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get preferences => '偏好设置';

  @override
  String get cookingTimePref => '烹饪时间';

  @override
  String get flavorPref => '口味偏好';

  @override
  String get equipmentPref => '厨具限制';

  @override
  String get startAICreation => '开始 AI 创作';

  @override
  String get noRecipesFound => '没有找到相关食谱';

  @override
  String get noScanHistory => '暂无识别记录';

  @override
  String get save => '保存';

  @override
  String get comingSoon => '即将上线...';

  @override
  String get error => '选择或识别图片失败';

  @override
  String get sortByCategory => '按品类排序';

  @override
  String get sortByExpiryDate => '按过期时间排序';

  @override
  String get sortByQuantity => '按数量排序';

  @override
  String get noFavoriteRecipes => '暂无收藏食谱';

  @override
  String get addDietPreferences => '添加饮食偏好';

  @override
  String get generateRecipes => '去生成食谱';

  @override
  String get retakePhoto => '返回重拍';

  @override
  String get generatedRecipesForYou => '为你生成的食谱';

  @override
  String get appTagline => '让你的冰箱更聪明，让烹饪更轻松';

  @override
  String get retry => '重试';

  @override
  String get reload => '重新加载';

  @override
  String get continueAdding => '继续添加';

  @override
  String get clearAndRetake => '清空重拍';

  @override
  String get takePhoto => '拍照';

  @override
  String generateRecipeFailed(String error) {
    return '生成食谱失败: $error';
  }

  @override
  String get iGotIt => '我知道了';

  @override
  String get viewMore => '查看更多';
}
