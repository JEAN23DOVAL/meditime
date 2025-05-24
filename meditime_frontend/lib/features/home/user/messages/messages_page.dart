import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/message_category_tab.dart';
import 'package:meditime_frontend/configs/app_colors.dart';
import 'package:meditime_frontend/configs/app_styles.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Messages', style: AppStyles.heading1.copyWith(color: AppColors.textLight)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        centerTitle: true,
      ),
      body: const MessageCategoryTab(filterType: 'all'), // ou adapte selon ton besoin
    );
  }
}