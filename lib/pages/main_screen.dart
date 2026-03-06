import 'package:flutter/material.dart';
import 'package:cook_app/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'pantry_page.dart';
import 'recipes_page.dart';
import 'profile_page.dart';
import 'camera_page.dart';
import '../core/app_colors.dart';
import '../core/navigation_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const HomePage(),
    const PantryPage(),
    const CameraPage(),
    const RecipesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navProvider = Provider.of<NavigationProvider>(context);
    
    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.selectedIndex,
        onTap: (index) => navProvider.setSelectedIndex(index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.kitchen_outlined),
            activeIcon: const Icon(Icons.kitchen),
            label: l10n.pantry,
          ),
          const BottomNavigationBarItem(
            icon: SizedBox(height: 24), // Space for FAB
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu_outlined),
            activeIcon: const Icon(Icons.restaurant_menu),
            label: l10n.recipes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.me,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => navProvider.setSelectedIndex(2),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
    );
  }
}
