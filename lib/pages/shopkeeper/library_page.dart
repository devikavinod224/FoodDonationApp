import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/food.dart';

class LibraryPage extends StatelessWidget {
  final Function(Food) onEdit;
  final VoidCallback onAdd;

  const LibraryPage({
    super.key,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shopkeeper = provider.shopkeeperProfile;
    if (shopkeeper == null) {
      return const Scaffold(body: Center(child: Text("Please login first")));
    }

    final shopId = shopkeeper.id;
    final foods = provider.foods;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Library',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Manage your food listings',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Food'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.shopkeeperPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Inventory List
          Expanded(
            child: foods.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      return _buildInventoryItem(context, food, provider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, Food food, AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(food.image, style: const TextStyle(fontSize: 32))),
        ),
        title: Text(food.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(food.category, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 12, color: AppTheme.shopkeeperPrimary),
                const SizedBox(width: 4),
                Text('${food.quantity} Portions', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.shopkeeperPrimary)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.textLight, size: 20),
              onPressed: () => onEdit(food),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
              onPressed: () => provider.deleteFood(food.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥘', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Your library is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('Add food items to start donating', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}
