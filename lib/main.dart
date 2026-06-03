import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/order_service.dart';
import 'services/product_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())..checkLogin()),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductService())),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider(ChatService())),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context.watch<AuthProvider>());
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Sneaker Shop',
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
