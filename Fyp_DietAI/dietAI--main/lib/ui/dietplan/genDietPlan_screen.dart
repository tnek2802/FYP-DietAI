import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/ui/progress/progress_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_login_screen/model/ResponseModel.dart'; // Adjust the path as needed
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneratedDietPlanScreen extends StatefulWidget {
  final String selectedGoal;
  final User user;

  GeneratedDietPlanScreen({required this.selectedGoal, required this.user});

  @override
  _GeneratedDietPlanScreenState createState() => _GeneratedDietPlanScreenState();
}

class _GeneratedDietPlanScreenState extends State<GeneratedDietPlanScreen> {
  late final TextEditingController promptController;
  String responseTxt = '';
  late ResponseModel responseModel;
  String selectedGoal = '';
  bool isTextFieldVisible = false; // Add a variable to control visibility

  Stream<List<UserProgress>>? userProgressStream;

  @override
  void initState() {
    promptController = TextEditingController();
    selectedGoal = widget.selectedGoal;
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  completionFun() async {
    setState(() => responseTxt = 'Loading...');
    final userProgress = await getUserLatestProgressStream(widget.user.email).first;
    final promptContent = 'Please help create a $selectedGoal diet plan that consist of breakfast, lunch and dinner only keep it short and simple without any chatgpt guideline and please provide an estimated calorie for each meal. My personal health information is age: ${widget.user.age}, gender: ${widget.user.gender}, BMI: ${userProgress?.bmi ?? 'N/A'}, BMR: ${userProgress?.bmr ?? 'N/A'}, Fat Percentage: ${userProgress?.fatPercentage ?? 'N/A'}, Muscle Mass: ${userProgress?.muscleMass ?? 'N/A'}';
    promptController.text = promptContent;

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['token']}',
      },
      body: jsonEncode(
        {
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": "Generate a diet plan for goal: $selectedGoal",
            },
            {
              "role": "user",
              "content": promptController.text,
            },
          ],
          "max_tokens": 500,
          "temperature": 0,
          "top_p": 1,
        },
      ),
    );

    setState(() {
      if (response.statusCode == 200 && response.body != null) {
        try {
          Map<String, dynamic> jsonMap = json.decode(response.body);
          ResponseModel responseModel = ResponseModel.fromJson(jsonMap);
          responseTxt = responseModel.choices.isNotEmpty
              ? responseModel.choices[0].message.content
              : 'No response content';
          debugPrint(responseTxt);
        } catch (e) {
          debugPrint('Error while parsing JSON: $e');
        }
      } else {
        debugPrint('API response is null');
      }
      isTextFieldVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Diet Plan'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Generate Diet Plan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                selectedGoal
              ),
              SizedBox(height: 20),
              StreamBuilder<UserProgress?>(
                stream: getUserLatestProgressStream(widget.user.email),
                builder: (context, snapshot) {
                  final userProgress = snapshot.data;
                  if (userProgress != null) {
                    return const Text(
                        ' ',
                        style: TextStyle(fontSize: 18),
                    );
                  } else {
                    return Text('No progress data detected.');
                  }
                },            
              ),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: completionFun,
                child: const Text('Get Diet Plan'),
              ),
              const SizedBox(height: 20),
              // Display the generated diet plan based on the chatbot response
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Text(
                    responseTxt,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Stream<UserProgress?> getUserLatestProgressStream(String email) {
  return FirebaseFirestore.instance
      .collection('userProgress')
      .where('email', isEqualTo: email)
      .orderBy('date', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs[0];
          return UserProgress(
            date: doc['date'].toDate(),
            bmi: doc['bmi'],
            bmr: doc['bmr'],
            muscleMass: doc['muscleMass'],
            fatPercentage: doc['fatPercentage'],
            email: doc['email'],
          );
        } else {
          return null; // Return null if no progress found
        }
      });
}
