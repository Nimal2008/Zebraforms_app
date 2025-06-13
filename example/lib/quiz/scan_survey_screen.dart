import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner_example/quiz/take_survey_screen.dart';
import 'package:mobile_scanner_example/quiz/database_helper.dart';

class ScanSurveyScreen extends StatefulWidget {
  const ScanSurveyScreen({super.key});

  @override
  _ScanSurveyScreenState createState() => _ScanSurveyScreenState();
}

class _ScanSurveyScreenState extends State<ScanSurveyScreen> {
  MobileScannerController controller = MobileScannerController();
  final TextEditingController _surveyIdController = TextEditingController();
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    _surveyIdController.dispose();
    super.dispose();
  }

  Future<void> _validateAndNavigate(String surveyId) async {
    final surveys = await DatabaseHelper.instance.getSurveys();
    if (surveys.any((survey) => survey.id == surveyId)) {
      await controller.stop();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakeSurveyScreen(surveyId: surveyId),
        ),
      );
      if (_isScanning) {
        await controller.start();
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid Survey ID')));
    }
  }

  void _toggleScanMode() {
    setState(() {
      _isScanning = !_isScanning;
    });
    if (_isScanning) {
      controller.start();
    } else {
      controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan or Enter Survey ID'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          if (_isScanning)
            Expanded(
              flex: 5,
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) async {
                  final code = capture.barcodes.first.rawValue;
                  if (code != null &&
                      code.startsWith('https://survey.app/take?surveyId=')) {
                    final surveyId = code.split('surveyId=')[1];
                    await _validateAndNavigate(surveyId);
                  }
                },
              ),
            ),
          if (!_isScanning)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _surveyIdController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Survey ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          () => _validateAndNavigate(_surveyIdController.text),
                      child: const Text('Submit Survey ID'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: _toggleScanMode,
                child: Text(
                  _isScanning ? 'Enter Survey ID Manually' : 'Scan QR Code',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
