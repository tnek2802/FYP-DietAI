import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_login_screen/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_login_screen/model/ResponseModel.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
  String jsonResponse = '';


class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController promptController;
  String responseTxt = '';
  late ResponseModel responseModel;

  @override
  void initState() {
    promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343541),
      appBar: AppBar(
        title: const Text(
          'Diet Chatbot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff343541),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        
        children: [
          Expanded(
            child: PromptBldr(responseTxt: responseTxt),
          ),
          TextFormFieldBldr(
            promptController: promptController, btnFun: completionFun),
  
        ],
      ),
    );
  }
  completionFun() async {
    setState(() => responseTxt = 'Loading...');

final response = await http.post(
  Uri.parse('https://api.openai.com/v1/chat/completions'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${dotenv.env['token']}',
  },
  body: jsonEncode(
    {
      "model": "gpt-3.5-turbo", // Use the gpt-3.5-turbo model
      "messages": [
        {
          "role": "system",
          "content": "You are a helpful assistant.", // Add a system message to set the behavior of the assistant
        },
        {
          "role": "user",
          "content": promptController.text, // Use the user's input as the prompt
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
            : 'No response content'; // Provide a default value if choices list is empty
        debugPrint(responseTxt);
      } catch (e) {
        debugPrint('Error while parsing JSON: $e');
        // Handle the error gracefully
      }
    } else {
      debugPrint('API response is null');
      // Handle the case when the API response is null
    }
  });
  }
}


class PromptBldr extends StatelessWidget {
  const PromptBldr(
    {super.key, required this.responseTxt,}
  );

  final String responseTxt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xff434654),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Text(
                    responseTxt,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Other widgets below if needed
      ],
    );
  }
}

class TextFormFieldBldr extends StatelessWidget {
  const TextFormFieldBldr(
    {super.key, required this.promptController, required this.btnFun}
  );

  final TextEditingController promptController;
  final Function btnFun;
 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 1, right:1, bottom: 5),
          child: Row(
            children: [
              Flexible(
                child: TextFormField(
                  cursorColor: Colors.white,
                  controller: promptController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff444653),
                      ),
                      borderRadius: BorderRadius.circular(5.5),
                    ), 
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff444653),
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xff444653),
                    hintText: 'Ask me anything about diet!',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  ),
                ),
                Container(
                  color: const Color(0xff19bc99),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      onPressed: ()=> btnFun(),
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
            ],
          )
        )
    )
    );
  }
}