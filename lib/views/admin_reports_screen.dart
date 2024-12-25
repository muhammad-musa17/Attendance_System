import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_reports_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminReportsScreen extends StatelessWidget {
  final AdminReportsController reportsController =
      Get.put(AdminReportsController());

  AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSectionHeader(
                context,
                title: "Attendance Report",
                icon: Icons.bar_chart,
              ),
              _buildAttendanceChart(),
              const SizedBox(height: 30),
              _buildSectionHeader(
                context,
                title: "Leave Report",
                icon: Icons.pie_chart,
              ),
              _buildLeaveChart(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: reportsController.saveReportsToLocalStorage,
                icon: const Icon(Icons.save_alt),
                label: const Text('Save Reports to Local Storage'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildAttendanceChart() {
    return FutureBuilder<List<BarChartGroupData>>(
      future: reportsController.getAttendanceDataForGraph(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState("No attendance data available.");
        }
        return _buildChartContainer(
          child: BarChart(
            BarChartData(
              barGroups: snapshot.data!,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 5,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          reportsController.getMonthName(value.toInt()),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveChart() {
    return FutureBuilder<List<PieChartSectionData>>(
      future: reportsController.getLeaveDataForGraph(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState("No leave data available.");
        }
        return _buildChartContainer(
          child: PieChart(
            PieChartData(
              sections: snapshot.data!,
              centerSpaceRadius: 50,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback:
                    (FlTouchEvent event, PieTouchResponse? response) {},
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.grey,
            size: 60,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer({required Widget child}) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
