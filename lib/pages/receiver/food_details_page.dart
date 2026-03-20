import 'package:flutter/material.dart';
import '../../models/food.dart';
import '../../theme/app_theme.dart';

class FoodDetailsPage extends StatefulWidget {
  final Food food;
  final VoidCallback onBack;
  final Function(int) onRequest;

  const FoodDetailsPage({
    super.key,
    required this.food,
    required this.onBack,
    required this.onRequest,
  });

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header / Image Area
          Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  child: _buildImage(),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.receiverPrimary, size: 16),
                      const SizedBox(width: 4),
                      Text('Verified by ${widget.food.shopName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.food.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              const SizedBox(height: 4),
                              Text(widget.food.category, style: const TextStyle(fontSize: 14, color: AppTheme.receiverPrimary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                          child: const Text('FREE', style: TextStyle(color: AppTheme.receiverPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.food.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5)),
                    const SizedBox(height: 20),
                    const Text('Main Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.food.ingredients, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    
                    const Spacer(),

                    // Quantity Control
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            _buildQtyBtn(Icons.remove, () { if (_quantity > 1) setState(() => _quantity--); }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            _buildQtyBtn(Icons.add, () { if (_quantity < widget.food.quantity) setState(() => _quantity++); }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Request Button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.receiverPrimary, AppTheme.receiverSecondary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppTheme.receiverPrimary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => widget.onRequest(_quantity),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text('Request Pickup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.food.image.startsWith('http')) {
      return Image.network(
        widget.food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        widget.food.image.length == 1 || widget.food.image.length == 2 
          ? widget.food.image 
          : "🥘",
        style: const TextStyle(fontSize: 120),
      ),
    );
  }
}
