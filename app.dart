import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/request_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

class HRPerfectApp extends StatelessWidget {
  const HRPerfectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RequestProvider>(
          create: (_) => RequestProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HR Perfect',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
