import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/resume.dart';

class AtsTrendChart extends StatelessWidget {
  final List<Resume> resumes;

  const AtsTrendChart({super.key, required this.resumes});

  @override
  Widget build(BuildContext context) {
    if (resumes.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text('Create more resumes to see your trend.'),
        ),
      );
    }

    // Sort chronologically for the chart
    final sortedResumes = List<Resume>.from(resumes)
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    final spots = sortedResumes.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value.atsScore ?? 0).toDouble(),
      );
    }).toList();

    // Ensure we have at least 2 points to draw a line
    if (spots.length == 1) {
      spots.insert(0, FlSpot(-1, spots.first.y));
    }

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: spots.first.x,
          maxX: spots.last.x,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.blue400,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.blue400.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
