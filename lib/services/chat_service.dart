import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class ChatService {
  static const _chatKey = 'chrono_chat_messages';

  Future<List<Message>> loadPersistedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_chatKey);
    if (jsonStr == null) return [];
    try {
      final list = json.decode(jsonStr) as List<dynamic>;
      return list.map((m) => Message.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePersistedMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(_chatKey, jsonStr);
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
