import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class SocketService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  final _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messageStream => _messageController.stream;

  bool get isConnected => _isConnected;

  // Stream for notifications
  final _notificationController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get notificationStream => _notificationController.stream;

  void initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    // Fallback if token is null, we can't properly auth the socket
    if (token == null) return;

    _socket = IO.io(AppConstants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint("[SOCKET] Connected to Backend");
      notifyListeners();

      // We could also send a 'join' event here if needed,
      // but the backend can also identify by token if implemented.
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint("[SOCKET] Disconnected");
      notifyListeners();
    });

    // Listen for general notifications
    _socket!.on("notification", (data) {
<<<<<<< HEAD
      print("[SOCKET] New Notification: $data");
      _messageController.add(data);
      notifyListeners();
=======
      debugPrint("[SOCKET] New Notification: $data");
      _notificationController.add(data);
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    _notificationController.close();
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}
