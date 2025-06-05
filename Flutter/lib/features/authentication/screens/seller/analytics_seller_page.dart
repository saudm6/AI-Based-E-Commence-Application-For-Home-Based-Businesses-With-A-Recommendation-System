import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsSellerPage extends StatefulWidget {
  const AnalyticsSellerPage({super.key});

  @override
  _AnalyticsSellerPageState createState() => _AnalyticsSellerPageState();
}

class _AnalyticsSellerPageState extends State<AnalyticsSellerPage> {

  // Options for time windows
  final List<int> _daysOptions = [7, 14];
  final List<String> _daysLabels = ['1W', '2W'];
  int _selectedRangeIndex = 0;

  bool _showRevenue = true;

  // Chart data
  List<FlSpot> _spots = [];
  List<DateTime> _dates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  // Loads order from firestore
  Future<void> _loadChartData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Not signed in';

      // Determine date range
      final end = DateTime.now();
      final days = _daysOptions[_selectedRangeIndex];
      final start = end.subtract(Duration(days: days - 1));

      // Initialize daily buckets
      final Map<DateTime, double> revenueMap = {};
      final Map<DateTime, int> countMap = {};
      for (int i = 0; i < days; i++) {
        final date = DateTime(start.year, start.month, start.day + i);
        revenueMap[date] = 0;
        countMap[date] = 0;
      }

      final ordersSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .get();

      // Add revenue
      for (var doc in ordersSnap.docs) {
        final data = doc.data();
        final ts = data['createdAt'] as Timestamp?;
        if (ts == null) continue;
        final date = ts.toDate();
        final bucket = DateTime(date.year, date.month, date.day);
        if (!revenueMap.containsKey(bucket)) continue;
        revenueMap[bucket] = revenueMap[bucket]! + (data['totalAmount'] as num).toDouble();
        countMap[bucket] = countMap[bucket]! + 1;
      }

      // Build spots
      final List<DateTime> sortedDates = revenueMap.keys.toList()..sort();
      final List<FlSpot> spots = [];
      for (int i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        final y = _showRevenue ? revenueMap[date]! : countMap[date]!.toDouble();
        spots.add(FlSpot(i.toDouble(), y));
      }

      // Update state
      setState(() {
        _dates = sortedDates;
        _spots = spots;
        _isLoading = false;
      });
    } catch (e) {
      // Error state
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Range toggle
            ToggleButtons(
              isSelected: List.generate(
                  _daysOptions.length,
                      (i) => i == _selectedRangeIndex),
              onPressed: (idx) {
                setState(() => _selectedRangeIndex = idx);
                _loadChartData();
              },
              children: _daysLabels
                  .map((label) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(label),
              ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Revenue toggle
            ToggleButtons(
              isSelected: [ _showRevenue, !_showRevenue ],
              onPressed: (idx) {
                setState(() => _showRevenue = (idx == 0));
                _loadChartData();
              },
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Revenue')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Orders')),
              ],
            ),

            const SizedBox(height: 24),

            // Chart area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : LineChart(
                LineChartData(

                  // Axes title and data
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= _dates.length) return const SizedBox();
                          final date = _dates[idx];
                          final label =
                              '${date.day}';
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(label, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),

                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: true),

                  // Add line points
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isStrokeCapRound: true,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}