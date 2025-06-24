import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RegistrationsBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final List<String> roles;
  final List<Color> roleColors;

  const RegistrationsBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.roles,
    required this.roleColors,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$title\nAucune donnée'),
        ),
      );
    }

    // Prépare les périodes (X) et les données groupées par période/role
    final periods = data.map((e) => e['period'] as String).toSet().toList()..sort();
    final Map<String, Map<String, int>> grouped = {};
    for (final period in periods) {
      grouped[period] = {};
      for (final role in roles) {
        grouped[period]![role] = 0;
      }
    }
    for (final e in data) {
      grouped[e['period']]![e['role']] = e['count'] as int;
    }

    // Prépare les bar groups
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < periods.length; i++) {
      final period = periods[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            for (int j = 0; j < roles.length; j++)
              BarChartRodData(
                toY: (grouped[period]![roles[j]] ?? 0).toDouble(),
                color: roleColors[j],
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  groupsSpace: 16,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= periods.length) return const SizedBox.shrink();

                          // Affiche seulement 1 label sur N, et toujours le premier et le dernier
                          const maxLabels = 6; // Ajuste selon la largeur de ton graphe
                          final step = (periods.length / maxLabels).ceil();
                          if (idx != 0 && idx != periods.length - 1 && idx % step != 0) {
                            return const SizedBox.shrink();
                          }

                          final label = periods[idx];
                          return Transform.rotate(
                            angle: -0.5, // Optionnel : incline le texte pour gagner de la place
                            child: Text(label.substring(5), style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, horizontalInterval: 1),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Légende
            Row(
              children: [
                for (int i = 0; i < roles.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, color: roleColors[i]),
                        const SizedBox(width: 4),
                        Text(roles[i], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RdvLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final Color color;

  const RdvLineChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$title\nAucune donnée'),
        ),
      );
    }

    final xLabels = data.map((e) => e['period'] as String).toList();
    final spots = data.asMap().entries.map((e) {
      final i = e.key;
      final v = double.tryParse(e.value['count'].toString()) ?? 0;
      return FlSpot(i.toDouble(), v);
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (xLabels.length / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= xLabels.length) return const SizedBox.shrink();
                          final label = xLabels[idx];
                          return Text(label.substring(5), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, horizontalInterval: 1),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final Color color;
  final bool area;

  const SimpleLineChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
    this.area = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$title\nAucune donnée'),
        ),
      );
    }
    final xLabels = data.map((e) => e['period'] as String).toList();
    final spots = data.asMap().entries.map((e) {
      final i = e.key;
      final v = double.tryParse(e.value['count'].toString()) ?? 0;
      return FlSpot(i.toDouble(), v);
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: area,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (xLabels.length / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= xLabels.length) return const SizedBox.shrink();
                          final label = xLabels[idx];
                          return Text(label.substring(5), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, horizontalInterval: 1),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bar chart simple pour doctorApplications et reviews
class SimpleBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final Color color;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$title\nAucune donnée'),
        ),
      );
    }
    final periods = data.map((e) => e['period'] as String).toList();
    final barGroups = data.asMap().entries.map((e) {
      final i = e.key;
      final v = double.tryParse(e.value['count'].toString()) ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: v,
            color: color,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= periods.length) return const SizedBox.shrink();
                          final label = periods[idx];
                          return Text(label.substring(5), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, horizontalInterval: 1),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stacked Bar Chart pour rdvStatusStats et doctorApplicationsStatus
class StackedBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final List<String> statuses;
  final List<Color> statusColors;

  const StackedBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.statuses,
    required this.statusColors,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$title\nAucune donnée'),
        ),
      );
    }
    final periods = data.map((e) => e['period'] as String).toSet().toList()..sort();
    final Map<String, Map<String, int>> grouped = {};
    for (final period in periods) {
      grouped[period] = {};
      for (final status in statuses) {
        grouped[period]![status] = 0;
      }
    }
    for (final e in data) {
      grouped[e['period']]![e['status']] = e['count'] as int;
    }

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < periods.length; i++) {
      final period = periods[i];
      double startY = 0;
      final rods = <BarChartRodData>[];
      for (int j = 0; j < statuses.length; j++) {
        final value = (grouped[period]![statuses[j]] ?? 0).toDouble();
        rods.add(
          BarChartRodData(
            toY: startY + value,
            fromY: startY,
            color: statusColors[j],
            width: 16,
            borderRadius: BorderRadius.zero,
          ),
        );
        startY += value;
      }
      barGroups.add(BarChartGroupData(x: i, barRods: rods));
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  groupsSpace: 16,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= periods.length) return const SizedBox.shrink();
                          final label = periods[idx];
                          return Text(label.substring(5), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, horizontalInterval: 1),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Légende scrollable horizontalement
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < statuses.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, color: statusColors[i]),
                          const SizedBox(width: 4),
                          Text(statuses[i], style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Donut Chart pour taux
class DonutChart extends StatelessWidget {
  final double value;
  final String title;
  final Color color;
  final String label;

  const DonutChart({
    super.key,
    required this.value,
    required this.title,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: value,
                          color: color,
                          radius: 24,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 100 - value,
                          color: Colors.grey[200],
                          radius: 24,
                          showTitle: false,
                        ),
                      ],
                      sectionsSpace: 0,
                      centerSpaceRadius: 36,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${value.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
                      Text(label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Single Value Card pour activeDoctors
class SingleValueCard extends StatelessWidget {
  final int value;
  final String title;
  final IconData icon;
  final Color color;

  const SingleValueCard({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}