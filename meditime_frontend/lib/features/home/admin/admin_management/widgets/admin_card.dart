import 'package:flutter/material.dart';
import 'package:meditime_frontend/models/admin_model.dart';

class AdminCard extends StatelessWidget {
  final AdminModel admin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AdminCard({
    super.key,
    required this.admin,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = admin.adminRole == 'super_admin'
        ? Colors.deepPurple
        : admin.adminRole == 'admin'
            ? Colors.blue
            : Colors.orange;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              backgroundImage: (admin.email.isNotEmpty && admin.email.contains('@') && admin.firstName == null)
                  ? null
                  : null, // Ajoute ici l'image réseau si tu as admin.profilePhoto
              child: (admin.firstName?.isNotEmpty ?? false)
                  ? Text(
                      admin.firstName![0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    )
                  : const Icon(Icons.person, size: 32, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            // Infos principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom ou email
                  Text(
                    "${admin.firstName ?? ''} ${admin.lastName ?? ''}".trim().isEmpty
                        ? admin.email
                        : "${admin.firstName ?? ''} ${admin.lastName ?? ''}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    admin.email,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rôle
                  Row(
                    children: [
                      Icon(
                        admin.adminRole == 'super_admin'
                            ? Icons.verified_user
                            : admin.adminRole == 'admin'
                                ? Icons.admin_panel_settings
                                : Icons.shield,
                        color: color,
                        size: 18,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        admin.adminRole == 'super_admin'
                            ? "Super Admin"
                            : admin.adminRole == 'admin'
                                ? "Admin"
                                : "Modérateur",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions et badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Modifier", style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue,
                    minimumSize: const Size(90, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: onEdit,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text("Supprimer", style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    minimumSize: const Size(90, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}