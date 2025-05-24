import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/user_message_service.dart';

final userMessagesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, type) async {
  // type = 'doctor' ou 'admin'
  return await UserMessageService().fetchMessages(type: type);
});