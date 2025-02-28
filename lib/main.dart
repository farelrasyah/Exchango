import 'package:flutter/material.dart';
import 'core/theme/Theme.dart';
import 'features/screens/converterScreen.dart';
import 'features/widgets/SplashScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exchango',
      theme: AppTheme.lightTheme,
      home:
          const SplashScreen(), // Changed from ConverterScreen to SplashScreen
      routes: {
        '/home': (context) => const ConverterScreen(),
      },
    );
  }
}
