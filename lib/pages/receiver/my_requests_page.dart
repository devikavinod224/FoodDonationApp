import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/food_request.dart';
import '../../widgets/request_card.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  String _activeFilter = "all";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final receiver = provider.receiverProfile;
    if (receiver == null) {
      return const Scaffold(body: Center(child: Text("Please login first")));
    }

    final receiverId = receiver.id;
    final allRequests = provider.requests;

    final filteredRequests = _activeFilter == "all"
        ? allRequests
        : allRequests.where((r) => r.status.name == _activeFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Requests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  'Track your food collection progress',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterTab('all', 'All'),
                      _buildFilterTab('pending', 'Pending'),
                      _buildFilterTab('accepted', 'Accepted'),
                      _buildFilterTab('rejected', 'Rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: filteredRequests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final req = filteredRequests[index];
                      return RequestCard(
                        request: req,
                        isShopkeeperView: false,
                        onAccept: () {},
                        onReject: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String key, String label) {
    final bool isSelected = _activeFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.receiverPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No requests found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('Your requests will appear here after you find food', style: TextStyle(fontSize: 12, color: AppTheme.textLight), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
