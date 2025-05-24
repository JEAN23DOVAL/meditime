import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/admin_message_service.dart';

final adminMessagesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await AdminMessageService().fetchAllMessages();
});