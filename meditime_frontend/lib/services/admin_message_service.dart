import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/core/network/dio_client.dart';

class AdminMessageService {
  final _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> fetchAllMessages() async {
    final response = await _dio.get(ApiConstants.adminAllMessages);
    if (response.statusCode == 200 && response.data != null) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    throw Exception('Erreur lors de la récupération des messages');
  }

  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String content,
    String? subject,
    String? type,
  }) async {
    final response = await _dio.post(
      '/messages/send',
      data: {
        'receiver_id': receiverId,
        'content': content,
        if (subject != null) 'subject': subject,
        if (type != null) 'type': type,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    }
    throw Exception('Erreur lors de l\'envoi du message');
  }

  Future<List<Map<String, dynamic>>> fetchConversation(int userId) async {
    final response = await _dio.get('/messages/conversation/$userId');
    if (response.statusCode == 200 && response.data != null) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    throw Exception('Erreur lors de la récupération de la conversation');
  }
}