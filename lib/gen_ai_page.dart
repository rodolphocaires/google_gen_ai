import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GenAIPage extends StatefulWidget {
  const GenAIPage({super.key});

  @override
  State<GenAIPage> createState() => _GenAIPageState();
}

class _GenAIPageState extends State<GenAIPage> {
  final TextEditingController textEditingController = TextEditingController();
  late String? apiKey;
  late GenerativeModel model;
  bool isLoading = false;
  String aiResponse = '';

  @override
  void initState() {
    super.initState();
    apiKey = const String.fromEnvironment('API_KEY');
    if (apiKey == null) {
      if (kDebugMode) {
        print('No \$API_KEY environment variable');
      }
      return;
    }
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
  }

  Future<void> _generate() async {
    setState(() {
      isLoading = true;
    });
    final content = [Content.text(textEditingController.text)];
    final response = await model.generateContent(content);
    if (response.text != null) {
      setState(() {
        aiResponse = response.text!;
        isLoading = false;
      });
      textEditingController.clear();
    }
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AI'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: <Widget>[
                  TextField(
                    cursorColor: Colors.pinkAccent,
                    cursorWidth: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter you input',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    controller: textEditingController,
                    onSubmitted: (value) async => await _generate(),
                  ),
                  isLoading
                      ? const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.pinkAccent,
                            ),
                          ),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Text(aiResponse),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : () async => await _generate(),
                      child: isLoading
                          ? const Text('Working on it...')
                          : const Text('Generate'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
