import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_screen/model/user.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _editedUser;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      print('Is Editing: $_isEditing');
    });
  }

  Future<void> _saveChanges() async {
    try {
      // Query for the document based on the email field
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _editedUser.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document found (you might want to add more checks here)
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

        // Update the document with the new data
        await documentSnapshot.reference.update({
          'gender': _editedUser.gender,
          'weight': _editedUser.weight,
          'height': _editedUser.height,
          'medicalHistory': _editedUser.medicalHistory,
          'foodPreferences': _editedUser.foodPreferences,
        });

        setState(() {
          _isEditing = false;
        });
      } else {
        print('Document not found for email: ${_editedUser.email}');
      }
    } catch (error) {
      print('Error updating user data: $error');
      // Handle the error as needed, e.g., show a dialog to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Center(
            child: Text('Profile'),
          ),
          
          leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // This will navigate back to the previous screen (Home Screen).
          },
        ),
        ),
      body: ListView(
        children: <Widget>[
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.deepOrange.shade300],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.5, 0.9],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        minRadius: 60.0,
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: 
                          AssetImage('assets/images/placeholder.jpg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _editedUser.fullName(),
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _editedUser.age.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: !_isEditing
                        ? Text(
                            _editedUser.email,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )
                        : TextFormField(
                            initialValue: _editedUser.email,
                            // Add appropriate onChanged and validator callbacks here
                          ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Gender',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: !_isEditing
                        ? Text(
                            _editedUser.gender,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )
                        : TextFormField(
                            initialValue: _editedUser.gender,
                            onChanged: (newValue) {
                              setState(() {
                                _editedUser.gender = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your gender';
                              }
                              // Add more validation rules as needed
                              return null;
                            },                          
                          ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Weight',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: !_isEditing
                        ? Text(
                            _editedUser.weight.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )
                        : TextFormField(
                            initialValue: _editedUser.weight.toString(),
                            onChanged: (newValue) {
                              setState(() {
                                _editedUser.weight = double.tryParse(newValue) ?? _editedUser.weight;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your weight';
                              }
                              // Add more validation rules as needed
                              return null;
                            },
                          ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Height',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: !_isEditing
                        ? Text(
                            _editedUser.height.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )
                        : TextFormField(
                            initialValue: _editedUser.height.toString(),
                            onChanged: (newValue) {
                              setState(() {
                                _editedUser.height = double.tryParse(newValue) ?? _editedUser.height;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your height';
                              }
                              // Add more validation rules as needed
                              return null;
                            },
                          ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Medical History',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: !_isEditing
                        ? Text(
                            _editedUser.medicalHistory,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )
                        : TextFormField(
                            initialValue: _editedUser.medicalHistory,
                            onChanged: (newValue) {
                              setState(() {
                                _editedUser.medicalHistory = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your medical history';
                              }
                              // Add more validation rules as needed
                              return null;
                            },
                          ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Food Preferences',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: !_isEditing
                        ? Text(
                            _editedUser.foodPreferences,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )
                        : TextFormField(
                            initialValue: _editedUser.foodPreferences,
                            onChanged: (newValue) {
                              setState(() {
                                _editedUser.foodPreferences = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your food preferences';
                              }
                              // Add more validation rules as needed
                              return null;
                            },
                          ),
                  ),
                ],
              ),
            ),

          // Edit button
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),

          // Save button (only in editing mode)
          if (_isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saveChanges,
                  child: const Text('Save'),
                ),
              ],
            ),
        ],
      ),
      )
    );
  }
}
