import 'package:flutter_dotenv/flutter_dotenv.dart';

class GemmaService {
  static String? get apiKey => dotenv.env['GEMMA_API_KEY'];
  // Add more getters for other secrets if needed

  // Example function using the key
  static Future<void> doSomethingWithGemma() async {
    final key = apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('Gemma API key not set.');
    }
    // Use the key securely here
  }
}
