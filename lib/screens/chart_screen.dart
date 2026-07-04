import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik Bulanan'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final txs = provider.transactions;
          if (txs.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          Map<int, double> incomeData = {};
          Map<int, double> expenseData = {};

          for (var t in txs) {
            final dateStr = t['date'] as String;
            DateTime dt = DateTime.parse(dateStr);
            int day = dt.day;
            double amount = (t['amount'] as num).toDouble();
            
            if (t['category_type'] == 'income') {
              incomeData[day] = (incomeData[day] ?? 0) + amount;
            } else {
              expenseData[day] = (expenseData[day] ?? 0) + amount;
            }
          }

          List<FlSpot> incomeSpots = incomeData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
          List<FlSpot> expenseSpots = expenseData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

          incomeSpots.sort((a, b) => a.x.compareTo(b.x));
          expenseSpots.sort((a, b) => a.x.compareTo(b.x));

          int daysInMonth = DateTime(provider.selectedMonth.year, provider.selectedMonth.month + 1, 0).day;

          if (incomeSpots.isEmpty) {
            incomeSpots = [const FlSpot(1, 0), FlSpot(daysInMonth.toDouble(), 0)];
          } else if (incomeSpots.length == 1) {
            incomeSpots.insert(0, const FlSpot(1, 0));
          }

          if (expenseSpots.isEmpty) {
            expenseSpots = [const FlSpot(1, 0), FlSpot(daysInMonth.toDouble(), 0)];
          } else if (expenseSpots.length == 1) {
            expenseSpots.insert(0, const FlSpot(1, 0));
          }
          
          double maxY = 0;
          for (var s in incomeSpots) if(s.y > maxY) maxY = s.y;
          for (var s in expenseSpots) if(s.y > maxY) maxY = s.y;
          maxY = maxY == 0 ? 100 : maxY * 1.5;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Arus Kas (Bulan Ini)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: incomeSpots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
                        ),
                        LineChartBarData(
                          spots: expenseSpots,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.1)),
                        ),
                      ],
                      minX: 1,
                      maxX: daysInMonth.toDouble(),
                      minY: 0,
                      maxY: maxY,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Container(width: 16, height: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Pemasukan')
                      ],
                    ),
                    Row(
                      children: [
                        Container(width: 16, height: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Pengeluaran')
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
