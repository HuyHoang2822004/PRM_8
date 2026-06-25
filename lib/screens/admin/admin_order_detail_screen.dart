import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/order.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.order});

  final Order order;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  bool _isProcessing = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isProcessing = true);
    final products = context.read<ProductProvider>().products;
    
    final success = await context.read<OrderProvider>().updateOrderStatus(
      widget.order.id,
      newStatus,
      products,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật trạng thái đơn hàng thành: $newStatus')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.decimalPattern('vi');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    // Determine status badge color
    Color statusBgColor;
    Color statusTextColor;
    switch (widget.order.status) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CHI TIẾT ĐƠN HÀNG'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & ID Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Mã đơn hàng:',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              Text(
                                widget.order.id,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ngày đặt hàng:',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              Text(
                                dateFormat.format(widget.order.createdAt),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Trạng thái hiện tại:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.order.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Customer Info Card
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'THÔNG TIN KHÁCH HÀNG',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5, color: AppColors.textSecondary),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.person_outline, 'Người nhận', widget.order.receiverName),
                          const Divider(height: 20),
                          _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', widget.order.phone),
                          const Divider(height: 20),
                          _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ giao hàng', widget.order.address),
                          const Divider(height: 20),
                          _buildInfoRow(
                            Icons.payment_outlined,
                            'Phương thức thanh toán',
                            widget.order.paymentMethod == 'COD' ? 'Thanh toán COD' : 'Chuyển khoản Ngân hàng',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Products Card
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'DANH SÁCH ĐỒNG HỒ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5, color: AppColors.textSecondary),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ...widget.order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      item.product.image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade100,
                                        child: const Icon(Icons.watch, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Màu: ${item.color} | Dây: ${item.strap}',
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Đơn giá: ${currencyFormat.format(item.product.activePrice)}đ',
                                          style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng thanh toán',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '${currencyFormat.format(widget.order.totalAmount)}đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons based on status
                  _buildActionButtons(widget.order.status),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String currentStatus) {
    if (currentStatus == 'Hoàn thành' || currentStatus == 'Đã hủy') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              currentStatus == 'Hoàn thành' ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: currentStatus == 'Hoàn thành' ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              currentStatus == 'Hoàn thành' ? 'Đơn hàng đã hoàn thành' : 'Đơn hàng đã bị hủy bỏ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: currentStatus == 'Hoàn thành' ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ),
      );
    }

    String primaryActionText = '';
    String nextStatus = '';
    IconData primaryIcon = Icons.check;

    if (currentStatus == 'Chờ duyệt') {
      primaryActionText = 'Duyệt đơn hàng';
      nextStatus = 'Đã duyệt';
      primaryIcon = Icons.approval;
    } else if (currentStatus == 'Đã duyệt') {
      primaryActionText = 'Giao hàng';
      nextStatus = 'Đang giao';
      primaryIcon = Icons.local_shipping_outlined;
    } else if (currentStatus == 'Đang giao') {
      primaryActionText = 'Hoàn thành';
      nextStatus = 'Hoàn thành';
      primaryIcon = Icons.done_all;
    }

    return Column(
      children: [
        // Primary Status Advancing button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(primaryIcon, size: 18),
            label: Text(
              primaryActionText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () => _updateStatus(nextStatus),
          ),
        ),
        const SizedBox(height: 12),
        
        // Cancel order button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text(
              'Hủy đơn hàng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận hủy đơn'),
                  content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        _updateStatus('Đã hủy');
                      },
                      child: const Text('Hủy đơn'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
