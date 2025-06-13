import 'package:flutter/material.dart';
import 'package:mobile_scanner_example/quiz/survey_question.dart';
import 'package:mobile_scanner_example/quiz/database_helper.dart';

class ResponseAnalysisScreen extends StatefulWidget {
  final String surveyId;

  const ResponseAnalysisScreen({super.key, required this.surveyId});

  @override
  _ResponseAnalysisScreenState createState() => _ResponseAnalysisScreenState();
}

class _ResponseAnalysisScreenState extends State<ResponseAnalysisScreen> {
  List<Question> _questions = [];
  List<Response> _responses = [];
  Map<int, Map<String, dynamic>> _analysis = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final questions = await DatabaseHelper.instance.getQuestions(
      widget.surveyId,
    );
    final responses = await DatabaseHelper.instance.getResponses(
      widget.surveyId,
    );
    final analysis = _calculateAnalysis(questions, responses);
    setState(() {
      _questions = questions;
      _responses = responses;
      _analysis = analysis;
    });
  }

  Map<int, Map<String, dynamic>> _calculateAnalysis(
    List<Question> questions,
    List<Response> responses,
  ) {
    final result = <int, Map<String, dynamic>>{};
    for (var question in questions) {
      final questionResponses =
          responses.where((r) => r.questionId == question.id).toList();
      if (question.type == QuestionType.multipleChoice ||
          question.type == QuestionType.trueFalse) {
        final correctCount =
            questionResponses
                .where(
                  (r) => r.answer == question.correctOptionIndex?.toString(),
                )
                .length;
        final incorrectCount = questionResponses.length - correctCount;
        result[question.id!] = {
          'correct': correctCount,
          'incorrect': incorrectCount,
        };
      } else if (question.type == QuestionType.rating) {
        final ratingCounts = <String, int>{
          '1': 0,
          '2': 0,
          '3': 0,
          '4': 0,
          '5': 0,
        };
        for (var response in questionResponses) {
          ratingCounts[response.answer] =
              (ratingCounts[response.answer] ?? 0) + 1;
        }
        result[question.id!] = {'ratings': ratingCounts};
      } else if (question.type == QuestionType.feedback) {
        result[question.id!] = {
          'responses': questionResponses.map((r) => r.answer).toList(),
        };
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Response Analysis',
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
        child: ListView.builder(
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];
            final analysis = _analysis[question.id!] ?? {};
            return ListTile(
              title: Text(
                'Question: ${question.questionText}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: _buildAnalysisText(question, analysis),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnalysisText(Question question, Map<String, dynamic> analysis) {
    if (question.type == QuestionType.multipleChoice ||
        question.type == QuestionType.trueFalse) {
      return Text(
        'Correct: ${analysis['correct'] ?? 0} | Incorrect: ${analysis['incorrect'] ?? 0}',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (question.type == QuestionType.rating) {
      final ratings = analysis['ratings'] as Map<String, int>;
      return Text(
        'Ratings: 1: ${ratings['1'] ?? 0}, 2: ${ratings['2'] ?? 0}, 3: ${ratings['3'] ?? 0}, '
        '4: ${ratings['4'] ?? 0}, 5: ${ratings['5'] ?? 0}',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      final responses = analysis['responses'] as List<String>;
      return Text(
        'Responses: ${responses.isEmpty ? 'None' : responses.join(', ')}',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }
}
