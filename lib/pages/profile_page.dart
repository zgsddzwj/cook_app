import 'package:flutter/material.dart';
import 'package:snap_cook/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../core/app_colors.dart';
import '../core/diet_preferences_provider.dart';
import '../core/navigation_provider.dart';
import '../core/user_provider.dart';
import 'edit_profile_page.dart';
import 'favorites_page.dart';
import 'scan_history_page.dart';
import 'diet_preferences_page.dart';
import 'privacy_policy_page.dart';
import 'about_page.dart';
import 'recognition_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.background,
            title: Text(
              l10n.me,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(context, l10n),
                const SizedBox(height: 24),
                _buildDietPreferences(context, l10n),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  title: l10n.myActivity,
                  items: [
                    _ListItem(
                        icon: Icons.favorite,
                        title: l10n.savedRecipes,
                        route: '/profile/favorites'),
                    _ListItem(
                        icon: Icons.history,
                        title: l10n.scanHistory,
                        route: '/profile/scan-history'),
                    _ListItem(
                        icon: Icons.inventory_2,
                        title: l10n.myIngredients,
                        index: 1),
                  ],
                  navProvider: navProvider,
                ),
                const SizedBox(height: 24),
                // _buildSection(
                //   context,
                //   title: l10n.features,
                //   items: [
                //     _ListItem(
                //         icon: Icons.calendar_today,
                //         title: l10n.weeklyMealPlan,
                //         route: '/meal-plan'),
                //     _ListItem(
                //         icon: Icons.shopping_cart,
                //         title: l10n.shoppingList,
                //         route: '/shopping-list'),
                //     _ListItem(
                //         icon: Icons.smart_toy, title: l10n.aiChef, index: 2),
                //   ],
                //   navProvider: navProvider,
                // ),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  title: l10n.settings,
                  items: [
                    // _ListItem(
                    //     icon: Icons.notifications,
                    //     title: l10n.notifications,
                    //     route: '/profile/settings/notifications'),
                    _ListItem(
                        icon: Icons.privacy_tip,
                        title: l10n.privacyPolicy,
                        route: '/profile/settings/privacy'),
                    _ListItem(
                        icon: Icons.info,
                        title: l10n.about,
                        route: '/profile/settings/about'),
                    // _ListItem(
                    //     icon: Icons.logout,
                    //     title: l10n.logout,
                    //     action: 'logout',
                    //     isDestructive: true),
                  ],
                  navProvider: navProvider,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppLocalizations l10n) {
    final userProvider = Provider.of<UserProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: userProvider.avatarPath != null
                      ? FileImage(File(userProvider.avatarPath!))
                      : NetworkImage(userProvider.defaultAvatarUrl)
                          as ImageProvider,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProvider.nickname,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProvider.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  l10n.editProfile,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPreferences(BuildContext context, AppLocalizations l10n) {
    final preferences = [
      {'label': l10n.keto, 'key': 'keto'},
      {'label': l10n.vegan, 'key': 'vegan'},
      {'label': l10n.vegetarian, 'key': 'vegetarian'},
      {'label': l10n.glutenFree, 'key': 'gluten_free'},
      {'label': l10n.lowCarb, 'key': 'low_carb'},
      {'label': l10n.dairyFree, 'key': 'dairy_free'},
    ];

    final dietProvider = Provider.of<DietPreferencesProvider>(context);
    final selectedPrefs =
        preferences.where((p) => dietProvider.isSelected(p['key']!)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.dietPreferences,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DietPreferencesPage()),
                  );
                },
                child: Text(l10n.editPreferences,
                    style: const TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          selectedPrefs.isEmpty
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DietPreferencesPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.addDietPreferences,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedPrefs.map((pref) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pref['label']!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title,
      required List<_ListItem> items,
      required NavigationProvider navProvider}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade50),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(item.icon,
                      color: item.isDestructive
                          ? Colors.redAccent
                          : AppColors.primary,
                      size: 22),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.isDestructive
                          ? Colors.redAccent
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      size: 20, color: Colors.grey),
                  onTap: () {
                    if (item.index != null) {
                      navProvider.setSelectedIndex(item.index!);
                    } else if (item.route != null) {
                      if (item.route == '/profile/favorites') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FavoritesPage()));
                      } else if (item.route == '/profile/scan-history') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ScanHistoryPage()));
                        // } else if (item.route ==
                        //     '/profile/settings/notifications') {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(content: Text('打开通知设置')));
                      } else if (item.route == '/profile/settings/privacy') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyPage()));
                      } else if (item.route == '/profile/settings/about') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AboutPage()));
                      } else if (item.route == '/profile/settings/recognition') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RecognitionSettingsPage()));
                      }
                      // } else if (item.action == 'logout') {
                      //   ScaffoldMessenger.of(context)
                      //       .showSnackBar(const SnackBar(content: Text('已退出登录')));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem {
  final IconData icon;
  final String title;
  final String? route;
  final String? action;
  final int? index;
  final bool isDestructive;

  _ListItem({
    required this.icon,
    required this.title,
    this.route,
    this.action,
    this.index,
    this.isDestructive = false,
  });
}
