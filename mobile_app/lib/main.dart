import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(const ChiliDoctorApp());

class ChiliDoctorApp extends StatelessWidget {
  const ChiliDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chili Leaf Doctor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AuthGate(),
    );
  }
}

/// Decides which screen to show when the app starts:
/// - a saved session token  -> Home
/// - no token (logged out)  -> Login
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool? _loggedIn;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await ApiService.isLoggedIn();
    if (mounted) setState(() => _loggedIn = loggedIn);
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      return const Scaffold(
        backgroundColor: AppColors.mintBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      );
    }
    return _loggedIn! ? const HomeScreen() : const LoginScreen();
  }
}