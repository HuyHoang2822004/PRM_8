import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore}) : _firestoreInstance = firestore;

  final FirebaseFirestore? _firestoreInstance;
  FirebaseFirestore get _firestore => _firestoreInstance ?? FirebaseFirestore.instance;

  // Stream of all messages ordered by timestamp ascending
  Stream<List<Message>> getMessagesStream() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        DateTime dt = DateTime.now();
        if (data['timestamp'] != null) {
          if (data['timestamp'] is Timestamp) {
            dt = (data['timestamp'] as Timestamp).toDate();
          } else {
            dt = DateTime.parse(data['timestamp'].toString());
          }
        }

        return Message(
          id: data['id'] as String? ?? doc.id,
          senderEmail: data['senderEmail'] as String? ?? '',
          receiverEmail: data['receiverEmail'] as String? ?? '',
          content: data['content'] as String? ?? '',
          timestamp: dt,
          isFromUser: data['isFromUser'] as bool? ?? true,
        );
      }).toList();
    });
  }

  // Save single message to Firestore
  Future<void> sendMessage(Message message) async {
    try {
      await _firestore.collection('messages').doc(message.id).set({
        'id': message.id,
        'senderEmail': message.senderEmail,
        'receiverEmail': message.receiverEmail,
        'content': message.content,
        'timestamp': Timestamp.fromDate(message.timestamp),
        'isFromUser': message.isFromUser,
      });
    } catch (e) {
      print('DEBUG: Lỗi gửi tin nhắn lên Firestore: $e');
      rethrow;
    }
  }

  Future<String> autoReply(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final msg = userMessage.toLowerCase();
    if (msg.contains('bảo hành') || msg.contains('bao hanh')) {
      return 'Dạ, tất cả đồng hồ tại Chrono Luxury được bảo hành chính hãng từ 1 đến 5 năm (tùy dòng sản phẩm) kèm gói thay pin miễn phí trọn đời tại hệ thống cửa hàng ạ.';
    }
    if (msg.contains('giá') || msg.contains('gia') || msg.contains('bao nhiêu') || msg.contains('bao nhieu')) {
      return 'Dạ, giá sản phẩm được niêm yết chính xác trên ứng dụng. Đặc biệt hiện tại đang có chương trình giảm giá cực tốt cho một số mẫu HOT, bạn xem qua nhé!';
    }
    if (msg.contains('còn hàng') || msg.contains('con hang') || msg.contains('có sẵn') || msg.contains('co san')) {
      return 'Dạ, các sản phẩm hiển thị "Còn hàng" đều đang có sẵn tại cửa hàng 123 Nguyễn Văn Linh, Quận 7. Bạn có thể đặt trực tiếp trên app để giữ hàng ạ.';
    }
    if (msg.contains('ship') || msg.contains('giao hàng') || msg.contains('giao hang') || msg.contains('vận chuyển')) {
      return 'Dạ, shop có ship COD toàn quốc. Miễn phí vận chuyển cho đơn hàng giá trị cao. Thời gian giao hàng chỉ từ 2-4 ngày thôi ạ.';
    }
    return 'Chào bạn! Cảm ơn bạn đã liên hệ Chrono Luxury. Bạn cần tư vấn thêm về mẫu đồng hồ nào hay chính sách bảo hành/giao hàng của shop ạ?';
  }
}
