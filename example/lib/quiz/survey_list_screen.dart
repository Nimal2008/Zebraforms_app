import 'package:flutter/material.dart';
import 'package:mobile_scanner_example/quiz/survey_question.dart';
import 'package:mobile_scanner_example/quiz/database_helper.dart';
import 'package:mobile_scanner_example/quiz/survey_form_screen.dart';
import 'package:mobile_scanner_example/quiz/take_survey_screen.dart';
import 'package:mobile_scanner_example/quiz/response_analysis_screen.dart';
import 'package:mobile_scanner_example/quiz/scan_survey_screen.dart';

class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({super.key});

  @override
  _SurveyListScreenState createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  List<Survey> _surveys = [];

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    final surveys = await DatabaseHelper.instance.getSurveys();
    setState(() {
      _surveys = surveys;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Surveys',
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
        child:
            _surveys.isEmpty
                ? const Center(child: Text('No surveys created yet.'))
                : ListView.builder(
                  itemCount: _surveys.length,
                  itemBuilder: (context, index) {
                    final survey = _surveys[index];
                    return ListTile(
                      title: Text(survey.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          TakeSurveyScreen(surveyId: survey.id),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.analytics),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ResponseAnalysisScreen(
                                        surveyId: survey.id,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        //childrenšenie
        children: [
          FloatingActionButton(
            heroTag: 'add_survey',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SurveyFormScreen(),
                ),
              );
              _loadSurveys();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'scan_survey',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanSurveyScreen(),
                ),
              );
            },
            child: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }
}
