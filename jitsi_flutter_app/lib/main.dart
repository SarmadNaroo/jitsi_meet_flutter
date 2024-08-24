import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jitsi_flutter_app/providers/auth_provider.dart';
import 'package:jitsi_flutter_app/providers/jitsi_provider.dart'; // Import JitsiProvider
import 'package:jitsi_flutter_app/screens/login_screen.dart';
import 'package:jitsi_flutter_app/screens/user_list_screen.dart';
import 'package:jitsi_flutter_app/screens/call_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<JitsiProvider>(create: (_) => JitsiProvider()), // Explicitly specify the type
        // Add other providers here if needed
      ],
      child: MaterialApp(
        title: 'Jitsi Flutter App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/user-list': (context) => UserListScreen(),
          '/call': (context) => CallScreen(),
        },
      ),
    );
  }
}
