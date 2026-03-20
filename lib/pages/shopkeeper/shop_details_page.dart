import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/profile_details.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/permission_service.dart';

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
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final details = Provider.of<AppProvider>(context, listen: false).shopDetails;
    if (details != null) {
      _nameController = TextEditingController(text: details.shopName);
      _locationController = TextEditingController(text: details.shopLocation);
      _aboutController = TextEditingController(text: details.aboutShop);
      _ownerController = TextEditingController(text: details.ownerName);
      _phoneController = TextEditingController(text: details.phone);
    } else {
      _nameController = TextEditingController();
      _locationController = TextEditingController();
      _aboutController = TextEditingController();
      _ownerController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final hasPermission = source == ImageSource.camera 
        ? await PermissionService.requestCameraPermission()
        : await PermissionService.requestGalleryPermission();
        
    if (hasPermission) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
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
            // Shop Image
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: _imageFile != null 
                        ? FileImage(_imageFile!) 
                        : (Provider.of<AppProvider>(context).shopDetails?.shopImageUrl.isNotEmpty ?? false)
                            ? NetworkImage(Provider.of<AppProvider>(context).shopDetails!.shopImageUrl) as ImageProvider
                            : null,
                    child: _imageFile == null && !(Provider.of<AppProvider>(context).shopDetails?.shopImageUrl.isNotEmpty ?? false)
                        ? Icon(Icons.storefront, size: 40, color: Colors.grey.shade400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.shopkeeperPrimary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
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
                  onPressed: () async {
                    final provider = Provider.of<AppProvider>(context, listen: false);
                    String? imageUrl = provider.shopDetails?.shopImageUrl ?? '';

                    if (_imageFile != null) {
                      final uploadedUrl = await provider.uploadImage(_imageFile!.path);
                      if (uploadedUrl != null) {
                        imageUrl = uploadedUrl;
                      }
                    }

                    await provider.updateShopDetails(ShopDetails(
                      shopName: _nameController.text,
                      shopLocation: _locationController.text,
                      aboutShop: _aboutController.text,
                      ownerName: _ownerController.text,
                      phone: _phoneController.text,
                      shopImageUrl: imageUrl,
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
