import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truckmate_admin_access/screens/history_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/drivers_screen.dart';
import 'screens/owners_screen.dart';
import 'screens/verification_screen.dart'; // ✅ NEW: Add verification screen import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Admin Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF6C5CE7), // Added primary color
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Set initial route
        initialRoute: '/',
        // Define all routes including login
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/drivers': (context) => const DriversScreen(),
          '/owners': (context) => const OwnersScreen(),
          '/verification': (context) => const VerificationScreen(), // ✅ NEW: Add verification route
          '/history': (context) => const HistoryScreen(),

        },
        // Handle unknown routes - redirect to login
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}

// Auth wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading spinner while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
              ),
            ),
          );
        }
        
        // Check authentication status
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}