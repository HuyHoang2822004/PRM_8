import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/checkout/checkout_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../../screens/order/order_success_screen.dart';
import '../../screens/order/order_history_screen.dart';
import '../../screens/chat/manager_chat_detail_screen.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../screens/admin/admin_order_detail_screen.dart';
import '../../screens/admin/admin_product_edit_screen.dart';
import '../../models/order.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialIndex = tabParam != null ? int.tryParse(tabParam) ?? 0 : 0;
          return CustomTransitionPage(
            key: ValueKey('home_page_$initialIndex'),
            child: MainNavigationScreen(
              key: ValueKey('main_nav_screen_$initialIndex'),
              initialIndex: initialIndex,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CheckoutScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        pageBuilder: (context, state) {
          final product = state.extra as Product;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(product: product),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OrderSuccessScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: CurveTween(curve: Curves.easeOutBack).animate(animation),
              child: FadeTransition(
                opacity: CurveTween(curve: Curves.easeIn).animate(animation),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OrderHistoryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.managerChatDetail,
        pageBuilder: (context, state) {
          final customerEmail = state.extra as String;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ManagerChatDetailScreen(customerEmail: customerEmail),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminOrderDetail,
        pageBuilder: (context, state) {
          final order = state.extra as Order;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminOrderDetailScreen(order: order),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminProductEdit,
        pageBuilder: (context, state) {
          final product = state.extra as Product?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AdminProductEditScreen(product: product),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
    ],
    redirect: (context, state) {
      final loggedIn = context.read<AuthProvider>().isLoggedIn;
      final loggingIn = state.uri.path == AppRoutes.login || state.uri.path == AppRoutes.register;
      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
  );
}
