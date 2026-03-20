import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../services/permission_service.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/permission_service.dart';
import '../../models/profile_details.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final MapController _mapController = MapController();
  final PanelController _panelController = PanelController();
  LatLng _currentLocation = const LatLng(12.9716, 77.5946); // Default: Bangalore
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final granted = await PermissionService.requestLocationPermission();
      if (granted) {
        // Get initial position
        final pos = await PermissionService.getCurrentLocation();
        if (pos != null && mounted) {
          setState(() {
            _currentLocation = LatLng(pos.latitude, pos.longitude);
            _isLoadingLocation = false;
          });
          _mapController.move(_currentLocation, 14);
          Provider.of<AppProvider>(context, listen: false).fetchNearbyShops(pos.latitude, pos.longitude);
        }

        // Start live tracking
        _positionStream = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
            });
          }
        });
      }
    } catch (e) {
      print('Location Error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _recenter() {
     _mapController.move(_currentLocation, 14);
     Provider.of<AppProvider>(context, listen: false).fetchNearbyShops(_currentLocation.latitude, _currentLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final shops = provider.nearbyShops;

    // Create custom markers for shops
    final markers = shops.map((shop) => Marker(
      point: LatLng(shop.lat, shop.lng),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _showShopDetails(shop),
        child: _buildCustomMarker(shop),
      ),
    )).toList();

    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        minHeight: 120,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        panel: _buildPanel(provider, shops),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 14,
                onTap: (_, __) => _panelController.close(),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.food.donation',
                ),
                MarkerLayer(
                  markers: [
                    // User current location marker (Animated-like)
                    Marker(
                      point: _currentLocation,
                      width: 50,
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(color: AppTheme.receiverPrimary.withOpacity(0.2), shape: BoxShape.circle),
                          ),
                          Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppTheme.receiverPrimary, width: 2)),
                            child: Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.receiverPrimary, shape: BoxShape.circle))),
                          ),
                        ],
                      ),
                    ),
                    ...markers,
                  ],
                ),
              ],
            ),
            
            // Search Bar / Overlay top
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: _buildTopSearchBar(),
            ),

            // Recenter Button - Better Styling
            Positioned(
              right: 20,
              bottom: 150, // Moved up slightly
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'recenter',
                    onPressed: _recenter,
                    backgroundColor: Colors.white,
                    elevation: 4,
                    child: const Icon(Icons.my_location, color: AppTheme.receiverPrimary),
                  ),
                ],
              ),
            ),

            if (_isLoadingLocation)
              const Center(child: CircularProgressIndicator(color: AppTheme.receiverPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomMarker(ShopDetails shop) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            border: Border.all(color: AppTheme.receiverPrimary.withOpacity(0.3), width: 1),
          ),
          child: Container(
            width: 35,
            height: 35,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade100),
            child: shop.shopImageUrl.isNotEmpty
              ? Image.network(shop.shopImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 20))
              : const Icon(Icons.store, size: 20, color: AppTheme.receiverPrimary),
          ),
        ),
        // Pin tip
        Container(
          width: 8,
          height: 8,
          transform: Matrix4.translationValues(0, -2, 0),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.receiverPrimary, shape: BoxShape.circle))),
        ),
      ],
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
      // No headers needed for basic Nominatim, but user-agent is recommended
      final res = await Provider.of<AppProvider>(context, listen: false).api.dio.get(url.toString());
      
      if (res.data is List && res.data.isNotEmpty) {
        final location = res.data[0];
        final lat = double.parse(location['lat']);
        final lon = double.parse(location['lon']);
        
        setState(() {
          _currentLocation = LatLng(lat, lon);
        });
        _mapController.move(_currentLocation, 14);
        Provider.of<AppProvider>(context, listen: false).fetchNearbyShops(lat, lon);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found. Try a more specific name.')),
          );
        }
      }
    } catch (e) {
      print('Search Location Error: $e');
    }
  }

  Widget _buildTopSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onSubmitted: (val) => _searchLocation(val),
        decoration: const InputDecoration(
          hintText: 'Search your real place (city, street...)',
          hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppTheme.receiverPrimary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPanel(AppProvider provider, List<ShopDetails> shops) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nearby Shops (${shops.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View List')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: provider.isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.receiverPrimary))
            : shops.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: shops.length,
                  itemBuilder: (context, index) => _buildShopCard(shops[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildShopCard(ShopDetails shop) {
    return GestureDetector(
      onTap: () => _showShopDetails(shop),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
              child: shop.shopImageUrl.isNotEmpty
                ? Image.network(shop.shopImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 30))
                : const Icon(Icons.store, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.shopName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppTheme.receiverPrimary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(shop.shopLocation, style: const TextStyle(fontSize: 12, color: AppTheme.textLight), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(shop.distance ?? 'Nearby', style: const TextStyle(fontSize: 12, color: AppTheme.receiverPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No shops found nearby', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _showShopDetails(ShopDetails shop) {
    // Fetch real foods for this shop
    Provider.of<AppProvider>(context, listen: false).fetchFoodsByShop(shop.id);
    
    _panelController.close();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShopDetailSheet(shop),
    );
  }

  Widget _buildShopDetailSheet(ShopDetails shop) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final foods = provider.shopFoods;
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80, height: 80,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.shade100),
                            child: shop.shopImageUrl.isNotEmpty 
                              ? Image.network(shop.shopImageUrl, fit: BoxFit.cover)
                              : const Icon(Icons.store, size: 40),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shop.shopName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(shop.shopLocation, style: const TextStyle(color: AppTheme.textLight)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('About this Shop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(shop.aboutShop.isNotEmpty ? shop.aboutShop : 'Help us reduce food waste by requesting donations from this shop.', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Donations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (provider.cart.isNotEmpty)
                            TextButton(onPressed: () => provider.clearCart(), child: const Text('Clear Cart', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (provider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (foods.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No available donations at this moment.', style: TextStyle(color: AppTheme.textLight))))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: foods.length,
                          itemBuilder: (context, index) => _buildMenuItem(foods[index], provider),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Cart Summary & CTA
              if (provider.cart.isNotEmpty)
                _buildCartSummary(provider, shop),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMenuItem(dynamic food, AppProvider provider) {
    final qty = provider.cart[food.id] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: qty > 0 ? AppTheme.receiverPrimary.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: qty > 0 ? AppTheme.receiverPrimary.withOpacity(0.2) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
            child: food.imageUrl.isNotEmpty 
              ? Image.network(food.imageUrl, fit: BoxFit.cover)
              : const Icon(Icons.fastfood, size: 24, color: AppTheme.receiverPrimary),
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
              icon: const Icon(Icons.add_circle, color: AppTheme.receiverPrimary, size: 28),
            )
          else
            Row(
              children: [
                IconButton(onPressed: () => provider.removeFromCart(food.id), icon: const Icon(Icons.remove_circle_outline, size: 24)),
                Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => provider.addToCart(food.id), icon: const Icon(Icons.add_circle, color: AppTheme.receiverPrimary, size: 24)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(AppProvider provider, ShopDetails shop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${provider.cartCount} items selected', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Free Donation', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final success = await provider.sendCartRequest(shop.id);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Requests sent successfully!'), backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.receiverPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: provider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Send Group Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
