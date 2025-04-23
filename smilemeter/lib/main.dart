// SmileMeter Flutter Kiosk App with Charts, Cloud Sync, and Feedback Effects

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SmileMeterApp());
}

class SmileMeterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmileMeter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SmileHomePage(),
    );
  }
}

class SmileHomePage extends StatefulWidget {
  @override
  _SmileHomePageState createState() => _SmileHomePageState();
}

class _SmileHomePageState extends State<SmileHomePage> {
  final List<String> labels = ['Happy', 'Neutral', 'Unhappy'];
  final List<String> emojis = ['🙂', '😐', '😕'];
  final AudioPlayer _player = AudioPlayer();
  final CollectionReference votesRef = FirebaseFirestore.instance.collection('votes');
  String? message;
  Map<String, int> counts = {'Happy': 0, 'Neutral': 0, 'Unhappy': 0};

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('votes').snapshots().listen((snapshot) {
      Map<String, int> newCounts = {'Happy': 0, 'Neutral': 0, 'Unhappy': 0};
      for (var doc in snapshot.docs) {
        String label = doc['vote'];
        newCounts[label] = (newCounts[label] ?? 0) + 1;
      }
      setState(() {
        counts = newCounts;
      });
    });
  }

  void logVote(int index) async {
    await votesRef.add({
      'timestamp': DateTime.now().toIso8601String(),
      'vote': labels[index]
    });

    _player.play(AssetSource('sounds/vote.mp3'));

    setState(() {
      message = 'Thanks for your feedback: ${emojis[index]}';
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        message = null;
      });
    });
  }

  BarChartGroupData _barGroup(int x, int value) => BarChartGroupData(x: x, barRods: [
    BarChartRodData(toY: value.toDouble(), color: Colors.lightBlue, width: 22)
  ]);

  Widget voteChart() {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        barGroups: List.generate(labels.length, (i) => _barGroup(i, counts[labels[i]] ?? 0)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) =>
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(labels[value.toInt()], style: TextStyle(fontSize: 12)),
              ))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('How was your experience?', style: TextStyle(fontSize: 28)),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(emojis.length, (index) {
                return ElevatedButton(
                  onPressed: () => logVote(index),
                  child: Text(emojis[index], style: TextStyle(fontSize: 50)),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(20)),
                );
              }),
            ),
            SizedBox(height: 20),
            if (message != null)
              Text(message!, style: TextStyle(fontSize: 20, color: Colors.green)),
            SizedBox(height: 30),
            Expanded(child: voteChart()),
          ],
        ),
      ),
    );
  }
}
\