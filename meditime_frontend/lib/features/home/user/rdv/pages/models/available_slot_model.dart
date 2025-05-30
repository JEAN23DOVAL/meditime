class AvailableSlot {
  final DateTime start;
  final DateTime end;
  final bool isTaken;

  AvailableSlot({required this.start, required this.end, required this.isTaken});

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
    start: DateTime.parse(json['start']),
    end: DateTime.parse(json['end']),
    isTaken: json['isTaken'] ?? false,
  );
}