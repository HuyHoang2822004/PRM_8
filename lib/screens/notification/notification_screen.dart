import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/chat_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().listenToNotifications();
    });
  }

  void _handleNotificationTap(BuildContext context, AppNotification item) {
    // Mark as read
    context.read<NotificationProvider>().markAsRead(item.id);

    if (item.type == 'new_product') {
      int? prodId;
      if (item.relatedId is int) {
        prodId = item.relatedId as int;
      } else if (item.relatedId != null) {
        prodId = int.tryParse(item.relatedId.toString());
      }
      if (prodId != null) {
        final product = context.read<ProductProvider>().getProductById(prodId);
        if (product != null) {
          context.push(AppRoutes.productDetail, extra: product);
          return;
        }
      }
    } else if (item.type == 'order_confirmed' ||
        item.type == 'order_shipping' ||
        item.type == 'order_completed') {
      final orderId = item.relatedId?.toString() ?? '';
      final ordersList = context.read<OrderProvider>().orders;
      final idx = ordersList.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        context.push(AppRoutes.orderDetail, extra: ordersList[idx]);
      } else {
        context.push(AppRoutes.orderHistory);
      }
      return;
    } else if (item.type == 'store') {
      context.read<ChatProvider>().requestTab(2);
      if (context.canPop()) {
        context.pop();
      }
      return;
    } else if (item.type == 'chat') {
      context.read<ChatProvider>().requestTab(3);
      if (context.canPop()) {
        context.pop();
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.body,
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Gửi lúc: ${item.timeAgo}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'THÔNG BÁO',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: Consumer<NotificationProvider>(
        builder: (_, provider, __) {
          if (provider.notifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Không có thông báo nào',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Bạn sẽ nhận được các thông tin khuyến mãi và cập nhật đơn hàng tại đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = provider.notifications[index];
              final isUnread = !item.isRead;
              
              // Decide icon based on title
              IconData iconData = Icons.campaign_outlined;
              if (item.title.contains('đơn hàng') || item.title.contains('Đơn hàng')) {
                iconData = Icons.local_shipping_outlined;
              } else if (item.title.contains('Rolex')) {
                iconData = Icons.stars_outlined;
              }

              return Card(
                color: isUnread ? Colors.white : Colors.grey.shade50,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isUnread ? AppColors.primary.withOpacity(0.08) : Colors.grey.shade100,
                    child: Icon(
                      iconData,
                      color: isUnread ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.timeAgo,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  onTap: () => _handleNotificationTap(context, item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
