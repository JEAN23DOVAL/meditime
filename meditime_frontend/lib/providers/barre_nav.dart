import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/providers/user_message_provider.dart';

final userUnreadCountProvider = Provider.family<int, String>((ref, type) {
  final messages = ref.watch(userMessagesProvider(type)).maybeWhen(
    data: (msgs) => msgs,
    orElse: () => [],
  );
  return messages.where((msg) => msg['is_read'] == false).length;
});