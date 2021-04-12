import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

void main() {
  return runApp(ChartApp());
}

class ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chart Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TooltipBehavior _tooltipBehavior;
  late TrackballBehavior _trackballBehavior;
  late Future<List<SalesData>> _future;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    _trackballBehavior = TrackballBehavior(enable: true);
    _future = loadSalesData();
    super.initState();
  }

  Future<List<SalesData>> loadSalesData() async {
    List<SalesData> chartData = [];
    String jsonString = await getJsonFromFirebaseRestAPI();
    final jsonResponse = json.decode(jsonString);
    setState(() {
      for (Map<String, dynamic> i in jsonResponse) chartData.add(SalesData.fromJson(i));
    });

    return chartData;
  }

  Future<String> getJsonFromFirebaseRestAPI() async {
    var url = "https://flutterdemo-f6d47.firebaseio.com/chartSalesData.json";
    var response = await http.get(Uri.parse(url));

    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter chart'),
        ),
        body: Center(
          child: FutureBuilder<List<SalesData>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  print('data');
                  return SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      // Chart title
                      title: ChartTitle(text: 'Half yearly sales analysis'),
                      // Enable legend
                      legend: Legend(isVisible: true),
                      // Enable tooltip
                      tooltipBehavior: _tooltipBehavior,
                      trackballBehavior: _trackballBehavior,
                      series: <ChartSeries<SalesData, String>>[
                        LineSeries<SalesData, String>(
                            dataSource: snapshot.data!,
                            xValueMapper: (SalesData sales, _) => sales.month,
                            yValueMapper: (SalesData sales, _) => sales.sales,
                            // Enable data label
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true))
                      ]);
                }
                return Card(
                  elevation: 5.0,
                  child: Container(
                    height: 100,
                    width: 400,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Retriving Firebase data...',
                              style: TextStyle(fontSize: 20.0)),
                          Container(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              semanticsLabel: 'Retriving Firebase data',
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent),
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ));
  }
}

class SalesData {
  SalesData(this.month, this.sales);

  final String month;
  final int sales;

  factory SalesData.fromJson(Map<String, dynamic> parsedJson) {
    return SalesData(
      parsedJson['month'].toString(),
      parsedJson['sales'],
    );
  }
}
