import 'package:flutter/material.dart';
import 'message_list.dart';
import 'package:meditime_frontend/configs/app_colors.dart';

class MessageCategoryTab extends StatelessWidget {
  final String filterType;
  const MessageCategoryTab({required this.filterType, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: AppColors.secondary,
            elevation: 0,
            bottom: const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Tous'),
                Tab(text: 'Lu'),
                Tab(text: 'Non lus'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            MessageList(filter: 'all', type: filterType),
            MessageList(filter: 'read', type: filterType),
            MessageList(filter: 'unread', type: filterType),
          ],
        ),
      ),
    );
  }
}