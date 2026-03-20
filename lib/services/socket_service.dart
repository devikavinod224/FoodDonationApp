import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  static const String wsUrl = 'wss://fooddonationbackend.onrender.com/ws';
  WebSocketChannel? _channel;

  void connect(String userId) {
    if (_channel != null) return;
    
    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl?userId=$userId'),
    );
    print('WebSocket connected for user: $userId');
  }

  Stream? get stream => _channel?.stream;

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    print('WebSocket disconnected');
  }

  void onEvent(Function(String event, dynamic data) callback) {
    stream?.listen((message) {
      try {
        final decoded = jsonDecode(message);
        callback(decoded['event'], decoded['data']);
      } catch (e) {
        print('WebSocket Error Decoding: $e');
      }
    });
  }
}
