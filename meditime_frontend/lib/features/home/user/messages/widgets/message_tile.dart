import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final Map<String, dynamic> msg;
  final VoidCallback? onTap; // <-- Ajoute ce paramètre

  const MessageTile({super.key, required this.msg, this.onTap});

  @override
  Widget build(BuildContext context) {
    final sender = msg['sender'];
    final isUnread = msg['is_read'] == false;

    return GestureDetector(
      onTap: onTap, // <-- Utilise le onTap passé en paramètre
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
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple.withOpacity(0.10),
              backgroundImage: sender?['profilePhoto'] != null
                  ? NetworkImage(sender['profilePhoto'])
                  : const AssetImage('assets/images/avatar.png') as ImageProvider,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender != null
                        ? (sender['role'] == 'admin'
                            ? 'Administrateur (${sender['lastName'] ?? ''} ${sender['firstName'] ?? ''})'
                            : '${sender['lastName'] ?? ''} ${sender['firstName'] ?? ''}')
                        : 'Administrateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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
  }
}