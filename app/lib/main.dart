import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/firebase_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/apps_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('[JaNee] Starting app...');

  try {
    await FirebaseConfig.initialize();
    print('[JaNee] Firebase initialized');
  } catch (e) {
    print('[JaNee] Firebase initialization error: $e');
  }

  runApp(const JaNeeApp());
}

class JaNeeApp extends StatelessWidget {
  const JaNeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppsProvider()),
      ],
      child: MaterialApp(
        title: 'JaNee',
        debugShowCheckedModeBanner: false,
        theme: JaNeeTheme.lightTheme,
        darkTheme: JaNeeTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: JaNeeTheme.jet,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'JaNee',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: JaNeeTheme.amber,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(JaNeeTheme.amber),
              ),
            ],
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
