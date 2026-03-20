import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login/shopkeeper_login.dart';
import 'login/receiver_login.dart';
import 'signup/create_account_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Logo and Title
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFB923C), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFB923C).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'FoodShare',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share surplus food, reduce waste',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Free food donation service',
                style: TextStyle(fontSize: 12, color: AppTheme.shopkeeperPrimary, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Shopkeeper Login Button
              _buildRoleButton(
                context: context,
                title: 'Shopkeeper Login',
                subtitle: 'Donate your surplus food',
                icon: Icons.store,
                color: AppTheme.shopkeeperPrimary,
                bgColor: const Color(0xFFFFF7ED), // orange-50
                borderColor: const Color(0xFFFFEDD5), // orange-100
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopkeeperLogin())),
              ),
              const SizedBox(height: 16),

              // Receiver Login Button
              _buildRoleButton(
                context: context,
                title: 'Receiver Login',
                subtitle: 'Collect free donated food',
                icon: Icons.person,
                color: AppTheme.receiverPrimary,
                bgColor: const Color(0xFFF0FDF4), // green-50
                borderColor: const Color(0xFFDCFCE7), // green-100
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiverLogin())),
              ),
              
              const Spacer(),
              
              // Illustration (Simplified Placeholder)
              _buildIllustration(),

              const SizedBox(height: 32),
              
              // Create Account Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountPage())),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(color: AppTheme.shopkeeperPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 180,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Plate
          Positioned(
            bottom: 16,
            child: Container(
              width: 144,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5), // orange-100
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Bowl
          Positioned(
            bottom: 24,
            child: Container(
              width: 112,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFED7AA), Color(0xFFFDBA74)], // orange-200 to 300
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(56), top: Radius.circular(8)),
              ),
            ),
          ),
          // Heart
          Positioned(
            top: 40,
            right: 24,
            child: Icon(Icons.favorite, color: Colors.red.shade400, size: 32),
          ),
          // Arrow
          const Positioned(
            top: 56,
            left: 16,
            child: Icon(Icons.arrow_forward, color: AppTheme.receiverPrimary, size: 24),
          ),
        ],
      ),
    );
  }
}
