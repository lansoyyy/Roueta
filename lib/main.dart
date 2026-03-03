import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const RouetaApp());
}

class RouetaApp extends StatelessWidget {
  const RouetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roueta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to Roueta', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
