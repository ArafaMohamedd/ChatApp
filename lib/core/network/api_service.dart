/*import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:chatnew/core/network/api_constants.dart';
import 'package:chatnew/models/social_app/message_model.dart';
import 'package:chatnew/models/social_app/social_user_model.dart';

class ApiService {
  final http.Client _client = http.Client();
  
  // Helper method for GET requests
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make GET request: $e');
    }
  }

  // Helper method for POST requests
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
        },
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make POST request: $e');
    }
  }

  // Helper method for file uploads
  Future<String> uploadFile(String endpoint, File file, String fileType) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          fileType, // 'image' or 'voice'
          file.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse['url']; // Assuming the API returns a URL
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  // Get messages between two users
  Future<List<MessageModel>> getMessages(String receiverId) async {
    final response = await get('${ApiConstants.messages}?receiverId=$receiverId');
    return (response['messages'] as List)
        .map((json) => MessageModel.fromjson(json))
        .toList();
  }

  // Send a message
  Future<void> sendMessage(MessageModel message) async {
    await post(ApiConstants.messages, message.toMap());
  }

  // Upload image
  Future<String> uploadImage(File imageFile) async {
    return await uploadFile(ApiConstants.uploadImage, imageFile, 'image');
  }

  // Upload voice message
  Future<String> uploadVoice(File voiceFile) async {
    return await uploadFile(ApiConstants.uploadVoice, voiceFile, 'voice');
  }

  // Get user profile
  Future<SocialUserModel> getUserProfile(String userId) async {
    final response = await get('${ApiConstants.users}/$userId');
    return SocialUserModel.fromjson(response);
  }
}*/