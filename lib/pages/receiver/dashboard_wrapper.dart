import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/food.dart';
import '../../models/food_request.dart';
import 'home_page.dart';
import 'nearby_page.dart';
import 'my_requests_page.dart';
import 'profile_page.dart';
import 'food_details_page.dart';
import '../../widgets/modals/save_success_modal.dart';

class ReceiverDashboardWrapper extends StatefulWidget {
  const ReceiverDashboardWrapper({super.key});

  @override
  State<ReceiverDashboardWrapper> createState() => _ReceiverDashboardWrapperState();
}

class _ReceiverDashboardWrapperState extends State<ReceiverDashboardWrapper> {
  int _selectedIndex = 0;
  Food? _selectedFood;
  bool _showSuccess = false;

  void _handleRequestFood(int qty) async {
    if (_selectedFood == null) return;
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    final success = await provider.sendRequest(_selectedFood!.id, qty);
    
    if (success && mounted) {
      setState(() => _showSuccess = true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send request. Please try again.')),
      );
    }
  }

  void _handleSuccessDismiss() {
    setState(() {
      _showSuccess = false;
      _selectedFood = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedFood != null) {
      return Stack(
        children: [
          FoodDetailsPage(
            food: _selectedFood!,
            onBack: () => setState(() => _selectedFood = null),
            onRequest: _handleRequestFood,
          ),
          if (_showSuccess)
            SaveSuccessModal(
              message: "Your food request has been sent to the shopkeeper!",
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
          selectedItemColor: AppTheme.receiverPrimary,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'My Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.near_me_outlined), activeIcon: Icon(Icons.near_me), label: 'Nearby'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return ReceiverHomePage(onFoodSelect: (food) => setState(() => _selectedFood = food));
      case 1:
        return const MyRequestsPage();
      case 2:
        return const NearbyPage();
      case 3:
        return ReceiverProfilePage(
          onLogout: () async {
            await Provider.of<AppProvider>(context, listen: false).logout();
            if (mounted) Navigator.of(context).pushReplacementNamed('/');
          },
        );
      default:
        return ReceiverHomePage(onFoodSelect: (food) => setState(() => _selectedFood = food));
    }
  }
}
