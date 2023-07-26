import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/constants.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_screen.dart';
import 'package:flutter_login_screen/ui/progress/progress_screen.dart';
import 'package:flutter_login_screen/ui/feedback/feedback_screen.dart';
import 'package:flutter_login_screen/ui/chatbot/chatbot_screen.dart';
import 'package:flutter_login_screen/ui/dietplan/dietplan_screen.dart';
import 'package:flutter_login_screen/ui/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late User user;

  int selectedPage = 0;
  final List _screens=[ProgressScreen(), const DietScreen(), const FeedbackScreen(), const ChatScreen()];

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }


  @override
  Widget build(BuildContext context) {
return DefaultTabController(
  length: 3, // Specify the number of tabs
  child: BlocListener<AuthenticationBloc, AuthenticationState>(
    listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
    },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(colorPrimary),
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Profile',
                  style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900, 
                  ),
                
                ),

                leading: Transform.rotate(
                  angle: 0,
                  child: Icon(
                    Icons.person,
                    color: isDarkMode(context)
                        ? Colors.grey.shade50
                        : Colors.grey.shade900,
                  ),
                ),

                onTap: () { Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen()));
                },               
              ),
              ListTile(
                title: Text(
                  'Logout',
                  style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900),
                ),

                leading: Transform.rotate(
                  angle: pi / 1,
                  child: Icon(
                    Icons.exit_to_app,
                    color: isDarkMode(context)
                        ? Colors.grey.shade50
                        : Colors.grey.shade900,
                  ),
                ),
                onTap: () {
                  context.read<AuthenticationBloc>().add(LogoutEvent());
                },
                
              ),

            ],
          ),
        ),
        appBar: AppBar(
          // title: const Text('Home'),

        ),
        body:  _screens[selectedPage],
        
        bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Diet Plan',
            backgroundColor: Colors.green,

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chatbot',
            backgroundColor: Colors.pink,
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedPage,
          onTap: (currentindex){
            setState(() {
              selectedPage = currentindex;
            });
          },
        selectedItemColor: Colors.blue[700],
        selectedFontSize: 13,
        unselectedFontSize: 13,
        iconSize: 30,
      ),

  ),
  ),
  );
  }
}
