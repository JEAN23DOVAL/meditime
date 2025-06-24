import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/core/network/socket_service.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/socket_provider.dart';
import 'package:meditime_frontend/services/user_message_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessageDetailPage extends ConsumerStatefulWidget {
  final String senderName;
  final String messageContent;
  final String time;
  final int receiverId; // Ajoute ce paramètre

  const MessageDetailPage({
    super.key,
    required this.senderName,
    required this.messageContent,
    required this.time,
    required this.receiverId, // Ajoute ce paramètre
  });

  @override
  ConsumerState<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends ConsumerState<MessageDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late final SocketService _socketService; // Ajoute cette ligne
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadConversation();

    _socketService = ref.read(socketServiceProvider); // Stocke ici
    _socketService.on('new_message', _onNewMessage);

    // Ajoute ce listener FCM pour recharger si la notif concerne la conversation ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      if (data['type'] == 'message') {
        final senderId = int.tryParse(data['senderId'] ?? '');
        final receiverId = int.tryParse(data['receiverId'] ?? '');
        if (senderId == widget.receiverId || receiverId == widget.receiverId) {
          _loadConversation();
        }
      }
    });
  }

  void _onNewMessage(dynamic data) {
    if (!mounted) return; // Ajoute cette ligne
    if (data is Map &&
        ((data['sender']?['idUser'] == widget.receiverId) ||
         (data['receiver']?['idUser'] == widget.receiverId))) {
      _loadConversation();
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
    try {
      final conv = await UserMessageService().fetchConversation(widget.receiverId);
      final currentUser = ref.read(authProvider);
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _messages.addAll(conv.map((msg) => {
          'content': msg['content'],
          'sentByUser': msg['sender']?['idUser'] == currentUser?.idUser,
          'time': msg['created_at']?.toString().substring(11, 16) ?? '',
          'sender': msg['sender'],
          'receiver': msg['receiver'],
        }));
      });
      _scrollToBottom();
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _socketService.off('new_message'); // Utilise la variable
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        final receiverId = widget.receiverId;
        await UserMessageService().sendMessage(
          receiverId: receiverId,
          content: text,
        );
        _controller.clear();
        await _loadConversation(); // Recharge la conversation après envoi
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi du message')),
        );
      }
    }
  }

  void _pickFile() {
    // Ajoute ici la logique pour choisir un fichier (FilePicker, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sélection de fichier non implémentée')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.senderName,
          style: AppStyles.heading1.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Affiche un menu ou des options supplémentaires
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
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isSentByUser = msg['sentByUser'] as bool;
                return Align(
                  alignment: isSentByUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSentByUser ? AppColors.primary : Colors.white,
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
                            color: isSentByUser ? Colors.white : AppColors.textDark,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: AppStyles.caption.copyWith(
                            color: isSentByUser ? Colors.white70 : Colors.grey,
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
                // Icône pièce jointe
                IconButton(
                  icon: const Icon(Icons.attach_file, color: AppColors.primary),
                  onPressed: _pickFile,
                  tooltip: 'Joindre un fichier',
                ),
                // Champ de texte
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
                // Bouton envoyer
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