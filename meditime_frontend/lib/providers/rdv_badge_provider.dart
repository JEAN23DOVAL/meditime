import 'package:flutter_riverpod/flutter_riverpod.dart';

final rdvBadgeProvider = StateNotifierProvider<RdvBadgeNotifier, int>((ref) => RdvBadgeNotifier());

class RdvBadgeNotifier extends StateNotifier<int> {
  RdvBadgeNotifier() : super(0);

  void increment() => state++;
  void clear() => state = 0;
  void set(int value) => state = value;
}