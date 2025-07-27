import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myapp/data/bill.dart';
import 'package:myapp/server/backend.dart';
import 'firebase_options.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DropdownProvider(),
      child: MaterialApp(
        title: 'Gemini Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ChatScreen(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

class DropdownProvider with ChangeNotifier {
  String _selectedModel = 'gemini-1.5-flash';

  String get selectedModel => _selectedModel;

  void changeModel(String newModel) {
    _selectedModel = newModel;
    notifyListeners();
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.text, required this.sender});

  final String text;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: Text(sender[0])),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(sender, style: Theme.of(context).textTheme.titleMedium),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<Content> geminiMessages = [];

  List<BillData> _list = [];

  @override
  void initState() {
    super.initState();

    fetchReceipts();
  }

  void fetchReceipts() async {
    EasyLoading.show(status: 'loading...');
    var resList = await Server().getAllReceipts();
    setState(() {
      _list = resList;
    });

    String listBill = "";

    for (var bill in _list) {
      listBill += jsonEncode(bill.toJson());
    }

    geminiMessages.add(Content.text(
      "You are an intelligent assistant."
      "Below is a list of invoice records in JSON format."
      "Each record includes: file name, billing name, billing date, category, items, and total."
      "Based on this data, answer the user query accurately."
      "here is the receipt history: $listBill"
      "Don't answer anything off topic."
    ));
    EasyLoading.dismiss();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(text: text, sender: 'user');
    setState(() {
      _messages.insert(0, message);
    });
    // Use the selected model from the provider
    final selectedModel = Provider.of<DropdownProvider>(
      context,
      listen: false,
    ).selectedModel;
    _getGeminiResponse(text, selectedModel);
  }

  void _getGeminiResponse(String prompt, String modelName) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(model: modelName);

      geminiMessages.add(
        Content.text(
          "user prompt: $prompt",
        ),
      );
      final response = await model.generateContent(geminiMessages);

      geminiMessages.add(response.candidates[0].content);

      ChatMessage geminiResponse = ChatMessage(
        text:
            response.text ??
            'No response from model.', // Handle potential null response
        sender: 'gemini',
      );
      setState(() {
        _messages.insert(0, geminiResponse);
      });
    } catch (e) {
      // Handle errors, e.g., display an error message
      ChatMessage errorResponse = ChatMessage(
        text: 'Error fetching response: $e',
        sender: 'gemini',
      );
      setState(() {
        _messages.insert(0, errorResponse);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat'),
        actions: [
          Consumer<DropdownProvider>(
            builder: (context, dropdownProvider, child) {
              return DropdownButton<String>(
                value: dropdownProvider.selectedModel,
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                ), // Set icon color to white
                elevation: 16,
                style: const TextStyle(
                  color: Colors.white,
                ), // Set text style to white
                underline: Container(height: 2, color: Colors.white),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    dropdownProvider.changeModel(newValue);
                  }
                },
                items:
                    <String>[
                          'gemini-1.5-flash',
                          'gemini-2.5-flash',
                          'gemini-1.5-pro',
                        ] // Gemini models
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.blue),
                            ), // Set item text color to blue
                          );
                        })
                        .toList(),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(), // Add the drawer here
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
