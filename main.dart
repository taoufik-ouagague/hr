import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';  // Your LoginScreen
import 'providers/auth_provider.dart';  // Your AuthProvider
import 'providers/request_provider.dart'; // Your RequestProvider
import 'screens/employee/employee_home.dart';  // Employee home screen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => RequestProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Perfect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Dynamically show LoginScreen or EmployeeHome depending on authentication state
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            // If authenticated, navigate to EmployeeHome screen
            return const EmployeeHome(key: Key('employeeHome'), userId: 'user@example.com'); // Example userId with key
          } else {
            // If not authenticated, show LoginScreen
            return const LoginScreen(key: Key('loginScreen')); // Adding key to LoginScreen
          }
        },
      ),
      routes: {
        '/home': (context) => const EmployeeHome(key: Key('employeeHome'), userId: 'user@example.com'),
      },
    );
  }
}
