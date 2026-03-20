import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/food_card.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/food.dart';
import '../../models/profile_details.dart';
import '../../services/permission_service.dart';

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
  ShopDetails? _selectedShop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialShops();
    });
  }

  Future<void> _fetchInitialShops() async {
    final granted = await PermissionService.requestLocationPermission();
    if (granted) {
      final pos = await PermissionService.getCurrentLocation();
      if (pos != null && mounted) {
        Provider.of<AppProvider>(context, listen: false).fetchNearbyShops(pos.latitude, pos.longitude);
        return;
      }
    }
    // Fallback if permission denied or location null
    Provider.of<AppProvider>(context, listen: false).fetchNearbyShops(12.9716, 77.5946); 
  }

  Color _getCategoryBg(String cat) {
    switch (cat) {
      case "All": return const Color(0xFFEFF6FF);
      case "Restaurants": return const Color(0xFFFFFBEB);
      case "Hotels": return const Color(0xFFFFF7ED);
      case "Groceries": return const Color(0xFFF0FDF4);
      case "Bakery": return const Color(0xFFFDF2F8);
      default: return Colors.grey.shade50;
    }
  }

  String _getCategoryIcon(String cat) {
    switch (cat) {
      case "All": return "🏪";
      case "Restaurants": return "🍱";
      case "Hotels": return "🏨";
      case "Groceries": return "🛒";
      case "Bakery": return "🥐";
      default: return "🍕";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    return PopScope(
      canPop: _selectedShop == null,
      onPopInvoked: (didPop) {
        if (!didPop && _selectedShop != null) {
          setState(() => _selectedShop = null);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: _selectedShop == null 
          ? _buildShopDiscovery(provider)
          : _buildShopMenu(provider, _selectedShop!),
      ),
    );
  }

  Widget _buildShopDiscovery(AppProvider provider) {
    final shops = provider.nearbyShops.where((s) {
      final matchesSearch = s.shopName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    final categories = ["All", "Restaurants", "Hotels", "Groceries", "Bakery"];

    return Column(
      children: [
        // Header
        _buildHeader('Explore Shops', 'Select a shop to view donations'),

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
                child: _buildCategoryItem(cat, isSelected),
              );
            },
          ),
        ),

        // Shops List
        Expanded(
          child: provider.isLoading && shops.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : shops.isEmpty 
              ? _buildEmptyState('No shops found nearby')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return _buildShopCard(shop);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShopMenu(AppProvider provider, ShopDetails shop) {
    final foods = provider.shopFoods;

    return Column(
      children: [
        // Shop Detail Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _selectedShop = null),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(shop.shopLocation, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: provider.isLoading && foods.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : foods.isEmpty
              ? _buildEmptyState('No active donations from this shop')
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: foods.length,
                  itemBuilder: (context, index) => _buildMenuItem(foods[index], provider),
                ),
        ),

        // Cart Summary
        if (provider.cart.isNotEmpty)
          _buildCartSummary(provider, shop),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
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
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                ],
              ),
              const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.notifications_none, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search shops...',
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
    );
  }

  Widget _buildCategoryItem(String cat, bool isSelected) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.receiverPrimary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppTheme.receiverPrimary : Colors.grey.shade100, width: 2),
            ),
            child: Center(child: Text(_getCategoryIcon(cat), style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 4),
          Text(cat, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.receiverPrimary : AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildShopCard(ShopDetails shop) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedShop = shop);
        Provider.of<AppProvider>(context, listen: false).fetchFoodsByShop(shop.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey.shade50),
              child: shop.shopImageUrl.isNotEmpty
                ? Image.network(shop.shopImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.store))
                : const Icon(Icons.store, color: AppTheme.receiverPrimary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Expanded(child: Text(shop.shopLocation, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.receiverPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('View Menu', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.receiverPrimary)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Food food, AppProvider provider) {
    final qty = provider.cart[food.id] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: qty > 0 ? AppTheme.receiverPrimary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: qty > 0 ? AppTheme.receiverPrimary.withOpacity(0.2) : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: food.image.isNotEmpty 
              ? Image.network(food.image, fit: BoxFit.cover)
              : const Icon(Icons.fastfood, color: AppTheme.receiverPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${food.quantity} items available', style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
              ],
            ),
          ),
          if (qty == 0)
            IconButton(
              onPressed: () => provider.addToCart(food.id),
              icon: const Icon(Icons.add_circle, color: AppTheme.receiverPrimary),
            )
          else
            Row(
              children: [
                IconButton(onPressed: () => provider.removeFromCart(food.id), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => provider.addToCart(food.id), icon: const Icon(Icons.add_circle, color: AppTheme.receiverPrimary, size: 20)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(AppProvider provider, ShopDetails shop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${provider.cartCount} Items Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Free Donation', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.sendCartRequest(shop.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requests sent!'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.receiverPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Send Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏙️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
