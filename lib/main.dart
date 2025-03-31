import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/blog_detail_screen.dart';
import 'screens/create_blog_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_blogs_screen.dart';
import 'models/blog_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseInitialized = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => SplashScreen(
                firebaseInitialized: firebaseInitialized,
                isConnected: firebaseInitialized,
                isLoggedIn: false,
              ),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => HomeScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          case '/create-blog':
            return MaterialPageRoute(
              builder: (context) => const CreateBlogScreen(),
            );
          case '/myBlogs':
            return MaterialPageRoute(
              builder: (context) => const MyBlogsScreen(),
            );
          case '/blog-detail':
            final blog = settings.arguments as Blog;
            return MaterialPageRoute(
              builder: (context) => BlogDetailScreen(blog: blog),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}
