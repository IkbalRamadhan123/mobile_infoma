import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../mahasiswa/mahasiswa_home.dart';
import '../penyedia/penyedia_home.dart';
import '../admin/admin_home.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userType;
  late int userId;

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    userType = authService.userType;
    userId = authService.userId;

    if (userType.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Route to appropriate home screen based on user type
    if (userType == 'mahasiswa') {
      return const MahasiswaHome();
    } else if (userType == 'penyedia') {
      return const PenyediaHome();
    } else if (userType == 'admin') {
      return const AdminHome();
    } else {
      return Scaffold(
        body: Center(child: Text('User type not recognized: $userType')),
      );
    }
  }
}
