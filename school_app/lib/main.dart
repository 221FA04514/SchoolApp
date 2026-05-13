import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'screens/auth/login_selection_screen.dart';
import 'core/socket/socket_service.dart';

import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations and system UI mode for responsiveness
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final socketService = SocketService();

  // Try to init socket on startup (if token exists)
  socketService.initSocket();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => socketService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School App',
      debugShowCheckedModeBanner: false,
      home: const LoginSelectionScreen(),
    );
  }
}
