import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumBarChart extends StatefulWidget {
  final Map<int, double> weeklySpending;

  const PremiumBarChart({super.key, required this.weeklySpending});

  @override
  State<PremiumBarChart> createState() => _PremiumBarChartState();
}

class _PremiumBarChartState extends State<PremiumBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6, // Wider chart
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor.withOpacity(0.5),
              Theme.of(context).cardColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Overview',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'This Week',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: BarChart(
                mainBarData(),
                swapAnimationDuration: const Duration(milliseconds: 250),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData mainBarData() {
    double maxY = 100; // Default min height
    widget.weeklySpending.forEach((_, amount) {
      if (amount > maxY) maxY = amount;
    });
    // Add some buffer to top
    maxY = maxY * 1.2;

    return BarChartData(
      maxY: maxY,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          // tooltipBgColor: Colors.blueGrey, // Use getTooltipItem for styling
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x) {
              case 0:
                weekDay = 'Mon';
                break;
              case 1:
                weekDay = 'Tue';
                break;
              case 2:
                weekDay = 'Wed';
                break;
              case 3:
                weekDay = 'Thu';
                break;
              case 4:
                weekDay = 'Fri';
                break;
              case 5:
                weekDay = 'Sat';
                break;
              case 6:
                weekDay = 'Sun';
                break;
              default:
                weekDay = '';
            }
            return BarTooltipItem(
              '$weekDay\n',
              GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '\$${rod.toY.toInt()}',
                  style: GoogleFonts.outfit(
                    color: Colors.yellowAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getBottomTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.grey,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('M', style: style);
        break;
      case 1:
        text = const Text('T', style: style);
        break;
      case 2:
        text = const Text('W', style: style);
        break;
      case 3:
        text = const Text('T', style: style);
        break;
      case 4:
        text = const Text('F', style: style);
        break;
      case 5:
        text = const Text('S', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: text);
  }

  List<BarChartGroupData> showingGroups() {
    return List.generate(7, (i) {
      final y = widget.weeklySpending[i] ?? 0.0;
      return makeGroupData(i, y, isTouched: i == touchedIndex);
    });
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 18,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 50 : y,
          color: isTouched
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.7),
          width: width,
          borderSide:
              isTouched // Highlight effect
              ? BorderSide(color: Colors.yellow, width: 2)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 700, // Max height
            color: Theme.of(context).disabledColor.withOpacity(0.05),
          ),
          borderRadius: BorderRadius.circular(12),
          gradient: isTouched
              ? LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
              : LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.5),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
