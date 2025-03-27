import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool firebaseInitialized;
  final bool isConnected;
  final bool isLoggedIn;

  const SplashScreen({
    super.key,
    required this.firebaseInitialized,
    required this.isConnected,
    required this.isLoggedIn,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!widget.firebaseInitialized || !widget.isConnected) {
        // Show error if Firebase is not initialized
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Firebase is not connected. Please check your setup."),
          ),
        );
      } else {
        // Navigate based on login state
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                widget.isLoggedIn ? HomeScreen() : LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              widget.firebaseInitialized
                  ? (widget.isConnected
                  ? "✅ Connected to Firebase..."
                  : "❌ Not connected to Firebase...")
                  : "🔄 Initializing Firebase...",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
 
