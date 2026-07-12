import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/chat_provider.dart';
import '../cart/cart_screen.dart';
import '../chat/chat_screen.dart';
import '../map/map_screen.dart';
import '../product/product_list_screen.dart';
import '../admin/admin_order_list_screen.dart';
import '../admin/admin_product_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _index;

  final _pages = const [
    ProductListScreen(),
    CartScreen(),
    MapScreen(),
    ChatScreen(),
  ];

  final _titles = const [
    AppStrings.homeTitle,
    AppStrings.cartTitle,
    AppStrings.mapTitle,
    AppStrings.chatTitle,
  ];

  @override
  void initState() {
    super.initState();
    _index = _normalizeTabIndex(widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productProvider = context.read<ProductProvider>();
      productProvider.listenToProducts();
      if (mounted) {
        final myEmail = context.read<AuthProvider>().userProfile['email'] ?? 'guest';
        final isManager = myEmail == 'admin@chrono.com';

        final chatProvider = context.read<ChatProvider>();
        chatProvider.setCurrentUserEmail(myEmail);
        chatProvider.startListeningToMessages();
        
        context.read<NotificationProvider>().listenToNotifications();
        
        final orderProvider = context.read<OrderProvider>();
        orderProvider.listenToOrders(productProvider.products);
        if (isManager) {
          orderProvider.listenToAllOrders(productProvider.products);
        }
      }
    });
  }

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      final normalized = _normalizeTabIndex(widget.initialIndex);
      if (_index != normalized) {
        _index = normalized;
      }
    }
  }

  int _normalizeTabIndex(int index) {
    if (index == 4) return 3;
    if (index == 3) return 2;
    if (index == 2) return 0; // Default back to Home if they try to access notification tab
    return index;
  }

  void setTabIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myEmail = auth.userProfile['email'] ?? 'guest';
    final isManager = myEmail == 'admin@chrono.com';
    final chatProvider = context.watch<ChatProvider>();

    if (chatProvider.requestedCustomerTab != null) {
      final targetTab = chatProvider.requestedCustomerTab!;
      chatProvider.clearRequestedCustomerTab();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _index = targetTab;
        });
      });
    }

    if (myEmail != 'guest' && myEmail.isNotEmpty && chatProvider.currentUserEmail != myEmail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatProvider.setCurrentUserEmail(myEmail);
      });
    }

    final managerPages = const [
      ChatScreen(),
      AdminOrderListScreen(),
      AdminProductListScreen(),
    ];

    final managerTitles = const [
      'TIN NHẮN KHÁCH HÀNG',
      'QUẢN LÝ ĐƠN HÀNG',
      'QUẢN LÝ SẢN PHẨM',
    ];

    if (isManager) {
      final activeIndex = _index >= managerPages.length ? 0 : _index;
      return Scaffold(
        appBar: AppBar(
          title: Text(managerTitles[activeIndex]),
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: AppStrings.logout,
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                context.go(AppRoutes.login);
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: managerPages[activeIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: activeIndex,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            NavigationDestination(
              icon: chatProvider.unreadChatsForManager.isNotEmpty
                  ? const Badge(
                      child: Icon(Icons.chat_bubble_outline),
                    )
                  : const Icon(Icons.chat_bubble_outline),
              selectedIcon: chatProvider.unreadChatsForManager.isNotEmpty
                  ? const Badge(
                      child: Icon(Icons.chat_bubble, color: AppColors.primary),
                    )
                  : const Icon(Icons.chat_bubble, color: AppColors.primary),
              label: 'Tin nhắn',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
              label: 'Đơn hàng',
            ),
            const NavigationDestination(
              icon: Icon(Icons.watch_outlined),
              selectedIcon: Icon(Icons.watch, color: AppColors.primary),
              label: 'Sản phẩm',
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    
    final cart = context.watch<CartProvider>();
    final notification = context.watch<NotificationProvider>();
    
    final unreadCount = notification.notifications.where((n) => !n.isRead).length;

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
            icon: notifyIcon,
            onPressed: () {
              context.push(AppRoutes.notification);
            },
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
                  backgroundImage: auth.userProfile['avatarUrl'] != null && auth.userProfile['avatarUrl']!.isNotEmpty
                      ? NetworkImage(auth.userProfile['avatarUrl']!)
                      : null,
                  child: auth.userProfile['avatarUrl'] == null || auth.userProfile['avatarUrl']!.isEmpty
                      ? Text(
                          auth.userProfile['name']?.substring(0, 1).toUpperCase() ?? 'K',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
                accountName: Row(
                  children: [
                    Text(
                      auth.userProfile['name'] ?? AppStrings.customer,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        context.push(AppRoutes.editProfile);
                      },
                      child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                    ),
                  ],
                ),
                accountEmail: Text(
                  auth.userProfile['email'] ?? AppStrings.notLoggedIn,
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 13),
                ),
              ),
              if (auth.userProfile['phone'] != null && auth.userProfile['phone']!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  title: const Text(AppStrings.phoneLabel, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(auth.userProfile['phone']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
              if (auth.userProfile['address'] != null && auth.userProfile['address']!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  title: const Text(AppStrings.addressLabel, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(
                    auth.userProfile['address']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                title: const Text(AppStrings.orderHistoryTitle, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.orderHistory);
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(AppStrings.logout, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await auth.logout();
                  if (!context.mounted) return;
                  context.go(AppRoutes.login);
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
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) {
                    setState(() => _index = value);
                    if (value == 3) {
                      context.read<ChatProvider>().markCustomerChatAsRead();
                    }
                  },
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
                    const NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map, color: AppColors.primary),
                      label: Text('Địa chỉ', style: TextStyle(fontSize: 11)),
                    ),
                    NavigationRailDestination(
                      icon: chatProvider.hasUnreadCustomerChat
                          ? const Badge(
                              child: Icon(Icons.chat_bubble_outline),
                            )
                          : const Icon(Icons.chat_bubble_outline),
                      selectedIcon: chatProvider.hasUnreadCustomerChat
                          ? const Badge(
                              child: Icon(Icons.chat_bubble, color: AppColors.primary),
                            )
                          : const Icon(Icons.chat_bubble, color: AppColors.primary),
                      label: const Text('Hỗ trợ', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
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
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) {
                setState(() => _index = value);
                if (value == 3) {
                  context.read<ChatProvider>().markCustomerChatAsRead();
                }
              },
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
                const NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map, color: AppColors.primary),
                  label: 'Cửa hàng',
                ),
                NavigationDestination(
                  icon: chatProvider.hasUnreadCustomerChat
                      ? const Badge(
                          child: Icon(Icons.chat_bubble_outline),
                        )
                      : const Icon(Icons.chat_bubble_outline),
                  selectedIcon: chatProvider.hasUnreadCustomerChat
                      ? const Badge(
                          child: Icon(Icons.chat_bubble, color: AppColors.primary),
                        )
                      : const Icon(Icons.chat_bubble, color: AppColors.primary),
                  label: 'Hỗ trợ',
                ),
              ],
            ),
    );
  }
}
