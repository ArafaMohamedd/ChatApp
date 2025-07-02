import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


const apiKey = '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';
const baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
const model = 'mistralai/mistral-7b-instruct';

Future<String> askChatbot(List<Map<String, String>> messages) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://yourdomain.com', // Optional
        'X-Title': 'Test ChatBot' // Optional
      },
      body: jsonEncode({
        'model': model,
        'messages': messages
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return '❌ Error: ${response.statusCode} - ${response.body}';
    }
  } catch (e) {
    return '❌ Error: $e';
  }
}

void main() async {
  print('🤖 ChatBot (OpenRouter): type "exit" to quit');
  while (true) {
    stdout.write('👤 You: ');
    final userInput = stdin.readLineSync();
    if (userInput == null || userInput.toLowerCase() == 'exit') break;
    final reply = await askChatbot([{'role': 'user', 'content': userInput}]);
    print('🤖 Bot: $reply');
  }
}