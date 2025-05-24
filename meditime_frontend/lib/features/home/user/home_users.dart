import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditime_frontend/providers/AuthNotifier.dart';
import 'package:meditime_frontend/widgets/home/home_pages.dart';
import 'package:meditime_frontend/widgets/home/home_navbar.dart';

class HomeUsers extends ConsumerStatefulWidget {
  const HomeUsers({super.key});

  @override
  ConsumerState<HomeUsers> createState() => _HomeUsersState();
}

class _HomeUsersState extends ConsumerState<HomeUsers> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider);
    final isDoctor = authUser?.role == 'doctor';

    final pages = buildHomePages(isDoctor: isDoctor);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}