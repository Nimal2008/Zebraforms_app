// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:uuid/uuid.dart';
// //import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dynamic Form App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const FormCreatorScreen(),
//     );
//   }
// }

// class FormCreatorScreen extends StatefulWidget {
//   const FormCreatorScreen({super.key});

//   @override
//   _FormCreatorScreenState createState() => _FormCreatorScreenState();
// }

// class _FormCreatorScreenState extends State<FormCreatorScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   List<DynamicField> _fields = [];
//   String? _formId;
//   String? _qrCodeData;
//   GlobalKey _qrKey = GlobalKey();

//   void _addField(String type) {
//     setState(() {
//       _fields.add(DynamicField(type: type, options: type == 'multiple' ? ['Option 1', 'Option 2'] : []));
//     });
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate() && _titleController.text.isNotEmpty) {
//       final formId = const Uuid().v4();
//       await FirebaseFirestore.instance.collection('forms').doc(formId).set({
//         'title': _titleController.text,
//         'fields': _fields.map((f) => f.toMap()).toList(),
//         'createdAt': Timestamp.now(),
//       });
//       final qrCodeData = 'https://your-app-url.com/submit/$formId';
//       setState(() {
//         _formId = formId;
//         _qrCodeData = qrCodeData;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Form')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: 'Form Title'),
//                 validator: (value) => value!.isEmpty ? 'Enter a title' : null,
//               ),
//               const SizedBox(height: 20),
//               ..._fields.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 return DynamicFieldWidget(
//                   field: entry.value,
//                   onUpdate: (updatedField) => setState(() => _fields[index] = updatedField),
//                   onDelete: () => setState(() => _fields.removeAt(index)),
//                 );
//               }).toList(),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => _addField('text'),
//                     child: const Text('Add Text Field'),
//                   ),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () => _addField('multiple'),
//                     child: const Text('Add Multiple Choice'),
//                   ),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () => _addField('checkbox'),
//                     child: const Text('Add Checkboxes'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: const Text('Submit Form'),
//               ),
//               if (_qrCodeData != null) ...[
//                 const SizedBox(height: 20),
//                 RepaintBoundary(
//                   key: _qrKey,
//                   child: QrImageView(
//                     data: _qrCodeData!,
//                     version: QrVersions.auto,
//                     size: 200.0,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text('Scan to submit form'),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DynamicField {
//   String type;
//   String? question;
//   List<String> options;

//   DynamicField({required this.type, this.question, this.options = const []});

//   Map<String, dynamic> toMap() => {
//     'type': type,
//     'question': question,
//     'options': options,
//   };
// }

// class DynamicFieldWidget extends StatefulWidget {
//   final DynamicField field;
//   final Function(DynamicField) onUpdate;
//   final VoidCallback onDelete;

//   const DynamicFieldWidget({
//     super.key,
//     required this.field,
//     required this.onUpdate,
//     required this.onDelete,
//   });

//   @override
//   _DynamicFieldWidgetState createState() => _DynamicFieldWidgetState();
// }

// class _DynamicFieldWidgetState extends State<DynamicFieldWidget> {
//   late TextEditingController _questionController;
//   late List<TextEditingController> _optionControllers;

//   @override
//   void initState() {
//     super.initState();
//     _questionController = TextEditingController(text: widget.field.question ?? '');
//     _optionControllers = widget.field.options.map((e) => TextEditingController(text: e)).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _questionController,
//               decoration: const InputDecoration(labelText: 'Question'),
//               onChanged: (value) {
//                 widget.field.question = value;
//                 widget.onUpdate(widget.field);
//               },
//             ),
//             const SizedBox(height: 10),
//             if (widget.field.type == 'multiple')
//               ..._optionControllers.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 return Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: entry.value,
//                         decoration: InputDecoration(labelText: 'Option ${index + 1}'),
//                         onChanged: (value) {
//                           widget.field.options[index] = value;
//                           widget.onUpdate(widget.field);
//                         },
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.remove),
//                       onPressed: () {
//                         setState(() {
//                           _optionControllers.removeAt(index);
//                           widget.field.options.removeAt(index);
//                           widget.onUpdate(widget.field);
//                         });
//                       },
//                     ),
//                   ],
//                 );
//               }).toList(),
//             if (widget.field.type == 'multiple')
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _optionControllers.add(TextEditingController());
//                     widget.field.options.add('');
//                     widget.onUpdate(widget.field);
//                   });
//                 },
//                 child: const Text('Add Option'),
//               ),
//             if (widget.field.type == 'checkbox')
//               ..._optionControllers.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 return Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: entry.value,
//                         decoration: InputDecoration(labelText: 'Option ${index + 1}'),
//                         onChanged: (value) {
//                           widget.field.options[index] = value;
//                           widget.onUpdate(widget.field);
//                         },
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.remove),
//                       onPressed: () {
//                         setState(() {
//                           _optionControllers.removeAt(index);
//                           widget.field.options.removeAt(index);
//                           widget.onUpdate(widget.field);
//                         });
//                       },
//                     ),
//                   ],
//                 );
//               }).toList(),
//             if (widget.field.type == 'checkbox')
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _optionControllers.add(TextEditingController());
//                     widget.field.options.add('');
//                     widget.onUpdate(widget.field);
//                   });
//                 },
//                 child: const Text('Add Option'),
//               ),
//             ElevatedButton(
//               onPressed: widget.onDelete,
//               child: const Text('Delete Field'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _questionController.dispose();
//     for (var controller in _optionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }

// class FormSubmissionScreen extends StatefulWidget {
//   final String formId;

//   const FormSubmissionScreen({super.key, required this.formId});

//   @override
//   _FormSubmissionScreenState createState() => _FormSubmissionScreenState();
// }

// class _FormSubmissionScreenState extends State<FormSubmissionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   Map<String, dynamic> _responses = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadForm();
//   }

//   Future<void> _loadForm() async {
//     final doc = await FirebaseFirestore.instance.collection('forms').doc(widget.formId).get();
//     if (doc.exists) {
//       setState(() {
//         _responses = {for (var field in doc['fields']) field['question'] ?? '': null};
//       });
//     }
//   }

//   Future<void> _submitResponses() async {
//     if (_formKey.currentState!.validate()) {
//       await FirebaseFirestore.instance.collection('responses').add({
//         'formId': widget.formId,
//         'responses': _responses,
//         'timestamp': Timestamp.now(),
//       });
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted!')));
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Submit Form')),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance.collection('forms').doc(widget.formId).get(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           final fields = List<Map<String, dynamic>>.from(data['fields']);
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: ListView(
//                 children: [
//                   Text(data['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 20),
//                   ...fields.map((field) {
//                     if (field['type'] == 'text') {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: TextFormField(
//                           decoration: InputDecoration(labelText: field['question']),
//                           onChanged: (value) => _responses[field['question']!] = value,
//                           validator: (value) => value!.isEmpty ? 'This field is required' : null,
//                         ),
//                       );
//                     } else if (field['type'] == 'multiple') {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(labelText: field['question']),
//                           items: field['options'].map<DropdownMenuItem<String>>((option) {
//                             return DropdownMenuItem<String>(
//                               value: option,
//                               child: Text(option),
//                             );
//                           }).toList(),
//                           onChanged: (value) => _responses[field['question']!] = value,
//                           validator: (value) => value == null ? 'Select an option' : null,
//                         ),
//                       );
//                     } else if (field['type'] == 'checkbox') {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: field['options'].map<Widget>((option) {
//                             return Row(
//                               children: [
//                                 Checkbox(
//                                   value: _responses[field['question']!]?.contains(option) ?? false,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       List<String> current = List.from(_responses[field['question']!] ?? []);
//                                       if (val == true) {
//                                         current.add(option);
//                                       } else {
//                                         current.remove(option);
//                                       }
//                                       _responses[field['question']!!] = current;
//                                     });
//                                   },
//                                 ),
//                                 Text(option),
//                               ],
//                             );
//                           }).toList(),
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   }).toList(),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _submitResponses,
//                     child: const Text('Submit'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class QRScannerScreen extends StatefulWidget {
//   const QRScannerScreen({super.key});

//   @override
//   _QRScannerScreenState createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   final MobileScannerController _controller = MobileScannerController();
//   String? _scannedData;

//   void _handleBarcode(BarcodeCapture barcodes) {
//     if (mounted) {
//       setState(() {
//         _scannedData = barcodes.barcodes.first.displayValue;
//       });
//       _controller.stop();
//       if (_scannedData != null && _scannedData!.startsWith('https://your-app-url.com/submit/')) {
//         final formId = _scannedData!.split('/').last;
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FormSubmissionScreen(formId: formId)),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan QR Code')),
//       body: Column(
//         children: [
//           Expanded(
//             child: MobileScanner(
//               controller: _controller,
//               onDetect: _handleBarcode,
//             ),
//           ),
//           if (_scannedData != null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text('Scanned: $_scannedData'),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
