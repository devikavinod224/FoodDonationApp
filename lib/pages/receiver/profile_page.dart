import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class ReceiverProfilePage extends StatelessWidget {
  final VoidCallback onLogout;

  const ReceiverProfilePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.receiverProfile;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.receiverPrimary, AppTheme.receiverSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'R',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '@${profile.username}',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),

          // Stats / Info
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                _buildStat('Requests', provider.requests.length.toString(), Icons.assignment_outlined),
                const SizedBox(width: 16),
                _buildStat('Collected', provider.requests.where((r) => r.status == RequestStatus.accepted).length.toString(), Icons.check_circle_outline),
              ],
            ),
          ),

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text('Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1)),
                const SizedBox(height: 16),
                _buildOption(Icons.person_outline, 'Personal Information'),
                _buildOption(Icons.notifications_none, 'Notification Preferences'),
                _buildOption(Icons.history, 'Collection History'),
                _buildOption(Icons.help_outline, 'Help & Support'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onLogout,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFFEE2E2)),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text('Logout Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.receiverPrimary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textSecondary, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textLight),
      ),
    );
  }
}
