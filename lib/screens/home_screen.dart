import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  String? temperature;
  String? motionX;
  String? motionY;
  String? motionZ;
  String? bpm;
  String? lastUpdated;

  final String channelId = '2342928';
  final String apiKey = 'KOB9PH6DY7MPDS1C';

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://api.thingspeak.com/channels/$channelId/feeds/last.json?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temperature = data['field1']?.toString() ?? 'Loading...';
        motionX = data['field2']?.toString() ?? 'Loading...';
        motionY = data['field3']?.toString() ?? 'Loading...';
        motionZ = data['field4']?.toString() ?? 'Loading...';
        bpm = data['field5']?.toString() ?? 'Loading...';
        lastUpdated = _formatTimestamp(data['created_at']?.toString() ?? '');
      });
    } else {
      setState(() {
        temperature = 'Error';
        motionX = 'Error';
        motionY = 'Error';
        motionZ = 'Error';
        bpm = 'Error';
        lastUpdated = '';
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    final pakistanTime = DateTime.parse(timestamp).toLocal();
    return '${pakistanTime.day}/${pakistanTime.month}/${pakistanTime.year} ${pakistanTime.hour}:${pakistanTime.minute}:${pakistanTime.second}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Livestock Care',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0, // Remove elevation to match with the background
        backgroundColor: Colors.blue, // Adjust the color to match the background
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Body Temperature',
                      style: TextStyle(fontSize: 12.0, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      temperature ?? 'Loading...',
                      style: TextStyle(fontSize: 20.0,  fontWeight: FontWeight.bold,  color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Heart Rate (BPM)',
                      style: TextStyle(fontSize: 12.0, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      bpm ?? 'Loading...',
                      style: TextStyle(fontSize: 20.0,  fontWeight: FontWeight.bold,  color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Motion Activity',
                      style: TextStyle(fontSize: 12.0, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Motion X',
                              style: TextStyle(fontSize: 16.0, color: Colors.black),
                            ),
                            Text(
                              motionX ?? 'Loading...',
                              style: TextStyle(fontSize: 16.0,  fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Motion Y',
                              style: TextStyle(fontSize: 16.0,  color: Colors.black),
                            ),
                            Text(
                              motionY ?? 'Loading...',
                              style: TextStyle(fontSize: 16.0,  fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Motion Z',
                              style: TextStyle(fontSize: 16.0, color: Colors.black),
                            ),
                            Text(
                              motionZ ?? 'Loading...',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Motion Graph',
                      style: TextStyle(fontSize: 12.0, color: Colors.black),
                    ),
                    Container(
                      width: 300,
                      height: 200,
                      child: Stack(
                        children: [
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: Colors.black.withOpacity(0.3),
                          //     borderRadius: BorderRadius.circular(16),
                          //   ),
                          // ),
                          LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, double.tryParse(motionX ?? '0') ?? 0),
                                    FlSpot(1, double.tryParse(motionY ?? '0') ?? 0),
                                    FlSpot(2, double.tryParse(motionZ ?? '0') ?? 0),
                                  ],
                                  isCurved: true,
                                  colors: [
                                    Colors.blue,
                                    Colors.green,
                                    Colors.orange,
                                  ],
                                ),
                              ],
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Last Updated: $lastUpdated',
                style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
