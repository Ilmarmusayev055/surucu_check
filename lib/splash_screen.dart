import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1D2C2F), // Tünd yaşıl/boz rəng
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo1.gif,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            Text(
              'SürücüCheck',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                fontFamaily: 'GaboDrive',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
