import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_request.dart';
import '../theme/app_theme.dart';

class RequestCard extends StatelessWidget {
  final FoodRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isShopkeeperView;

  const RequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    this.isShopkeeperView = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = request.status == RequestStatus.pending;
    final bool isAccepted = request.status == RequestStatus.accepted;
    final bool isRejected = request.status == RequestStatus.rejected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isAccepted 
          ? const Color(0xFFF0FDF4).withOpacity(0.5) 
          : isRejected 
            ? const Color(0xFFFEF2F2).withOpacity(0.5) 
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted 
            ? const Color(0xFFBBF7D0) 
            : isRejected 
              ? const Color(0xFFFECACA) 
              : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Food Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF7ED), Color(0xFFFFFBEB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildImage(),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.foodName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(request.foodCategory, style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 12, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(
                            isShopkeeperView ? request.receiverName : request.shopName,
                            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(width: 8),
                          Text(
                            'Qty: ${request.requestedQty}',
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold, 
                              color: isShopkeeperView ? AppTheme.shopkeeperPrimary : AppTheme.receiverPrimary
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                if (!isPending || !isShopkeeperView)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAccepted 
                        ? const Color(0xFFDCFCE7) 
                        : isRejected 
                          ? const Color(0xFFFEE2E2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAccepted ? 'Accepted' : isRejected ? 'Rejected' : 'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAccepted 
                          ? const Color(0xFF15803D) 
                          : isRejected 
                            ? const Color(0xFFB91C1C)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            if (isPending && isShopkeeperView) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF3F4F6), height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        foregroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFFEE2E2)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Accept'),
                         style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (request.foodImage.startsWith('http')) {
      return Image.network(
        request.foodImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        request.foodImage.length == 1 || request.foodImage.length == 2 
          ? request.foodImage 
          : "🥘",
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}
