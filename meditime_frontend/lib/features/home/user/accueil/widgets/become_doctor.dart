import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:meditime_frontend/configs/app_routes.dart';
import 'package:meditime_frontend/widgets/buttons/buttons.dart';

class BecomeDoctor extends StatelessWidget {
  const BecomeDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.medical_services,
            size: 40,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Devenir Médecin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Proposez vos services aux patients.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          CircleIconButton(
            onPressed: () => context.go(AppRoutes.devenirMedecin),
            icon: MdiIcons.arrowTopRight,
            size: 50,
            backgroundColor: Colors.blueAccent,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}