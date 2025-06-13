import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner_example/quiz/survey_question.dart';
import 'package:mobile_scanner_example/quiz/database_helper.dart';

class TakeSurveyScreen extends StatefulWidget {
  final String surveyId;

  const TakeSurveyScreen({super.key, required this.surveyId});

  @override
  _TakeSurveyScreenState createState() => _TakeSurveyScreenState();
}

class _TakeSurveyScreenState extends State<TakeSurveyScreen> {
  List<Question> _questions = [];
  List<String> _answers = [];
  int _currentQuestionIndex = 0;
  final String _userId = const Uuid().v4();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await DatabaseHelper.instance.getQuestions(
      widget.surveyId,
    );
    setState(() {
      _questions = questions;
      _answers = List.filled(questions.length, '');
    });
  }

  void _submitSurvey() async {
    if (_answers.every((answer) => answer.isNotEmpty)) {
      for (var i = 0; i < _questions.length; i++) {
        final response = Response(
          surveyId: widget.surveyId,
          questionId: _questions[i].id!,
          answer: _answers[i],
          userId: _userId,
        );
        await DatabaseHelper.instance.insertResponse(response);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Survey answers submitted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Take Survey',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}: ${question.questionText}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (question.type == QuestionType.multipleChoice ||
                  question.type == QuestionType.trueFalse) ...[
                ...List.generate(
                  question.options!.length,
                  (index) => RadioListTile<String>(
                    title: Text(question.options![index]),
                    value: index.toString(),
                    groupValue: _answers[_currentQuestionIndex],
                    onChanged: (value) {
                      setState(() {
                        _answers[_currentQuestionIndex] = value!;
                      });
                    },
                  ),
                ),
              ],
              if (question.type == QuestionType.rating) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index <
                                int.parse(
                                  _answers[_currentQuestionIndex].isEmpty
                                      ? '0'
                                      : _answers[_currentQuestionIndex],
                                )
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.yellow,
                      ),
                      onPressed: () {
                        setState(() {
                          _answers[_currentQuestionIndex] =
                              (index + 1).toString();
                        });
                      },
                    ),
                  ),
                ),
              ],
              if (question.type == QuestionType.feedback)
                TextField(
                  controller: _feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Your Feedback',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onChanged: (value) {
                    _answers[_currentQuestionIndex] = value;
                  },
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                          _feedbackController.text =
                              _answers[_currentQuestionIndex];
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  if (_currentQuestionIndex < _questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        if (_answers[_currentQuestionIndex].isNotEmpty) {
                          setState(() {
                            _currentQuestionIndex++;
                            _feedbackController.text =
                                _answers[_currentQuestionIndex];
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please provide an answer'),
                            ),
                          );
                        }
                      },
                      child: const Text('Next'),
                    ),
                  if (_currentQuestionIndex == _questions.length - 1)
                    ElevatedButton(
                      onPressed: _submitSurvey,
                      child: const Text('Submit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
