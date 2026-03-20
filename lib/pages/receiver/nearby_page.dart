import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    // Mock shops for now (as in the React codebase)
    final shops = [
      {
        "id": "1",
        "name": "Sunshine Bakery",
        "distance": "0.8 km",
        "rating": "4.8",
        "items": "12 items available",
        "image": "🥖"
      },
      {
        "id": "2",
        "name": "Fresh Mart",
        "distance": "1.2 km",
        "rating": "4.5",
        "items": "8 items available",
        "image": "🛒"
      },
      {
        "id": "3",
        "name": "Community Kitchen",
        "distance": "1.5 km",
        "rating": "4.9",
        "items": "25 items available",
        "image": "🍲"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header with Mock Map Background
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&q=80&w=1000'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.receiverPrimary),
                        SizedBox(width: 8),
                        Expanded(child: Text('Your current location', style: TextStyle(fontWeight: FontWeight.bold))),
                        Icon(Icons.gps_fixed, color: AppTheme.textLight, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Shops List
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text(shop['image']!, style: const TextStyle(fontSize: 32))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(shop['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(shop['rating']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  Text(shop['distance']!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(shop['items']!, style: const TextStyle(fontSize: 12, color: AppTheme.receiverPrimary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.textLight),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
