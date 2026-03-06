import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/pantry_provider.dart';
import '../models/ingredient.dart';
import 'ingredient_detail_page.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '库存列表',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_outlined),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('排序', style: TextStyle(color: AppColors.textSecondary))),
          ),
        ],
      ),
      body: Consumer<PantryProvider>(
        builder: (context, pantry, child) {
          if (pantry.ingredients.isEmpty) {
            return const Center(child: Text('冰箱空空如也'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pantry.ingredients.length,
            itemBuilder: (context, index) {
              final item = pantry.ingredients[index];
              return _buildInventoryItem(context, item, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, Ingredient item, int index) {
    // Determine color based on index or category for visual interest
    final Color itemColor = index % 2 == 0 ? Colors.orange : Colors.green;
    final time = index % 2 == 0 ? '仅剩 2 天' : '10 天后过期';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('${item.name}_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          Provider.of<PantryProvider>(context, listen: false).removeIngredient(index);
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IngredientDetailPage(ingredient: item),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.amount} | ${item.category}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: itemColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(color: itemColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
