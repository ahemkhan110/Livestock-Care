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
    timer =
        Timer.periodic(const Duration(seconds: 5), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farm Care',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(
                  "Body Temperature", temperature, Colors.black, screenHeight),
              _buildInfoCard(
                  "Heart Rate (BPM)", bpm, Colors.black, screenHeight),
              _buildMotionCard(screenHeight),
              _buildGraph(screenHeight),
              Text(
                'Last Updated: $lastUpdated',
                style: TextStyle(
                  fontSize: screenHeight * 0.015,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String? value, Color color, double screenHeight) {
    return Card(
      color: Colors.teal.shade100,
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenHeight * 0.015,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenHeight * 0.025,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              value ?? 'Loading...',
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionCard(double screenHeight) {
    return Card(
      elevation: 5,
      color: Colors.teal.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenHeight * 0.015,
        ),
        child: Column(
          children: [
            Text(
              'Motion Activity',
              style: TextStyle(
                fontSize: screenHeight * 0.025,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMotionValue("X", motionX, screenHeight),
                _buildMotionValue("Y", motionY, screenHeight),
                _buildMotionValue("Z", motionZ, screenHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionValue(String axis, String? value, double screenHeight) {
    return Column(
      children: [
        Text(
          'Motion $axis',
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value ?? 'Loading...',
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGraph(double screenHeight) {
    return Card(
      color: Colors.teal.shade100,
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          children: [
            Text(
              'Motion Graph',
              style: TextStyle(
                fontSize: screenHeight * 0.025,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              height: screenHeight * 0.25,
              child: LineChart(
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
                      colors: [Colors.blueAccent],
                      barWidth: 3,
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
