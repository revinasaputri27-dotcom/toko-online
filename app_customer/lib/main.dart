import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_exception.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';

void main() {
  runApp(const TokoOnlineApp());
}

class TokoOnlineApp extends StatelessWidget {
  const TokoOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartService>.value(
      value: CartService.instance,
      child: MaterialApp(
        title: 'Toko Online Customer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          scaffoldBackgroundColor: const Color(0xFFF7F7FB),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final auth = AuthService();
    final token = await auth.getToken();
    var isSignedIn = false;
    if (token != null && token.isNotEmpty) {
      try {
        await ApiService().getMe(token: token);
        isSignedIn = true;
      } on ApiException catch (error) {
        if (error.statusCode == 401) {
          await auth.logout();
        } else {
          isSignedIn = true;
        }
      } catch (_) {
        isSignedIn = true;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => isSignedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_rounded, size: 64, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Toko Online',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
