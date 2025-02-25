import 'package:flutter/material.dart';
import 'core/theme/Theme.dart';
import 'features/screens/converterScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchango',
      theme: AppTheme.lightTheme,
      home: const ConverterScreen(),
    );
  }
}
