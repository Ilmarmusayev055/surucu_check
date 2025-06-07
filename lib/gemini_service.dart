import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyDcAh6c_UE2d2a-e1YvhBNf5QCsziTIoMM'; // 🔒 Sənin Gemini API açarın

  Future<String> getGeminiResponse(String userMessage) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': userMessage}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final reply = decoded['candidates'][0]['content']['parts'][0]['text'];
      return reply;
    } else {
      print('Gemini XƏTASI: ${response.body}');
      return 'AI cavab verə bilmədi.';
    }
  }
}
