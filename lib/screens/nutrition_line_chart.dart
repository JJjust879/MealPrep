import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class NutritionLineChart extends StatelessWidget {
  final Map<String, List<double>> nutritionByDay;
  final List<String> days;

  const NutritionLineChart({
    Key? key,
    required this.nutritionByDay,
    required this.days,
  }) : super(key: key);

  static const nutrientColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.brown,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  List<LineChartBarData> _buildLineData(List<String> nutrients) {
    return List.generate(nutrients.length, (i) {
      final nutrient = nutrients[i];
      final color = nutrientColors[i % nutrientColors.length];

      return LineChartBarData(
        spots: List.generate(
          days.length,
          (j) => FlSpot(j.toDouble(), nutritionByDay[nutrient]![j]),
        ),
        isCurved: false,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        preventCurveOverShooting: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final nutrients = nutritionByDay.keys.toList();

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition Intake (Past 7 Days)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: math.max(600, days.length * 100.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 24, 16),
                        child: RepaintBoundary(
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 1000,
                              minX: 0,
                              maxX: (days.length - 1).toDouble(),
                              clipData: FlClipData.all(),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0 ||
                                          value == 500 ||
                                          value == 1000) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    interval: 500,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= days.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          days[idx],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                  right: BorderSide(color: Colors.transparent),
                                  top: BorderSide(color: Colors.transparent),
                                ),
                              ),
                              lineBarsData: _buildLineData(nutrients),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 500,
                                getDrawingHorizontalLine:
                                    (value) => FlLine(
                                      color: Colors.grey[300]!,
                                      strokeWidth: 0.5,
                                    ),
                              ),
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchSpotThreshold: 10,
                                handleBuiltInTouches: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: List.generate(nutrients.length, (i) {
                    final color = nutrientColors[i % nutrientColors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          nutrients[i],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nutritional Data Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: RepaintBoundary(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: DataTable(
                        columnSpacing: 16,
                        headingRowHeight: 40,
                        dataRowHeight: 35,
                        border: TableBorder.all(
                          color: Colors.grey[300]!,
                          width: 0.5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        headingTextStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        columns: [
                          const DataColumn(label: Text('Nutrient')),
                          ...days.map(
                            (day) => DataColumn(
                              label: Text(day, textAlign: TextAlign.center),
                            ),
                          ),
                          const DataColumn(label: Text('Avg')),
                          const DataColumn(label: Text('Total')),
                        ],
                        rows:
                            nutrients.map((nutrient) {
                              final values = nutritionByDay[nutrient]!;
                              final total = values.fold<double>(
                                0,
                                (sum, val) => sum + val,
                              );
                              final average = total / values.length;

                              return DataRow(
                                color: MaterialStateProperty.resolveWith<
                                  Color?
                                >((states) {
                                  return nutrients.indexOf(nutrient) % 2 == 0
                                      ? Colors.grey[100]
                                      : Colors.white;
                                }),
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color:
                                                nutrientColors[nutrients
                                                        .indexOf(nutrient) %
                                                    nutrientColors.length],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(nutrient),
                                      ],
                                    ),
                                  ),
                                  ...values.map(
                                    (value) => DataCell(
                                      Text(
                                        value.toStringAsFixed(1),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      average.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      total.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
