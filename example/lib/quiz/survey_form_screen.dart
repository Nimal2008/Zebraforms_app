import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner_example/quiz/survey_question.dart';
import 'package:mobile_scanner_example/quiz/database_helper.dart';
import 'package:mobile_scanner_example/quiz/survey_creation_success_screen.dart';

class SurveyFormScreen extends StatefulWidget {
  const SurveyFormScreen({super.key});

  @override
  _SurveyFormScreenState createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  QuestionType _questionType = QuestionType.multipleChoice;
  int _correctOptionIndex = 0;
  final List<Question> _questions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    if (_formKey.currentState!.validate()) {
      Question question;
      if (_questionType == QuestionType.multipleChoice) {
        question = Question(
          surveyId: '',
          questionText: _questionController.text,
          type: _questionType,
          options: _optionControllers.map((c) => c.text).toList(),
          correctOptionIndex: _correctOptionIndex,
        );
      } else if (_questionType == QuestionType.trueFalse) {
        question = Question(
          surveyId: '',
          questionText: _questionController.text,
          type: _questionType,
          options: ['True', 'False'],
          correctOptionIndex: _correctOptionIndex,
        );
      } else {
        question = Question(
          surveyId: '',
          questionText: _questionController.text,
          type: _questionType,
        );
      }
      setState(() {
        _questions.add(question);
        _questionController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        _correctOptionIndex = 0;
        _questionType = QuestionType.multipleChoice;
      });
    }
  }

  void _submitSurvey() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question')),
      );
      return;
    }
    final surveyId = const Uuid().v4();
    final survey = Survey(id: surveyId, title: _titleController.text);
    await DatabaseHelper.instance.insertSurvey(survey);
    for (var question in _questions) {
      question.surveyId = surveyId;
      await DatabaseHelper.instance.insertQuestion(question);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyCreationSuccessScreen(surveyId: surveyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Survey',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Survey Title'),
                  validator:
                      (value) => value!.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<QuestionType>(
                  value: _questionType,
                  decoration: const InputDecoration(labelText: 'Question Type'),
                  items:
                      QuestionType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _questionType = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter a question' : null,
                ),
                if (_questionType == QuestionType.multipleChoice) ...[
                  ...List.generate(
                    4,
                    (index) => TextFormField(
                      controller: _optionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter option ${index + 1}'
                                  : null,
                    ),
                  ),
                  DropdownButtonFormField<int>(
                    value: _correctOptionIndex,
                    decoration: const InputDecoration(
                      labelText: 'Correct Option',
                    ),
                    items: List.generate(
                      4,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text('Option ${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value!;
                      });
                    },
                  ),
                ],
                if (_questionType == QuestionType.trueFalse)
                  DropdownButtonFormField<int>(
                    value: _correctOptionIndex,
                    decoration: const InputDecoration(
                      labelText: 'Correct Answer',
                    ),
                    items: [
                      const DropdownMenuItem(value: 0, child: Text('True')),
                      const DropdownMenuItem(value: 1, child: Text('False')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value!;
                      });
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addQuestion,
                  child: const Text('Add Question'),
                ),
                const SizedBox(height: 20),
                Text('${_questions.length} question(s) added'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitSurvey,
                  child: const Text('Submit Survey'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
