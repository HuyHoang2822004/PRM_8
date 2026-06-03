import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

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
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (_, provider, __) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: provider.notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) {
          final item = provider.notifications[index];
          return ListTile(
            tileColor: item.isRead ? null : Colors.blue.shade50,
            title: Text(item.title),
            subtitle: Text('${item.body}\n${item.timeAgo}'),
            onTap: () => provider.markAsRead(item.id),
          );
        },
      ),
    );
  }
}
