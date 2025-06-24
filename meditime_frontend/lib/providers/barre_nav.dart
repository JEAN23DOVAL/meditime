import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/provider/admin_message_provider.dart';
import 'package:meditime_frontend/features/home/user/providers/user_message_provider.dart';

final adminUnreadCountProvider = Provider<int>((ref) {
  final messages = ref.watch(adminMessagesProvider).maybeWhen(
    data: (msgs) => msgs,
    orElse: () => [],
  );
  return messages.where((msg) => msg['is_read'] == false).length;
});

final userUnreadCountProvider = Provider.family<int, String>((ref, type) {
  final messages = ref.watch(userMessagesProvider(type)).maybeWhen(
    data: (msgs) => msgs,
    orElse: () => [],
  );
  return messages.where((msg) => msg['is_read'] == false).length;
});