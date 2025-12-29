import 'package:flutter/material.dart';
// import 'services/gemma_service.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // try {
  //   await GemmaService.ensureInitialized();
  // } catch (e) {
  //   debugPrint('Gemma initialization failed: $e');
  // }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Financier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
