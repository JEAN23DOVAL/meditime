import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
import 'package:meditime_frontend/features/home/user/messages/widgets/message_category_tab.dart';
import 'package:meditime_frontend/models/user_model.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/providers/rdv_provider.dart';
import 'package:meditime_frontend/features/home/user/messages/widgets/message_detail_page.dart';

import '../providers/user_message_provider.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force le rafraîchissement des messages à chaque ouverture de la page
    ref.invalidate(userMessagesProvider('all'));
    ref.invalidate(userMessagesProvider('doctor'));
    ref.invalidate(userMessagesProvider('admin'));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Messages', style: AppStyles.heading1.copyWith(color: AppColors.textLight)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        centerTitle: true,
      ),
      body: const MessageCategoryTab(filterType: 'all'), // ou adapte selon ton besoin
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              heroTag: 'messages_fab', // <-- Ajoute cette ligne pour un tag unique
              icon: const Icon(Icons.add_comment),
              label: const Text("Nouveau message"),
              backgroundColor: AppColors.primary,
              onPressed: () => _showNewConversationDialog(context, user),
            ),
    );
  }

  void _showNewConversationDialog(BuildContext context, User user) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: _NewConversationList(user: user, ref: ref),
      ),
    );
  }
}

// Widget pour afficher la liste des contacts possibles
class _NewConversationList extends StatefulWidget {
  final User user;
  final WidgetRef ref;
  const _NewConversationList({required this.user, required this.ref});

  @override
  State<_NewConversationList> createState() => _NewConversationListState();
}

class _NewConversationListState extends State<_NewConversationList> {
  late Future<List<User>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _fetchContacts();
  }

  Future<List<User>> _fetchContacts() async {
    // On récupère tous les RDV de l'utilisateur
    final rdvs = await widget.ref.read(rdvServiceProvider).fetchRdvs(
      patientId: widget.user.role == 'patient' ? widget.user.idUser : null,
      doctorId: widget.user.role == 'doctor' ? widget.user.idUser : null,
    );
    // Statuts autorisés
    const allowedStatuses = ['completed', 'upcoming', 'no_show', 'doctor_no_show', 'cancelled'];
    // On extrait les contacts uniques
    final contacts = <int, User>{};
    for (final rdv in rdvs) {
      if (!allowedStatuses.contains(rdv.status)) continue; // <-- FILTRE ICI
      if (widget.user.role == 'patient' && rdv.doctor != null) {
        contacts[rdv.doctor!.idUser] = rdv.doctor!;
      }
      if (widget.user.role == 'doctor' && rdv.patient != null) {
        contacts[rdv.patient!.idUser] = rdv.patient!;
      }
    }
    return contacts.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<User>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snapshot.data ?? [];
          if (contacts.isEmpty) {
            return const Center(child: Text("Aucun contact disponible pour démarrer une conversation."));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final name = contact.role == 'doctor'
                  ? 'Dr. ${(contact.firstName ?? '').trim()} ${(contact.lastName).trim()}'
                  : '${contact.firstName ?? ''} ${contact.lastName}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MessageDetailPage(
                          senderName: name,
                          messageContent: '',
                          time: '',
                          receiverId: contact.idUser,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: contact.profilePhoto != null && contact.profilePhoto!.isNotEmpty
                                  ? NetworkImage(contact.profilePhoto!)
                                  : null,
                              child: contact.profilePhoto == null
                                  ? const Icon(Icons.person, size: 32, color: Colors.white)
                                  : null,
                              backgroundColor: Colors.deepPurple[100],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.role == 'doctor'
                                      ? 'Dr. ${(contact.firstName ?? '').trim()} ${(contact.lastName).trim()}'
                                      : '${contact.firstName ?? ''} ${contact.lastName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (contact.role == 'doctor' &&
                                    contact.specialite != null &&
                                    contact.specialite!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      contact.specialite!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.deepPurple,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MessageDetailPage(
                                      senderName: name,
                                      messageContent: '',
                                      time: '',
                                      receiverId: contact.idUser,
                                    ),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.message, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}