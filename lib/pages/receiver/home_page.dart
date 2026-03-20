import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/food_card.dart';
import '../../models/food.dart';

class ReceiverHomePage extends StatefulWidget {
  final Function(Food) onFoodSelect;

  const ReceiverHomePage({super.key, required this.onFoodSelect});

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage> {
  String _searchQuery = "";
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

    final allFoods = provider.foods;
    final categories = ["All", ...provider.getCategories()];
    final filteredFoods = allFoods.where((f) {
      final matchesSearch = f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || f.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.receiverPrimary, AppTheme.receiverSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Find Food',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Available surplus food near you',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.notifications_none, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search for food or categories...',
                    hintStyle: const TextStyle(color: AppTheme.textLight),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          // Categories
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.receiverPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? AppTheme.receiverPrimary : Colors.grey.shade100, width: 2),
                            boxShadow: isSelected ? [BoxShadow(color: AppTheme.receiverPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                          ),
                          child: Center(
                            child: Text(
                              cat == "All" ? "🥘" : _getCategoryIcon(cat),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.split(' ')[0],
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.receiverPrimary : AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Food Grid
          Expanded(
            child: filteredFoods.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = filteredFoods[index];
                      return FoodCard(
                        food: food,
                        categoryBg: _getCategoryBg(food.category),
                        onTap: () => widget.onFoodSelect(food),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥗', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No food available right now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('Check back later or try another category', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}
