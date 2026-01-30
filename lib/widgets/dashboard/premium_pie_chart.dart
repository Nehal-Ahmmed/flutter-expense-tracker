import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/models/category.dart';

class PremiumPieChart extends StatefulWidget {
  final Map<CategoryType, double> categorySpending;
  final double totalExpense;

  const PremiumPieChart({
    super.key,
    required this.categorySpending,
    required this.totalExpense,
  });

  @override
  State<PremiumPieChart> createState() => _PremiumPieChartState();
}

class _PremiumPieChartState extends State<PremiumPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Sort logic
    final sortedEntries = widget.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4, // Spacing between sections
              centerSpaceRadius: 60, // Donut hole size
              sections: getSections(sortedEntries),
            ),
          ),
          // Center Summary
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                '\$${widget.totalExpense.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> getSections(
    List<MapEntry<CategoryType, double>> entries,
  ) {
    return List.generate(entries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 70.0 : 60.0;
      final entry = entries[i];
      final percentage = (entry.value / widget.totalExpense) * 100;

      // Add shadow/glow effect on touched sections could be done with decorations but limited in fl_chart section

      return PieChartSectionData(
        color: entry.key.color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
        badgeWidget: _Badge(
          entry.key.icon,
          size: 30,
          borderColor: entry.key.color,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, {required this.size, required this.borderColor});
  final IconData icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PdfChart.defaultAnimationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: size * 0.6, color: borderColor),
      ),
    );
  }
}

// Placeholder for PdfChart reference if not available
class PdfChart {
  static const defaultAnimationDuration = Duration(milliseconds: 300);
}
