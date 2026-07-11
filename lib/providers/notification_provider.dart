import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> notifications = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  void listenToNotifications() {
    _subscription?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      notifications = [];
      notifyListeners();
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        seedDefaultNotifications(user.uid);
        return;
      }

      final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
          snapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>());
      docs.sort((a, b) {
        final aTime = a.data()['createdAt'] as Timestamp?;
        final bTime = b.data()['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      notifications = docs.map((doc) {
        final data = doc.data();
        DateTime dt = DateTime.now();
        if (data['createdAt'] != null) {
          if (data['createdAt'] is Timestamp) {
            dt = (data['createdAt'] as Timestamp).toDate();
          } else {
            dt = DateTime.parse(data['createdAt'].toString());
          }
        }
        
        final diff = DateTime.now().difference(dt);
        String timeAgo = 'Vừa xong';
        if (diff.inDays > 0) {
          timeAgo = '${diff.inDays} ngày trước';
        } else if (diff.inHours > 0) {
          timeAgo = '${diff.inHours} giờ trước';
        } else if (diff.inMinutes > 0) {
          timeAgo = '${diff.inMinutes} phút trước';
        }

        return AppNotification(
          id: doc.id,
          title: data['title'] as String? ?? '',
          body: data['body'] as String? ?? '',
          timeAgo: timeAgo,
          isRead: data['isRead'] as bool? ?? false,
          type: data['type'] as String? ?? 'promotion',
          relatedId: data['relatedId'],
        );
      }).toList();

      notifyListeners();
    });
  }

  Future<void> seedDefaultNotifications(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    
    final notificationsToSeed = [
      {
        'userId': userId,
        'title': '🔥 Siêu Ưu Đãi Hè - Chrono Luxury',
        'body': 'Giảm giá lên đến 20% cho các dòng Casio và Citizen chính hãng. Mua ngay kẻo lỡ!',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        'type': 'promotion',
        'isRead': false,
      },
      {
        'userId': userId,
        'title': '✨ BST Rolex Submariner Mới',
        'body': 'Rolex Submariner màu xanh lục cực hiếm đã cập bến cửa hàng 123 Nguyễn Văn Linh, Quận 7. Nhấp để xem chi tiết!',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'type': 'new_product',
        'relatedId': 1,
        'isRead': false,
      },
      {
        'userId': userId,
        'title': '📢 Tìm vị trí Showroom Chrono Luxury',
        'body': 'Tìm vị trí showroom tại 123 Nguyễn Văn Linh, Quận 7 trên bản đồ để nhận chỉ đường chi tiết.',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
        'type': 'store',
        'isRead': false,
      }
    ];

    for (final notif in notificationsToSeed) {
      final ref = firestore.collection('notifications').doc();
      batch.set(ref, notif);
    }
    await batch.commit();
  }

  void markAsRead(String id) {
    FirebaseFirestore.instance.collection('notifications').doc(id).update({
      'isRead': true,
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
