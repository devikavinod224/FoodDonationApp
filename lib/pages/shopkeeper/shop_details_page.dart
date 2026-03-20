import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/profile_details.dart';

class ShopDetailsPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSaved;

  const ShopDetailsPage({
    super.key,
    required this.onBack,
    required this.onSaved,
  });

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _ownerController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final details = Provider.of<AppProvider>(context, listen: false).shopDetails;
    _nameController = TextEditingController(text: details.shopName);
    _locationController = TextEditingController(text: details.shopLocation);
    _aboutController = TextEditingController(text: details.aboutShop);
    _ownerController = TextEditingController(text: details.ownerName);
    _phoneController = TextEditingController(text: details.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shop Details', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField('Shop Name', _nameController, Icons.storefront),
            _buildField('Shop Location', _locationController, Icons.location_on_outlined),
            _buildField('About Shop', _aboutController, Icons.info_outline, maxLines: 3),
            _buildField('Owner Name', _ownerController, Icons.person_outline),
            _buildField('Phone Number', _phoneController, Icons.phone_outlined),
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
                child: ElevatedButton(
                  onPressed: () {
                    final provider = Provider.of<AppProvider>(context, listen: false);
                    provider.updateShopDetails(ShopDetails(
                      shopName: _nameController.text,
                      shopLocation: _locationController.text,
                      aboutShop: _aboutController.text,
                      ownerName: _ownerController.text,
                      phone: _phoneController.text,
                      shopImageUrl: provider.shopDetails.shopImageUrl,
                    ));
                    widget.onSaved();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Save Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
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
            decoration: InputDecoration(
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
