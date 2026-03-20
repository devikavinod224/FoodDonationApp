import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/food_request.dart';
import '../../widgets/request_card.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  String _activeFilter = "all";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shopkeeper = provider.shopkeeperProfile;
    if (shopkeeper == null) {
      return const Scaffold(body: Center(child: Text("Please login first")));
    }

    final shopId = shopkeeper.id;
    final allRequests = provider.requests;

    final filteredRequests = _activeFilter == "all"
        ? allRequests
        : allRequests.where((r) => r.status.name == _activeFilter).toList();

    final pendingCount = allRequests.where((r) => r.status == RequestStatus.pending).length;
    final acceptedCount = allRequests.where((r) => r.status == RequestStatus.accepted).length;
    final rejectedCount = allRequests.where((r) => r.status == RequestStatus.rejected).length;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Requests',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'Manage food collection requests',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pendingCount pending',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.shopkeeperPrimary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterTab('all', 'All', allRequests.length),
                      _buildFilterTab('pending', 'Pending', pendingCount),
                      _buildFilterTab('accepted', 'Accepted', acceptedCount),
                      _buildFilterTab('rejected', 'Rejected', rejectedCount),
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
                        isShopkeeperView: true,
                        onAccept: () => provider.updateRequestStatus(req.id, RequestStatus.accepted),
                        onReject: () => provider.updateRequestStatus(req.id, RequestStatus.rejected),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String key, String label, int count) {
    final bool isSelected = _activeFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.shopkeeperPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.shopkeeperPrimary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No requests yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('When receivers request your food, they\'ll appear here', style: TextStyle(fontSize: 12, color: AppTheme.textLight), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
