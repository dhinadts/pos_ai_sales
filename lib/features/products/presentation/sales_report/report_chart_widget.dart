import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_ai_sales/features/products/domain/sales_record.dart';

class ReportChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;
  final String filterType; // daily, weekly, monthly, yearly
  final String chartType; // bar, line, pie

  const ReportChartWidget({
    super.key,
    required this.salesData,
    required this.filterType,
    this.chartType = 'bar',
  });

  @override
  State<ReportChartWidget> createState() => _ReportChartWidgetState();
}

class _ReportChartWidgetState extends State<ReportChartWidget> {
  bool _isLoading = false;
  String _selectedChartType = 'multi_line';

  @override
  void initState() {
    super.initState();
    _selectedChartType = widget.chartType;
  }

  @override
  void didUpdateWidget(ReportChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.salesData != widget.salesData ||
        oldWidget.filterType != widget.filterType) {
      _simulateLoading();
    }
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return [];

    DateTime now = DateTime.now();
    DateTime start;

    switch (widget.filterType.toLowerCase()) {
      case 'daily':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'monthly':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'yearly':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        start = DateTime(2000);
    }

    return data.where((item) {
      try {
        final d = SalesRecord.parseDate(item['date']);
        return d.isAfter(start.subtract(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Map<String, double> _aggregateByProduct(List<Map<String, dynamic>> data) {
    final Map<String, double> aggregated = {};

    for (final item in data) {
      try {
        final productName =
            item['productName']?.toString() ?? 'Unknown Product';
        final amount = (item['amount'] ?? item['total'] ?? 0.0) as num;

        aggregated[productName] =
            (aggregated[productName] ?? 0.0) + amount.toDouble();
      } catch (_) {
        continue;
      }
    }

    return aggregated;
  }

  Map<String, double> _aggregateByCategory(List<Map<String, dynamic>> data) {
    // For demo purposes, creating mock categories based on product names
    final Map<String, double> aggregated = {};
    final categoryMap = {
      'Product A': 'Electronics',
      'Product B': 'Clothing',
      'Product C': 'Home & Kitchen',
      'Product D': 'Electronics',
      'Product E': 'Sports',
      'Unknown': 'Other',
    };

    for (final item in data) {
      try {
        final productName = item['productName']?.toString() ?? 'Unknown';
        final category = categoryMap[productName] ?? 'Other';
        final amount = (item['amount'] ?? item['total'] ?? 0.0) as num;

        aggregated[category] =
            (aggregated[category] ?? 0.0) + amount.toDouble();
      } catch (_) {
        continue;
      }
    }

    return aggregated;
  }

  Widget _buildBarChart(Map<String, double> aggregatedData) {
    final labels = aggregatedData.keys.toList();
    final amounts = aggregatedData.values.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: amounts.isNotEmpty
            ? (amounts.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble()
            : 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey[300], strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateInterval(amounts),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '₹${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      _truncateLabel(labels[index]),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = labels[groupIndex];
              return BarTooltipItem(
                '$label\n₹${rod.toY.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        barGroups: List.generate(amounts.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: amounts[i],
                color: _getBarColor(i, amounts.length),
                borderRadius: BorderRadius.circular(4),
                width: 16,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(Map<String, double> aggregatedData) {
    final labels = aggregatedData.keys.toList();
    final amounts = aggregatedData.values.toList();
    final spots = List.generate(
      amounts.length,
      (i) => FlSpot(i.toDouble(), amounts[i]),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey[300], strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateInterval(amounts),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '₹${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      _truncateLabel(labels[index]),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Map<String, List<FlSpot>> _generateMultiLineSpots(
    List<Map<String, dynamic>> data,
  ) {
    Map<String, List<FlSpot>> lineMap = {};

    // Sort by date ASC
    data.sort((a, b) => a["date"].compareTo(b["date"]));

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final productName = item['productName'] ?? "Unknown";
      final total = (item['total'] ?? 0).toDouble();

      lineMap.putIfAbsent(productName, () => []);
      lineMap[productName]!.add(FlSpot(i.toDouble(), total));
    }

    return lineMap;
  }

  Widget _buildMultiLineChart(List<SalesRecord> sales) {
    if (sales.isEmpty) {
      return const Center(
        child: Text("No Sales Data Available", style: TextStyle(fontSize: 16)),
      );
    }

    // Sort by date ASC
    sales.sort((a, b) => a.date.compareTo(b.date));

    // Convert dates → x-axis (0,1,2,3...)
    final List<FlSpot> totalLine = [];
    final List<FlSpot> qtyLine = [];

    for (int i = 0; i < sales.length; i++) {
      totalLine.add(FlSpot(i.toDouble(), sales[i].total));
      qtyLine.add(FlSpot(i.toDouble(), sales[i].qty.toDouble()));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (sales.length - 1).toDouble(),

        minY: 0,
        maxY: _calculateMaxY(sales),

        gridData: const FlGridData(show: true),

        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= sales.length) return const SizedBox();
                return Text(
                  DateFormat('dd/MM').format(sales[index].date),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),

        borderData: FlBorderData(show: true),

        lineBarsData: [
          /// 🔵 LINE 1 — Total Amount
          LineChartBarData(
            spots: totalLine,
            isCurved: true,
            barWidth: 3,
            color: Colors.cyan,
            dotData: const FlDotData(show: true),
          ),

          /// 🟣 LINE 2 — Quantity
          LineChartBarData(
            spots: qtyLine,
            isCurved: true,
            barWidth: 3,
            color: Colors.deepPurple,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  /// Dynamically find max Y value
  double _calculateMaxY(List<SalesRecord> sales) {
    final maxTotal = sales.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final maxQty = sales.map((e) => e.qty).reduce((a, b) => a > b ? a : b);
    return (maxTotal > maxQty ? maxTotal : maxQty) * 1.2; // padding for chart
  }

  Color _getNeonColor(int index) {
    const neon = [
      Color(0xFF00F5A0), // Neon Green
      Color(0xFF00D4FF), // Neon Blue
      Color(0xFFBD00FF), // Neon Purple
      Color(0xFFFF0099), // Neon Pink
      Color(0xFFFFA500), // Orange
    ];
    return neon[index % neon.length];
  }

  /*  Widget _buildMultiLineChart(Map<String, double> aggregatedData) {
    final labels = aggregatedData.keys.toList();
    final amounts = aggregatedData.values.toList();

    // Create 3 sample lines (you can map categories/products later)
    List<List<double>> demoLines = [
      List.generate(amounts.length, (i) => amounts[i] * 0.8),
      List.generate(amounts.length, (i) => amounts[i] * 1.1),
      List.generate(amounts.length, (i) => amounts[i] * 0.6),
    ];

    List<List<FlSpot>> allSpots = demoLines
        .map(
          (line) =>
              List.generate(line.length, (i) => FlSpot(i.toDouble(), line[i])),
        )
        .toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: amounts.length.toDouble() - 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Colors.white.withOpacity(0.15),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}',
                  const TextStyle(color: Colors.white, fontSize: 14),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= labels.length)
                  return const SizedBox();
                return Text(
                  labels[index],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        lineBarsData: List.generate(allSpots.length, (lineIndex) {
          return LineChartBarData(
            spots: allSpots[lineIndex],
            isCurved: true,
            barWidth: 5,
            gradient: LinearGradient(
              colors: [
                _getNeonColor(lineIndex).withOpacity(0.9),
                _getNeonColor(lineIndex + 1).withOpacity(0.9),
              ],
            ),
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _getNeonColor(lineIndex).withOpacity(0.35),
                  _getNeonColor(lineIndex + 1).withOpacity(0.35),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          );
        }),
      ),
      // swapAnimationDuration: const Duration(milliseconds: 700),
      // swapAnimationCurve: Curves.easeInOut,
    );
  }

  Color _getNeonColor(int index) {
    const neonColors = [
      Color(0xFF00F5A0), // neon green
      Color(0xFF00D4FF), // neon cyan
      Color(0xFFBD00FF), // neon purple
      Color(0xFFFF0099), // neon pink
    ];
    return neonColors[index % neonColors.length];
  }

  */
  Widget _buildPieChart(Map<String, double> aggregatedData) {
    final labels = aggregatedData.keys.toList();
    final amounts = aggregatedData.values.toList();
    final total = amounts.fold(0.0, (sum, amount) => sum + amount);

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: List.generate(amounts.length, (i) {
          final percentage = total > 0 ? (amounts[i] / total * 100) : 0;
          return PieChartSectionData(
            color: _getBarColor(i, amounts.length),
            value: amounts[i],
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 30,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  String _truncateLabel(String label) {
    if (label.length <= 12) return label;
    return '${label.substring(0, 10)}...';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading chart data...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final filteredData = _filterData(widget.salesData);
    final aggregatedData = _aggregateByProduct(filteredData);

    if (aggregatedData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No sales data available for this period.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sales Report (${widget.filterType.toUpperCase()})",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              DropdownButton<String>(
                value: _selectedChartType,
                items: const [
                  DropdownMenuItem(
                    value: 'multi_line',
                    child: Text('Multi Line Chart'),
                  ),
                  DropdownMenuItem(value: 'bar', child: Text('Bar Chart')),

                  DropdownMenuItem(value: 'line', child: Text('Line Chart')),
                  DropdownMenuItem(value: 'pie', child: Text('Pie Chart')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedChartType = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.6,
            child: _buildChart(_selectedChartType, aggregatedData),
          ),
          const SizedBox(height: 16),
          _buildLegend(aggregatedData),
        ],
      ),
    );
  }

  Widget _buildChart(String chartType, Map<String, double> aggregatedData) {
    switch (chartType) {
      case 'line':
        return _buildLineChart(aggregatedData);
      case 'pie':
        return _buildPieChart(aggregatedData);
      case 'bar':
        return _buildBarChart(aggregatedData);
      default:
        return _buildMultiLineChart(
          widget.salesData.map((e) => SalesRecord.fromMap(e)).toList(),
        );
    }
  }

  Widget _buildLegend(Map<String, double> aggregatedData) {
    final labels = aggregatedData.keys.toList();
    final amounts = aggregatedData.values.toList();
    final total = amounts.fold(0.0, (sum, amount) => sum + amount);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(labels.length, (i) {
        final percentage = total > 0 ? (amounts[i] / total * 100) : 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: _getBarColor(i, amounts.length),
            ),
            const SizedBox(width: 4),
            Text(
              '${_truncateLabel(labels[i])} (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }),
    );
  }

  double _calculateInterval(List<double> amounts) {
    if (amounts.isEmpty) return 100;
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    if (maxAmount <= 100) return 20;
    if (maxAmount <= 500) return 50;
    if (maxAmount <= 1000) return 100;
    if (maxAmount <= 5000) return 500;
    return 1000;
  }

  Color _getBarColor(int index, int total) {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
      Colors.indigoAccent,
    ];
    return colors[index % colors.length];
  }
}


/* import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;
  final String filterType; // daily, weekly, monthly, yearly

  const ReportChartWidget({
    super.key,
    required this.salesData,
    required this.filterType,
  });

  @override
  State<ReportChartWidget> createState() => _ReportChartWidgetState();
}

class _ReportChartWidgetState extends State<ReportChartWidget> {
  bool _isLoading = false;

  @override
  void didUpdateWidget(ReportChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.salesData != widget.salesData ||
        oldWidget.filterType != widget.filterType) {
      _simulateLoading();
    }
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return [];

    DateTime now = DateTime.now();
    DateTime start;

    switch (widget.filterType.toLowerCase()) {
      case 'daily':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'monthly':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'yearly':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        start = DateTime(2000);
    }

    return data.where((item) {
      try {
        final d =  SalesRecord._parseDate(item['date']);
        return d.isAfter(start.subtract(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Map<String, double> _aggregateData(List<Map<String, dynamic>> data) {
    final Map<String, double> aggregated = {};

    for (final item in data) {
      try {
        final date =  SalesRecord._parseDate(item['date']);
        String key;

        switch (widget.filterType.toLowerCase()) {
          case 'daily':
            key = DateFormat('MM-dd').format(date);
            break;
          case 'weekly':
            final weekStart = date.subtract(Duration(days: date.weekday - 1));
            key = 'W${DateFormat('MM-dd').format(weekStart)}';
            break;
          case 'monthly':
            key = DateFormat('MMM yyyy').format(date);
            break;
          case 'yearly':
            key = DateFormat('yyyy').format(date);
            break;
          default:
            key = DateFormat('MM-dd').format(date);
        }

        final amount = (item['amount'] ?? item['total'] ?? 0.0) as num;
        aggregated[key] = (aggregated[key] ?? 0.0) + amount.toDouble();
      } catch (_) {
        continue;
      }
    }

    return aggregated;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading chart data...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final filteredData = _filterData(widget.salesData);
    final aggregatedData = _aggregateData(filteredData);

    if (aggregatedData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No sales data available for this period.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Convert aggregated data to lists for chart
    final labels = aggregatedData.keys.toList();
    final amounts = aggregatedData.values.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        children: [
          Text(
            "Sales Report (${widget.filterType.toUpperCase()})",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.6,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (amounts.reduce((a, b) => a > b ? a : b) * 1.2)
                    .ceilToDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey[300], strokeWidth: 1),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _calculateInterval(amounts),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // tooltipBgColor: Colors.blueAccent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '₹${rod.toY.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(amounts.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: amounts[i],
                        color: _getBarColor(i, amounts.length),
                        borderRadius: BorderRadius.circular(4),
                        width: 16,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateInterval(List<double> amounts) {
    if (amounts.isEmpty) return 100;
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    if (maxAmount <= 100) return 20;
    if (maxAmount <= 500) return 50;
    if (maxAmount <= 1000) return 100;
    if (maxAmount <= 5000) return 500;
    return 1000;
  }

  Color _getBarColor(int index, int total) {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];
    return colors[index % colors.length];
  }
}
 */