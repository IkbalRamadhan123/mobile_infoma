import 'package:flutter/material.dart';
import 'dart:async';
import 'utils/app_theme.dart';
import 'services/auth_service.dart';
import 'utils/sample_data.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Main: Initialized WidgetsFlutterBinding');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<bool> _initialize() async {
    try {
      print('MyApp: Seeding sample data (if needed)');
      await SampleData.seedAll();

      print('MyApp: Initializing AuthService');
      final authService = AuthService();
      print('MyApp: Calling authService.init()');

      // Add timeout to prevent hanging
      await authService.init().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('MyApp: AuthService.init() timed out');
          throw TimeoutException('AuthService initialization timeout');
        },
      );

      print('MyApp: AuthService initialized successfully');
      return true;
    } catch (e) {
      print('MyApp: Error initializing auth: $e');
      print('MyApp: Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AssessMent 2 PPBL',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.data!) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error initializing app'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _initFuture = _initialize();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final authService = AuthService();
          return authService.isLoggedIn
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
