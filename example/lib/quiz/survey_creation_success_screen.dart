import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SurveyCreationSuccessScreen extends StatelessWidget {
  final String surveyId;

  const SurveyCreationSuccessScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context) {
    final qrData = 'https://survey.app/take?surveyId=$surveyId';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Created', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Survey created successfully! Share this QR code:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              QrImageView(data: qrData, version: QrVersions.auto, size: 200.0),
              const SizedBox(height: 20),
              Text('Survey ID: $surveyId'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
