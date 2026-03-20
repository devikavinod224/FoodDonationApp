import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onShopDetails;
  final VoidCallback onLogout;

  const SettingsPage({
    super.key,
    required this.onShopDetails,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.shopkeeperProfile;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.shopkeeperPrimary.withOpacity(0.1),
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'S',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.shopkeeperPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  '@${profile.username}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ],
            ),
          ),

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Account Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1)),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  icon: Icons.store_outlined,
                  title: 'Shop Details',
                  subtitle: 'Update your shop info',
                  onTap: onShopDetails,
                ),
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile Info',
                  subtitle: 'Update name and email',
                ),
                const SizedBox(height: 24),
                const Text('App Preference', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1)),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Enable or disable alerts',
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy & Security',
                  subtitle: 'Change your password',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onLogout,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFFEE2E2)),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'App Version 1.0.0',
                    style: TextStyle(fontSize: 10, color: AppTheme.textLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.shopkeeperPrimary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)) : null,
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textLight),
      ),
    );
  }
}
