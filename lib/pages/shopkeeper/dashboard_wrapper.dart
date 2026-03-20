import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/food.dart';
import 'home_page.dart';
import 'requests_page.dart';
import 'library_page.dart';
import 'settings_page.dart';
import 'shop_details_page.dart';
import 'add_food_page.dart';
import '../../widgets/modals/save_success_modal.dart';

class ShopkeeperDashboardWrapper extends StatefulWidget {
  const ShopkeeperDashboardWrapper({super.key});

  @override
  State<ShopkeeperDashboardWrapper> createState() => _ShopkeeperDashboardWrapperState();
}

enum SubPage { none, shopDetails, addFood, editFood }

class _ShopkeeperDashboardWrapperState extends State<ShopkeeperDashboardWrapper> {
  int _selectedIndex = 0;
  SubPage _subPage = SubPage.none;
  Food? _editingFood;
  bool _showSuccess = false;
  String _successMessage = "";

  void _handleShowSuccess(String message) {
    setState(() {
      _successMessage = message;
      _showSuccess = true;
    });
  }

  void _handleSuccessDismiss() {
    setState(() {
      _showSuccess = false;
      _subPage = SubPage.none;
      _editingFood = null;
    });
  }

  void _handleEditFood(Food food) {
    setState(() {
      _editingFood = food;
      _subPage = SubPage.editFood;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_subPage == SubPage.shopDetails) {
      return Stack(
        children: [
          ShopDetailsPage(
            onBack: () => setState(() => _subPage = SubPage.none),
            onSaved: () => _handleShowSuccess("Shop details saved successfully!"),
          ),
          if (_showSuccess)
            SaveSuccessModal(
              message: _successMessage,
              onDismiss: _handleSuccessDismiss,
            ),
        ],
      );
    }

    if (_subPage == SubPage.addFood || _subPage == SubPage.editFood) {
      return Stack(
        children: [
          AddFoodPage(
            onBack: () => setState(() {
              _subPage = SubPage.none;
              _editingFood = null;
            }),
            onSaved: () => _handleShowSuccess(
              _editingFood != null ? "Food updated successfully!" : "Food added successfully!"
            ),
            editingFood: _editingFood,
          ),
          if (_showSuccess)
            SaveSuccessModal(
              message: _successMessage,
              onDismiss: _handleSuccessDismiss,
            ),
        ],
      );
    }

    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppTheme.shopkeeperPrimary,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ShopkeeperHomePage();
      case 1:
        return const RequestsPage();
      case 2:
        return LibraryPage(
          onAdd: () => setState(() => _subPage = SubPage.addFood),
          onEdit: _handleEditFood,
        );
      case 3:
        return SettingsPage(
          onShopDetails: () => setState(() => _subPage = SubPage.shopDetails),
          onLogout: () async {
            await Provider.of<AppProvider>(context, listen: false).logout();
            if (mounted) Navigator.of(context).pushReplacementNamed('/');
          },
        );
      default:
        return const ShopkeeperHomePage();
    }
  }
}
