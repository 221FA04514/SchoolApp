import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class SocketService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

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
      print("[SOCKET] Connected to Backend");
      notifyListeners();

      // We could also send a 'join' event here if needed,
      // but the backend can also identify by token if implemented.
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print("[SOCKET] Disconnected");
      notifyListeners();
    });

    // Listen for general notifications
    _socket!.on("notification", (data) {
      print("[SOCKET] New Notification: $data");
      // Handle showing a global snackbar or updating a notification count
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}
