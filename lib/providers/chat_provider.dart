import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../../main.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._chatService);

  final ChatService _chatService;
  final List<Message> _allMessages = [];
  StreamSubscription<List<Message>>? _streamSubscription;
  bool isChatOpen = false;
  String? activeChatEmail;
  String? _currentUserEmail;
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  bool hasUnreadCustomerChat = false;
  final Set<String> unreadChatsForManager = {};

  int? requestedCustomerTab;

  void requestTab(int tabIndex) {
    requestedCustomerTab = tabIndex;
    notifyListeners();
  }

  void clearRequestedCustomerTab() {
    requestedCustomerTab = null;
  }

  void startListeningToNotifications(String uid) {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('type', isEqualTo: 'chat')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (_currentUserEmail == 'admin@chrono.com') {
        unreadChatsForManager.clear();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data['relatedId'] != null) {
            unreadChatsForManager.add(data['relatedId'].toString());
          }
        }
      } else {
        hasUnreadCustomerChat = snapshot.docs.isNotEmpty;
      }
      notifyListeners();
    });
  }

  Future<void> markCustomerChatAsRead() async {
    hasUnreadCustomerChat = false;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .where('type', isEqualTo: 'chat')
            .where('isRead', isEqualTo: false)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('DEBUG: [ChatProvider] Lỗi khi đánh dấu đã đọc thông báo: $e');
    }
  }

  Future<void> markManagerChatAsRead(String customerEmail) async {
    unreadChatsForManager.remove(customerEmail);
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .where('type', isEqualTo: 'chat')
            .where('relatedId', isEqualTo: customerEmail)
            .where('isRead', isEqualTo: false)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('DEBUG: [ChatProvider] Lỗi khi đánh dấu đã đọc thông báo manager: $e');
    }
  }

  String? get currentUserEmail => _currentUserEmail;

  List<Message> get allMessages => List.unmodifiable(_allMessages);

  void setCurrentUserEmail(String email) {
    if (_currentUserEmail != email) {
      _currentUserEmail = email;
      _streamSubscription?.cancel();
      _streamSubscription = null;
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        startListeningToNotifications(user.uid);
      } else {
        FirebaseAuth.instance.authStateChanges().first.then((user) {
          if (user != null && _currentUserEmail == email) {
            startListeningToNotifications(user.uid);
          }
        });
      }
      
      startListeningToMessages();
    }
  }

  Future<void> loadAllMessages() async {
    startListeningToMessages();
  }

  void startListeningToMessages() {
    if (_streamSubscription != null) return;
    _streamSubscription = _chatService.getMessagesStream().listen((messagesList) async {
      debugPrint('DEBUG: [ChatProvider] Nhận được danh sách ${messagesList.length} tin nhắn từ Firestore.');
      
      // Handle notifications for new messages
      if (_allMessages.isNotEmpty) {
        final oldMessageIds = _allMessages.map((m) => m.id).toSet();
        for (final msg in messagesList) {
          if (!oldMessageIds.contains(msg.id)) {
            debugPrint('DEBUG: [ChatProvider] Có tin nhắn mới: ID=${msg.id}, Sender=${msg.senderEmail}, Receiver=${msg.receiverEmail}, Content=${msg.content}');
            try {
              _notifyNewMessage(msg);
            } catch (e) {
              debugPrint('DEBUG: [ChatProvider] Lỗi khi thông báo tin nhắn: $e');
            }
          }
        }
      }

      _allMessages.clear();
      _allMessages.addAll(messagesList);
      
      // Seed message if empty for demo purposes
      if (_allMessages.isEmpty) {
        final seed1 = Message(
          id: 'msg_seed_1',
          senderEmail: 'khachhang@test.com',
          receiverEmail: 'admin@chrono.com',
          content: 'Xin chào shop! Shop có mẫu Rolex Submariner còn hàng không ạ?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isFromUser: true,
        );
        final seed2 = Message(
          id: 'msg_seed_2',
          senderEmail: 'admin@chrono.com',
          receiverEmail: 'khachhang@test.com',
          content: 'Dạ chào bạn, mẫu Rolex Submariner hiện đang còn hàng sẵn tại showroom 123 Nguyễn Văn Linh ạ.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
          isFromUser: false,
        );
        await _chatService.sendMessage(seed1);
        await _chatService.sendMessage(seed2);
      }
      
      notifyListeners();
    });
  }

  void _notifyNewMessage(Message msg) {
    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) return;

    final lowerRec = msg.receiverEmail.toLowerCase().trim();
    final lowerSend = msg.senderEmail.toLowerCase().trim();
    final lowerCurrent = _currentUserEmail!.toLowerCase().trim();

    final isForMe = lowerRec == lowerCurrent;
    final isFromMe = lowerSend == lowerCurrent;

    if (isForMe && !isFromMe) {
      final isCurrentlyChatting = activeChatEmail != null &&
          activeChatEmail!.toLowerCase().trim() == msg.senderEmail.toLowerCase().trim();

      if (!isCurrentlyChatting) {
        // 1. Mark as unread
        if (_currentUserEmail == 'admin@chrono.com') {
          unreadChatsForManager.add(msg.senderEmail);
        } else {
          hasUnreadCustomerChat = true;
        }
        notifyListeners();

        // 2. Show in-app top overlay notification
        final senderName = msg.senderEmail == 'admin@chrono.com' ? 'Chrono Luxury' : msg.senderEmail;
        _showTopNotification(senderName, msg.content);
      }
    }
  }

  void _showTopNotification(String senderName, String messageContent) {
    try {
      final context = scaffoldMessengerKey.currentContext;
      if (context == null) return;

      final overlay = Overlay.of(context);
      if (overlay == null) {
        debugPrint('DEBUG: [ChatProvider] Không tìm thấy Overlay trong context hiện tại.');
        return;
      }

      late OverlayEntry overlayEntry;
      overlayEntry = OverlayEntry(
        builder: (overlayContext) {
          return Positioned(
            top: MediaQuery.of(overlayContext).padding.top + 12,
            right: 16,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: Dismissible(
                key: UniqueKey(),
                onDismissed: (_) {
                  overlayEntry.remove();
                },
                child: GestureDetector(
                  onTap: () {
                    overlayEntry.remove();
                    _navigateToChat();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tin nhắn mới từ $senderName',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                messageContent,
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(overlayEntry);

      // Auto dismiss after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    } catch (e) {
      debugPrint('DEBUG: [ChatProvider] Lỗi hiển thị Top Notification Overlay: $e');
    }
  }

  void _navigateToChat() {
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) return;
    final isManager = _currentUserEmail == 'admin@chrono.com';
    if (isManager) {
      context.go('${AppRoutes.home}?tab=0');
    } else {
      context.go('${AppRoutes.home}?tab=4');
    }
  }

  List<Message> getConversation(String customerEmail) {
    final lowerCustomer = customerEmail.toLowerCase().trim();
    
    // Deduplicate messages by ID to prevent duplicated messages
    final Map<String, Message> uniqueMap = {};
    
    for (final m in _allMessages) {
      final lowerSender = m.senderEmail.toLowerCase().trim();
      final lowerReceiver = m.receiverEmail.toLowerCase().trim();
      final isCustomerSender = lowerSender == lowerCustomer && lowerReceiver == 'admin@chrono.com';
      final isCustomerReceiver = lowerSender == 'admin@chrono.com' && lowerReceiver == lowerCustomer;
      if (isCustomerSender || isCustomerReceiver) {
        uniqueMap[m.id] = m;
      }
    }
    
    final res = uniqueMap.values.toList();
    
    // Sort by timestamp ascending to ensure order is correct
    res.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    debugPrint('DEBUG: [ChatProvider] getConversation($customerEmail) tìm thấy ${res.length} tin nhắn (Tổng: ${_allMessages.length})');
    return res;
  }

  List<String> getActiveChats() {
    final Set<String> emails = {};
    for (final m in _allMessages) {
      final lowerSender = m.senderEmail.toLowerCase().trim();
      final lowerReceiver = m.receiverEmail.toLowerCase().trim();
      if (lowerSender != 'admin@chrono.com' && lowerSender.isNotEmpty) {
        emails.add(lowerSender);
      }
      if (lowerReceiver != 'admin@chrono.com' && lowerReceiver.isNotEmpty) {
        emails.add(lowerReceiver);
      }
    }
    
    // Sort customer emails by their latest message timestamp
    final List<String> sortedEmails = emails.toList();
    sortedEmails.sort((a, b) {
      final latestA = _latestMessageTime(a);
      final latestB = _latestMessageTime(b);
      return latestB.compareTo(latestA);
    });
    return sortedEmails;
  }

  DateTime _latestMessageTime(String email) {
    final conv = getConversation(email);
    if (conv.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    return conv.last.timestamp;
  }

  Future<void> sendMessageFromCustomer(String customerEmail, String content) async {
    if (content.trim().isEmpty) return;
    
    final newMsg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderEmail: customerEmail,
      receiverEmail: 'admin@chrono.com',
      content: content.trim(),
      timestamp: DateTime.now(),
      isFromUser: true,
    );

    await _chatService.sendMessage(newMsg);

    // Create notification for manager
    try {
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: 'admin@chrono.com')
          .limit(1)
          .get();
      if (adminSnapshot.docs.isNotEmpty) {
        final adminUid = adminSnapshot.docs.first.id;
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': adminUid,
          'title': '💬 Tin nhắn mới từ khách hàng ($customerEmail)',
          'body': content.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'chat',
          'isRead': false,
          'relatedId': customerEmail,
        });
      }
    } catch (e) {
      debugPrint('DEBUG: [ChatProvider] Lỗi khi tạo thông báo cho manager: $e');
    }
  }

  Future<void> sendMessageFromManager(String customerEmail, String content) async {
    if (content.trim().isEmpty) return;

    final newMsg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderEmail: 'admin@chrono.com',
      receiverEmail: customerEmail,
      content: content.trim(),
      timestamp: DateTime.now(),
      isFromUser: false,
    );

    await _chatService.sendMessage(newMsg);

    // Create notification for customer
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: customerEmail)
          .limit(1)
          .get();
      if (userSnapshot.docs.isNotEmpty) {
        final userUid = userSnapshot.docs.first.id;
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': userUid,
          'title': '💬 Tin nhắn mới từ Chrono Luxury',
          'body': content.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'chat',
          'isRead': false,
          'relatedId': 'chat',
        });
      }
    } catch (e) {
      debugPrint('DEBUG: [ChatProvider] Lỗi khi tạo thông báo cho customer: $e');
    }
  }

  // Deprecated methods mapping to prevent breaks
  void loadMessages() {
    loadAllMessages();
  }

  List<Message> get messages {
    return _allMessages.where((m) => m.senderEmail == 'guest' || m.receiverEmail == 'guest').toList();
  }

  Future<void> sendMessage(String text) async {
    await sendMessageFromCustomer('guest', text);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
