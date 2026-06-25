import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/order.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  String _selectedStatus = 'Tất cả';
  final List<String> _statuses = ['Tất cả', 'Chờ duyệt', 'Đã duyệt', 'Đang giao', 'Hoàn thành', 'Đã hủy'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrders();
    });
  }

  void _refreshOrders() {
    final products = context.read<ProductProvider>().products;
    context.read<OrderProvider>().fetchAllOrders(products);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final currencyFormat = NumberFormat.decimalPattern('vi');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Filter orders based on status
    final filteredOrders = orderProvider.allOrders.where((order) {
      if (_selectedStatus == 'Tất cả') return true;
      return order.status == _selectedStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshOrders();
        },
        color: AppColors.accent,
        child: Column(
          children: [
            // Status Filters Row
            Container(
              height: 60,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: _statuses.length,
                itemBuilder: (context, index) {
                  final status = _statuses[index];
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            
            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Không có đơn hàng nào',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kéo xuống để tải lại dữ liệu.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];

                        // Badge Colors
                        Color statusBgColor;
                        Color statusTextColor;
                        switch (order.status) {
                          case 'Đang giao':
                            statusBgColor = Colors.blue.shade50;
                            statusTextColor = Colors.blue.shade700;
                            break;
                          case 'Hoàn thành':
                            statusBgColor = Colors.green.shade50;
                            statusTextColor = Colors.green.shade700;
                            break;
                          case 'Đã hủy':
                            statusBgColor = Colors.red.shade50;
                            statusTextColor = Colors.red.shade700;
                            break;
                          case 'Chờ duyệt':
                          default:
                            statusBgColor = Colors.orange.shade50;
                            statusTextColor = Colors.orange.shade700;
                            break;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border, width: 0.5),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push(AppRoutes.adminOrderDetail, extra: order);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Order Header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Mã: ${order.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusBgColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          order.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: statusTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Customer Info
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        order.receiverName,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        order.phone,
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Items count summary
                                  Row(
                                    children: [
                                      const Icon(Icons.watch_outlined, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          order.items.map((i) => '${i.product.name} (x${i.quantity})').join(', '),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  
                                  // Total Payment and Date
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateFormat.format(order.createdAt),
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      Text(
                                        'Tổng: ${currencyFormat.format(order.totalAmount)}đ',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
