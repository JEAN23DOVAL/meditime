import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/user/messages/widgets/message_detail_page.dart';
import 'package:meditime_frontend/features/home/user/providers/user_message_provider.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart'; // Pour récupérer l'utilisateur courant
import 'package:meditime_frontend/services/user_message_service.dart';

import 'message_tile.dart';

class MessageList extends ConsumerWidget {
  final String filter;
  final String type;
  const MessageList({required this.filter, required this.type, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(userMessagesProvider(type));
    final currentUser = ref.read(authProvider);

    return messagesAsync.when(
      data: (messages) {
        // Applique le filtre (lu/non lu/tous)
        final filtered = messages.where((msg) {
          switch (filter) {
            case 'unread':
              return msg['is_read'] == false;
            case 'read':
              return msg['is_read'] == true;
            default:
              return true;
          }
        }).toList();

        // Regroupe les messages par conversation
        final Map<String, List<Map<String, dynamic>>> conversations = {};
        for (var msg in filtered) {
          final senderId = msg['sender_id'];
          final receiverId = msg['receiver_id'];
          final otherUserId = senderId == currentUser?.idUser ? receiverId : senderId;
          final convKey = otherUserId.toString(); // 1 conversation par autre utilisateur

          conversations.putIfAbsent(convKey, () => []);
          conversations[convKey]!.add(msg);
        }

        if (conversations.isEmpty) {
          return const Center(child: Text('Aucun message'));
        }

        // Affiche une seule tuile par conversation (le dernier message)
        final convList = conversations.values.map((msgs) {
          msgs.sort((a, b) => b['created_at'].compareTo(a['created_at']));
          return msgs.first;
        }).toList();

        convList.sort((a, b) => b['created_at'].compareTo(a['created_at']));

        return ListView.separated(
          itemCount: convList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final msg = convList[index];
            final otherUser = msg['sender_id'] == currentUser?.idUser ? msg['receiver'] : msg['sender'];
            final receiverId = otherUser?['idUser'];

            return MessageTile(
              msg: msg,
              onTap: () async {
                if (msg['is_read'] == false) {
                  await UserMessageService().markAsRead(msg['id']);
                }
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MessageDetailPage(
                      senderName: otherUser != null
                          ? (otherUser['role'] == 'admin'
                              ? 'Administrateur (${otherUser['lastName'] ?? ''} ${otherUser['firstName'] ?? ''})'
                              : '${otherUser['lastName'] ?? ''} ${otherUser['firstName'] ?? ''}')
                          : 'Administrateur',
                      messageContent: msg['content'] ?? '',
                      time: msg['created_at']?.toString().substring(11, 16) ?? '',
                      receiverId: receiverId,
                    ),
                  ),
                );
                ref.invalidate(userMessagesProvider(type));
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}