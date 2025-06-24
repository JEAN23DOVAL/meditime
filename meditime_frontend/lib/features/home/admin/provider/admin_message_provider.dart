import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/services/admin_message_service.dart';

final adminMessagesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await AdminMessageService().fetchAllMessages();
});

// Ajoute ce provider pour le badge
final adminUnreadCountProvider = FutureProvider<int>((ref) async {
  final messages = await AdminMessageService().fetchAllMessages();
  return messages.where((msg) => msg['is_read'] == false).length;
});