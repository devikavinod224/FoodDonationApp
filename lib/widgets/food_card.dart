import 'package:flutter/material.dart';
import '../models/food.dart';
import '../theme/app_theme.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final Color categoryBg;
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.food,
    required this.categoryBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: categoryBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildImage(),
              ),
            ),
...
  Widget _buildImage() {
    if (food.image.startsWith('http')) {
      return Image.network(
        food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        food.image.length == 1 || food.image.length == 2 ? food.image : "🍽️",
        style: const TextStyle(fontSize: 40),
      ),
    );
  }
            // Info Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    food.ingredients,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4), // green-50
                          border: Border.all(color: const Color(0xFFDCFCE7)), // green-100
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${food.quantity} left',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A), // green-600
                          ),
                        ),
                      ),
                      const Text(
                        'FREE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.shopkeeperPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
