import 'package:flutter/material.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'genDietPlan_screen.dart';

class DietScreen extends StatelessWidget {
  final User user;
  const DietScreen({required this.user, Key? key}) : super(key: key);
   
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Diet Plan';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body:  MyCustomForm(user: user),
      ),
    );
  }
}

// Create a Form widget.
// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  final User user; // Add user property
  MyCustomForm({required this.user, Key? key}) : super(key: key);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '\nGenerate your personalized diet plan!\n\nSet your goal:\n\n',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
            textAlign: TextAlign.center,
          ),
          
          DropdownButtonFormField<String>(
            value: _selectedOption,
            onChanged: (String? newValue) {
              setState(() {
                _selectedOption = newValue;
              });
            },
            items: <String>['Losing Weight', 'Maintaining Weight', 'Gaining Weight']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: const InputDecoration(
              hintText: 'Select your goal', // Placeholder text for the field
              labelText: 'Goal', // Label text for the field
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // Navigate to the GeneratedDietPlanScreen with the selected goal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeneratedDietPlanScreen(selectedGoal: _selectedOption!, user: widget.user),
                    ),
                  );
                }                  

              },
              child: const Text('Generate',
              ),
            ),
          ),
        ],
      ),
    );
  }
}