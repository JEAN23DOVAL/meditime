import 'package:flutter/foundation.dart';

@immutable
class StatsParams {
  final String period;
  final int nb;
  final String? start;
  final String? end;

  const StatsParams({
    required this.period,
    required this.nb,
    this.start,
    this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsParams &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          nb == other.nb &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => period.hashCode ^ nb.hashCode ^ (start?.hashCode ?? 0) ^ (end?.hashCode ?? 0);
}