import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/food.dart';

class AddFoodPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSaved;
  final Food? editingFood;

  const AddFoodPage({
    super.key,
    required this.onBack,
    required this.onSaved,
    this.editingFood,
  });

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _descController;
  late TextEditingController _ingController;
  String _selectedCategory = "Rice Item";
  String _selectedEmoji = "🍚";

  final List<Map<String, String>> _categories = [
    {"name": "Rice Item", "emoji": "🍚"},
    {"name": "Paratha Item", "emoji": "🫓"},
    {"name": "Drinking Item", "emoji": "🥤"},
    {"name": "Snack Item", "emoji": "🥟"},
    {"name": "Dessert Item", "emoji": "🍰"},
    {"name": "Curry Item", "emoji": "🥘"},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingFood?.name ?? "");
    _qtyController = TextEditingController(text: widget.editingFood?.quantity.toString() ?? "");
    _descController = TextEditingController(text: widget.editingFood?.description ?? "");
    _ingController = TextEditingController(text: widget.editingFood?.ingredients ?? "");
    if (widget.editingFood != null) {
      _selectedCategory = widget.editingFood!.category;
      _selectedEmoji = widget.editingFood!.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.editingFood == null ? 'Add Food' : 'Edit Food', style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Emoji Selector
            const Text('Food Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['name'];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = cat['name']!;
                      _selectedEmoji = cat['emoji']!;
                    }),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.shopkeeperPrimary : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppTheme.shopkeeperPrimary : Colors.grey.shade100, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat['emoji']!, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(
                            cat['name']!.split(' ')[0],
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            _buildField('Food Name', _nameController, Icons.fastfood_outlined, hint: 'e.g., Veg Fried Rice'),
            _buildField('Quantity (Portions)', _qtyController, Icons.production_quantity_limits, hint: 'e.g., 10', keyboardType: TextInputType.number),
            _buildField('Description', _descController, Icons.description_outlined, hint: 'Brief description...', maxLines: 2),
            _buildField('Ingredients', _ingController, Icons.list_alt, hint: 'Main ingredients...', maxLines: 2),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.shopkeeperPrimary, AppTheme.shopkeeperSecondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppTheme.shopkeeperPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: provider.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                      onPressed: () async {
                        final foodData = {
                          'name': _nameController.text.trim(),
                          'category': _selectedCategory,
                          'quantity': int.tryParse(_qtyController.text) ?? 0,
                          'image': _selectedEmoji, // Fallback if no image uploaded
                          'description': _descController.text.trim(),
                          'ingredients': _ingController.text.trim(),
                        };

                        bool success;
                        if (widget.editingFood == null) {
                          success = await provider.createFood(foodData);
                        } else {
                          success = await provider.updateFood(widget.editingFood!.id, foodData);
                        }

                        if (success && mounted) {
                          widget.onSaved();
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to save food item.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: Text(
                        widget.editingFood == null ? 'Add to Library' : 'Update Item',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {String? hint, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppTheme.textLight),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.shopkeeperPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
