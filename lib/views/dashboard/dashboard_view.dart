import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/sidebar.dart';
import '../../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final controller = Get.put(DashboardController());

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const Sidebar(currentRoute: '/dashboard'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Today\'s Sales'),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${controller.todaySales.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Transactions'),
                            const SizedBox(height: 8),
                            Text(
                              '${controller.totalTransactions}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sales Chart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: controller.salesData.isEmpty
                              ? const Center(child: Text('No sales data available'))
                              : LineChart(
                                  LineChartData(
                                    minX: 0,
                                    maxX: controller.salesData.length.toDouble() - 1,
                                    minY: 0,
                                    maxY: controller.salesData.isEmpty ? 100 : 
                                          controller.salesData
                                              .map((data) => (data['amount'] as num).toDouble())
                                              .reduce((a, b) => a > b ? a : b) * 1.2,
                                    gridData: const FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            if (value.toInt() >= controller.salesData.length) {
                                              return const SizedBox.shrink();
                                            }
                                            final date = DateTime.parse(
                                              controller.salesData[value.toInt()]['date']
                                            );
                                            return Text('${date.day}/${date.month}');
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: controller.salesData.asMap().entries.map((e) {
                                          return FlSpot(
                                            e.key.toDouble(),
                                            (e.value['amount'] as num).toDouble(),
                                          );
                                        }).toList(),
                                        isCurved: false,
                                        dotData: const FlDotData(show: true),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
