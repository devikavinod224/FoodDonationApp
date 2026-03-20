import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/food_card.dart';
import '../../models/food.dart';

class ShopkeeperHomePage extends StatefulWidget {
  const ShopkeeperHomePage({super.key});

  @override
  State<ShopkeeperHomePage> createState() => _ShopkeeperHomePageState();
}

class _ShopkeeperHomePageState extends State<ShopkeeperHomePage> {
  String _searchQuery = "";
  bool _showSearch = false;
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  Color _getCategoryBg(String cat) {
    switch (cat) {
      case "Rice Item": return const Color(0xFFFFFBEB);
      case "Drinking Item": return const Color(0xFFEFF6FF);
      case "Paratha Item": return const Color(0xFFFFF7ED);
      case "Snack Item": return const Color(0xFFF0FDF4);
      case "Dessert Item": return const Color(0xFFFDF2F8);
      case "Curry Item": return const Color(0xFFFEF2F2);
      default: return Colors.grey.shade50;
    }
  }

  String _getCategoryIcon(String cat) {
    switch (cat) {
      case "Rice Item": return "🍚";
      case "Drinking Item": return "🥤";
      case "Paratha Item": return "🫓";
      case "Snack Item": return "🥟";
      case "Dessert Item": return "🍰";
      case "Curry Item": return "🥘";
      default: return "🍽️";
    }
  }

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
    final categories = ["All", ...provider.getCategories(shopId: shopId)];

    final filteredFoods = foods.where((f) {
      final matchesSearch = f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || f.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Group foods by category for "All" view
    final Map<String, List<Food>> groupedFoods = {};
    if (_selectedCategory == "All") {
      for (var food in filteredFoods) {
        groupedFoods.putIfAbsent(food.category, () => []).add(food);
      }
    }

    final totalItems = foods.length;
    final totalQuantity = foods.fold(0, (sum, f) => sum + f.quantity);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.shopkeeperPrimary, AppTheme.shopkeeperSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.shopDetails?.shopName ?? "My Shop",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          shopkeeper.name,
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => setState(() => _showSearch = !_showSearch),
                      icon: const Icon(Icons.search, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                    ),
                  ],
                ),
                if (_showSearch) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search food items...',
                      hintStyle: const TextStyle(color: AppTheme.textLight),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatCard(totalItems.toString(), 'Food Items'),
                    const SizedBox(width: 12),
                    _buildStatCard(totalQuantity.toString(), 'Total Portions'),
                    const SizedBox(width: 12),
                    _buildStatCard((categories.length - 1).toString(), 'Categories'),
                  ],
                ),
              ],
            ),
          ),

          // Category Filter
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cat != "All") Text("${_getCategoryIcon(cat)} "),
                        Text(cat),
                      ],
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.shopkeeperPrimary,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200)),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          // Food List
          Expanded(
            child: filteredFoods.isEmpty 
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: _selectedCategory == "All" 
                    ? groupedFoods.entries.map((e) => _buildCategorySection(e.key, e.value)).toList()
                    : [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredFoods.length,
                          itemBuilder: (context, index) => FoodCard(
                            food: filteredFoods[index],
                            categoryBg: _getCategoryBg(filteredFoods[index].category),
                          ),
                        ),
                      ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Food> categoryFoods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_getCategoryIcon(category), style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(width: 8),
            Text('(${categoryFoods.length})', style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: categoryFoods.length,
          itemBuilder: (context, index) => FoodCard(
            food: categoryFoods[index],
            categoryBg: _getCategoryBg(category),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No food items found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('Try a different search or category', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}
