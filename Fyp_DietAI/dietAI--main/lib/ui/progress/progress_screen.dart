import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_login_screen/ui/progress/progress_series.dart';
 

class ProgressSeries {
  final String year;
  final int developers;
  final charts.Color barColor;

  ProgressSeries({required this.year, required this.developers, required this.barColor});
}

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Level Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BMITabContent(data: getData(), tabType: 'Day'),
          BMITabContent(data: getData(), tabType: 'Week'),
          BMITabContent(data: getData(), tabType: 'Month'),
        ],
      ),
    );
  }

  List<ProgressSeries> getData() {
    return [
      ProgressSeries(
        year: "2017",
        developers: 40000,
        barColor: charts.ColorUtil.fromDartColor(Colors.green),
      ),
      ProgressSeries(
        year: "2018",
        developers: 50000,
        barColor: charts.ColorUtil.fromDartColor(Colors.green),
      ),
      ProgressSeries(
        year: "2019",
        developers: 40000,
        barColor: charts.ColorUtil.fromDartColor(Colors.green),
      ),
      ProgressSeries(
        year: "2020",
        developers: 35000,
        barColor: charts.ColorUtil.fromDartColor(Colors.green),
      ),
      ProgressSeries(
        year: "2021",
        developers: 45000,
        barColor: charts.ColorUtil.fromDartColor(Colors.green),
      ),
    ];
  }
}

class BMITabContent extends StatelessWidget {
  final String tabType;
  final List<ProgressSeries> data;

  const BMITabContent({super.key, required this.tabType, required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ProgressSeries, String>> series = [
      charts.Series(
        id: "Progress",
        data: data,
        domainFn: (ProgressSeries series, _) => series.year,
        measureFn: (ProgressSeries series, _) => series.developers,
        colorFn: (ProgressSeries series, _) => series.barColor,
      ),
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(25),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            children: <Widget>[
              Text(
                "BMI Level Progress ($tabType)",
              ),
              Expanded(
                child: charts.BarChart(series, animate: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}