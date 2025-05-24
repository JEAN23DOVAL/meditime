import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/features/home/admin/messages/admin_message_detail_page.dart';
import 'package:meditime_frontend/features/home/admin/provider/admin_message_provider.dart';

import '../widgets/admin_drawer.dart';

class AdminMessagesPage extends StatefulWidget {
  const AdminMessagesPage({super.key});

  @override
  State<AdminMessagesPage> createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends State<AdminMessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Patient'),
            Tab(text: 'Médecin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminMessageList(receiverRole: 'patient'),
          AdminMessageList(receiverRole: 'doctor'),
        ],
      ),
    );
  }
}

class AdminMessageList extends ConsumerWidget {
  final String receiverRole; // 'patient' ou 'doctor'
  const AdminMessageList({super.key, required this.receiverRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(adminMessagesProvider);

    return messagesAsync.when(
      data: (messages) {
        // Filtrage par rôle du destinataire
        final filtered = messages.where((msg) =>
          msg['receiver']?['role'] == receiverRole
        ).toList();

        // Regrouper les messages par conversation (en utilisant l'ID de la conversation)
        final Map<String, List<Map<String, dynamic>>> conversations = {};
        for (var msg in filtered) {
          final receiver = msg['receiver'];
          final receiverId = receiver?['idUser'];
          if (receiverId == null) continue;
          final convKey = receiverId.toString();
          conversations.putIfAbsent(convKey, () => []);
          conversations[convKey]!.add(msg);
        }

        if (conversations.isEmpty) {
          return const Center(child: Text('Aucun message'));
        }

        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final msgs = conversations.values.toList()[index];
            msgs.sort((a, b) => b['created_at'].compareTo(a['created_at']));
            final msg = msgs.first; // Le dernier message de la conversation
            final receiver = msg['receiver'];
            // final sender = msg['sender'];
            final isUnread = msg['is_read'] == false;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminMessageDetailPage(message: msg),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                decoration: BoxDecoration(
                  color: isUnread ? Colors.deepPurple.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.withOpacity(0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo de profil
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.deepPurple.withOpacity(0.10),
                      backgroundImage: receiver?['profilePhoto'] != null
                          ? NetworkImage(receiver['profilePhoto'])
                          : const AssetImage('assets/images/avatar.png') as ImageProvider,
                    ),
                    const SizedBox(width: 14),
                    // Nom + message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom de l'expéditeur (au-dessus)
                          Text(
                            '${receiver?['lastName'] ?? ''} ${receiver?['firstName'] ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Ligne message + heure
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  msg['content'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                msg['created_at']?.toString().substring(11, 16) ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 6),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}