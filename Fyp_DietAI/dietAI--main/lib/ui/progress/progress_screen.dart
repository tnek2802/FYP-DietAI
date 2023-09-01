import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  final User user; // Pass the User model to the ProgressScreen

  ProgressScreen({required this.user});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserProgress> userProgressData = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> recordUserProgress(double muscleMass, double fatPercentage) async {
    double bmi = calculateBMI(widget.user.height, widget.user.weight);
    double bmr = calculateBMR(widget.user.weight, widget.user.height, widget.user.age, widget.user.gender);

    DateTime currentDate = DateTime.now();

    UserProgress progress = UserProgress(
      date: currentDate,
      bmi: bmi,
      bmr: bmr,
      muscleMass: muscleMass,
      fatPercentage: fatPercentage,
      email: widget.user.email,
    );

    await FirebaseFirestore.instance.collection('userProgress').add({
      'date': progress.date,
      'bmi': progress.bmi,
      'bmr': progress.bmr,
      'muscleMass': progress.muscleMass,
      'fatPercentage': progress.fatPercentage,
      'email': progress.email,
    });

    setState(() {
      userProgressData.add(progress);
    });
  }

  Future<void> _showInputDialog(BuildContext context) async {
    double fatMass = 0.0; // Initialize fat mass
    double leanMass = 0.0; // Initialize lean mass
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your Latest Health Data'),
          content: Form(
            key: _formKey, // Create a GlobalKey<FormState> in your State
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat Mass (kg)',
                    hintText: 'Enter fat mass (5 - 100 kg)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    double? fatMassInput = double.tryParse(value);
                    if (fatMassInput == null || fatMassInput < 5 || fatMassInput > 100) {
                      return 'Please enter a value between 5 and 100.';
                    }
                    return null; // Validation passed
                  },
                  onChanged: (value) => fatMass = double.tryParse(value) ?? 0.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Lean Mass (kg)',
                    hintText: 'Enter lean mass (20 - 150 kg)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    double? leanMassInput = double.tryParse(value);
                    if (leanMassInput == null || leanMassInput < 20 || leanMassInput > 150) {
                      return 'Please enter a value between 20 and 150.';
                    }
                    return null; // Validation passed
                  },
                  onChanged: (value) => leanMass = double.tryParse(value) ?? 0.0,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  double fatPercentage = calculateFatPercentage(widget.user.weight, fatMass);
                  double muscleMass = calculateMuscleMass(widget.user.weight, fatMass, leanMass);
                  recordUserProgress(muscleMass, fatPercentage);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'BMI'),
            Tab(text: 'BMR'),
            Tab(text: 'Muscle & Fat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProgressTabContent(dataStream: getUserProgressStream('BMI'), dataType: 'BMI', measureFn: (UserProgress series) => series.bmi),
          ProgressTabContent(dataStream: getUserProgressStream('BMR'), dataType: 'BMR', measureFn: (UserProgress series) => series.bmr),
          ProgressTabContent(dataStream: getUserProgressStream('Muscle & Fat'), dataType: 'Muscle & Fat', measureFn: (UserProgress series) => series.muscleMass + series.fatPercentage),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInputDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  Stream<List<UserProgress>> getUserProgressStream(String dataType) {
    return FirebaseFirestore.instance
        .collection('userProgress')
        .where('email', isEqualTo: widget.user.email)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserProgress(
              date: doc['date'].toDate(),
              bmi: doc['bmi'],
              bmr: doc['bmr'],
              muscleMass: doc['muscleMass'],
              fatPercentage: doc['fatPercentage'],
              email: doc['email'],
            )).toList());
  }

}
class ProgressTabContent extends StatelessWidget {
  final String dataType;
  final Stream<List<UserProgress>> dataStream; // Use a Stream instead of List
  final num Function(UserProgress series) measureFn; // Updated type

  const ProgressTabContent({
    Key? key,
    required this.dataType,
    required this.dataStream,
    required this.measureFn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<UserProgress>>(
      
      stream: dataStream, // Use the provided dataStream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        }

        final data = snapshot.data ?? [];
        // Calculate levels for the current progress data
        String bmiLevel = indicateLevel(data.last.bmi, [18.5, 23, 27.6], ['Underweight', 'Normal', 'Overweight', 'Obese']);
        String bmrLevel = indicateLevel(data.last.bmr, [1500, 2000, 2500], ['Low', 'Normal', 'High']);
        String muscleFatLevel = indicateLevel(data.last.muscleMass + data.last.fatPercentage, [50, 60, 70], ['Low', 'Normal', 'High']);
        List<charts.Series<UserProgress, String>> series = [
          charts.Series(
            id: "Progress",
            data: data,
            domainFn: (UserProgress series, _) => DateFormat('dd MMM').format(series.date),
            measureFn: (UserProgress series, _) => measureFn(series),
            colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.green),
            labelAccessorFn: (UserProgress series, _) =>
                '${measureFn(series).toStringAsFixed(2)}', // Display numeric value on top of bars
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
                    "$dataType Progress",
                  ),
                  Expanded(
                    child: charts.BarChart(
                      series,
                      animate: true,
                      domainAxis: const charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            color: charts.ColorUtil.fromDartColor(Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "\nSuccess is not final, failure is not fatal: it is the courage to continue that counts. - Winston Churchill.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("Current health level:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  Text("BMI Level: $bmiLevel"),
                  Text("BMR Level: $bmrLevel"),
                  Text("Muscle & Fat Level: $muscleFatLevel"),
                  Divider(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class UserProgress {
  final DateTime date;
  final double bmi;
  final double bmr;
  final double muscleMass;
  final double fatPercentage;
  final String email;

  UserProgress({
    required this.date,
    required this.bmi,
    required this.bmr,
    required this.muscleMass,
    required this.fatPercentage,
    required this.email,
  });
}

double calculateBMI(double heightInCM, double weightInKG) {
  // BMI Formula: weight (kg) / (height (m))^2
  double heightInM = heightInCM / 100.0;
  double bmi = weightInKG / (heightInM * heightInM);
  return bmi;
}

double calculateBMR(double weightInKG, double heightInCM, int age, String gender) {
  if (gender == 'Male') {
    // BMR Formula for males: 10 * weight (kg) + 6.25 * height (cm) - 5 * age + 5
    return 10 * weightInKG + 6.25 * heightInCM - 5 * age + 5;
  } else {
    // BMR Formula for females: 10 * weight (kg) + 6.25 * height (cm) - 5 * age - 161
    return 10 * weightInKG + 6.25 * heightInCM - 5 * age - 161;
  }
}

double calculateFatPercentage(double weightInKG, double fatMass) {
  return (fatMass / weightInKG) * 100;
}

double calculateMuscleMass(double weightInKG, double fatMass, double leanMass) {
  return weightInKG - fatMass - leanMass;
}

String indicateLevel(double value, List<double> ranges, List<String> labels) {
  for (int i = 0; i < ranges.length; i++) {
    if (value < ranges[i]) {
      return labels[i];
    }
  }
  return labels.last;
}
