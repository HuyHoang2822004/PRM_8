class ChatService {
  Future<String> autoReply() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Shop: Product is available.';
  }
}
