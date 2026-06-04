import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../cart/cart_screen.dart';
import '../chat/chat_screen.dart';
import '../map/map_screen.dart';
import '../notification/notification_screen.dart';
import '../product/product_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;

  final _pages = const [
    ProductListScreen(),
    CartScreen(),
    NotificationScreen(),
    MapScreen(),
    ChatScreen(),
  ];

  final _titles = const [
    'CHRONO LUXURY',
    'GIỎ HÀNG CỦA BẠN',
    'THÔNG BÁO',
    'CỬA HÀNG BẢN ĐỒ',
    'HỖ TRỢ TRỰC TUYẾN',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final notification = context.watch<NotificationProvider>();
    
    // Count unread notifications
    final unreadCount = notification.notifications.where((n) => !n.isRead).length;

    // Badged icons
    Widget cartIcon = Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_bag_outlined),
        if (cart.totalQuantity > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${cart.totalQuantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );

    Widget notifyIcon = Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_outlined),
        if (unreadCount > 0)
          Positioned(
            right: -4,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 10,
                minHeight: 10,
              ),
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/checkout'),
            icon: cartIcon,
            tooltip: 'Thanh toán',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        elevation: 1,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.accent.withOpacity(0.9),
                  child: Text(
                    auth.userProfile['name']?.substring(0, 1).toUpperCase() ?? 'K',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                accountName: Text(
                  auth.userProfile['name'] ?? 'Khách hàng',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                accountEmail: Text(
                  auth.userProfile['email'] ?? 'Chưa đăng nhập',
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 13),
                ),
              ),
              if (auth.userProfile['phone'] != null && auth.userProfile['phone']!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  title: const Text('Số điện thoại', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(auth.userProfile['phone']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
              if (auth.userProfile['address'] != null && auth.userProfile['address']!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  title: const Text('Địa chỉ giao hàng', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(auth.userProfile['address']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
              const Divider(),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất tài khoản', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await auth.logout();
                  if (!context.mounted) return;
                  context.go('/login');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: isDesktop
          ? Row(
              children: [
                // Elegant Side Navigation Rail for Desktop
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) => setState(() => _index = value),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  elevation: 1,
                  minWidth: 90,
                  indicatorColor: AppColors.primary.withOpacity(0.08),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.watch_outlined),
                      selectedIcon: Icon(Icons.watch, color: AppColors.primary),
                      label: Text('Sản phẩm', style: TextStyle(fontSize: 11)),
                    ),
                    NavigationRailDestination(
                      icon: cartIcon,
                      label: const Text('Giỏ hàng', style: TextStyle(fontSize: 11)),
                    ),
                    NavigationRailDestination(
                      icon: notifyIcon,
                      label: const Text('Thông báo', style: TextStyle(fontSize: 11)),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map, color: AppColors.primary),
                      label: Text('Địa chỉ', style: TextStyle(fontSize: 11)),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_outline),
                      selectedIcon: Icon(Icons.chat_bubble, color: AppColors.primary),
                      label: Text('Hỗ trợ', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
                // Main Page Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutQuad,
                    switchOutCurve: Curves.easeInQuad,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(_index),
                      child: _pages[_index],
                    ),
                  ),
                ),
              ],
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutQuad,
              switchOutCurve: Curves.easeInQuad,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(_index),
                child: _pages[_index],
              ),
            ),
      bottomNavigationBar: isDesktop
          ? null // No bottom bar on desktop
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.watch_outlined),
                  selectedIcon: Icon(Icons.watch, color: AppColors.primary),
                  label: 'Sản phẩm',
                ),
                NavigationDestination(
                  icon: cartIcon,
                  label: 'Giỏ hàng',
                ),
                NavigationDestination(
                  icon: notifyIcon,
                  label: 'Thông báo',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map, color: AppColors.primary),
                  label: 'Cửa hàng',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble, color: AppColors.primary),
                  label: 'Hỗ trợ',
                ),
              ],
            ),
    );
  }
}
