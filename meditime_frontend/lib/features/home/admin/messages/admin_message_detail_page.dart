import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/core/network/socket_service.dart';
import 'package:meditime_frontend/features/home/admin/provider/admin_message_provider.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/services/admin_message_service.dart';
import 'package:meditime_frontend/providers/socket_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meditime_frontend/services/notification_service.dart';

class AdminMessageDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> message;
  const AdminMessageDetailPage({super.key, required this.message});

  @override
  ConsumerState<AdminMessageDetailPage> createState() => _AdminMessageDetailPageState();
}

class _AdminMessageDetailPageState extends ConsumerState<AdminMessageDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late final SocketService _socketService;
  final ScrollController _scrollController = ScrollController(); // Ajout

  @override
  void initState() {
    super.initState();
    _loadConversation();

    _socketService = ref.read(socketServiceProvider);
    _socketService.on('new_message', _onNewMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      if (data['type'] == 'message') {
        final receiver = widget.message['receiver'];
        final receiverId = receiver?['idUser'];
        final senderId = int.tryParse(data['senderId'] ?? '');
        final notifReceiverId = int.tryParse(data['receiverId'] ?? '');
        if (senderId == receiverId || notifReceiverId == receiverId) {
          _loadConversation();
        }
        NotificationService.showMessageNotification(Map<String, dynamic>.from(data));
      }
    });
  }

  void _onNewMessage(dynamic data) {
    if (!mounted) return;
    final receiver = widget.message['receiver'];
    final receiverId = receiver?['idUser'];
    if (data is Map &&
        ((data['sender']?['idUser'] == receiverId) ||
         (data['receiver']?['idUser'] == receiverId))) {
      _loadConversation();
      NotificationService.showMessageNotification(Map<String, dynamic>.from(data));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _loadConversation() async {
    final receiver = widget.message['receiver'];
    final receiverId = receiver?['idUser'];
    if (receiverId == null) return;
    try {
      final conv = await AdminMessageService().fetchConversation(receiverId);
      final admin = ref.read(authProvider);
      if (admin != null) {
        for (final msg in conv) {
          // Marquer comme lu uniquement les messages reçus par l'admin et non lus
          if (msg['receiver']?['idUser'] == admin.idUser && msg['is_read'] == false) {
            await AdminMessageService().markAsRead(msg['id']);
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _messages.addAll(conv.map((msg) => {
          'content': msg['content'],
          'sentByAdmin': msg['sender']?['role'] == 'admin',
          'time': msg['created_at']?.toString().substring(11, 16) ?? '',
          'sender': msg['sender'],
          'receiver': msg['receiver'],
        }));
      });
      ref.invalidate(adminUnreadCountProvider);
      _scrollToBottom();
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Ajout ici
    _socketService.off('new_message');
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        final receiver = widget.message['receiver'];
        final receiverId = receiver?['idUser'];
        if (receiverId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Destinataire inconnu')),
          );
          return;
        }

        final sentMsg = await AdminMessageService().sendMessage(
          receiverId: receiverId,
          content: text,
        );

        setState(() {
          _messages.add({
            'content': sentMsg['content'],
            'sentByAdmin': true,
            'time': sentMsg['created_at']?.toString().substring(11, 16) ?? TimeOfDay.now().format(context),
            'sender': sentMsg['sender'],
            'receiver': sentMsg['receiver'],
          });
          _controller.clear();
        });
        _scrollToBottom(); // Ajout ici
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi du message')),
        );
      }
    }
  }

  void _pickFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sélection de fichier non implémentée')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiver = widget.message['receiver'];
    final receiverName = '${receiver?['lastName'] ?? ''} ${receiver?['firstName'] ?? ''}';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            ref.invalidate(adminMessagesProvider);
            ref.invalidate(adminUnreadCountProvider); // Ajoute cette ligne
          },
        ),
        title: Text(
          receiverName,
          style: AppStyles.heading1.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => ListView(
                  shrinkWrap: true,
                  children: const [
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Infos contact'),
                    ),
                    ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Supprimer la conversation'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone des messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Ajout ici
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isSentByAdmin = msg['sentByAdmin'] as bool;
                return Align(
                  alignment: isSentByAdmin
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSentByAdmin ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['content'],
                          style: AppStyles.bodyText.copyWith(
                            color: isSentByAdmin ? Colors.white : AppColors.textDark,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: AppStyles.caption.copyWith(
                            color: isSentByAdmin ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Zone de saisie
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: AppColors.primary),
                  onPressed: _pickFile,
                  tooltip: 'Joindre un fichier',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      hintStyle: AppStyles.bodyText.copyWith(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}