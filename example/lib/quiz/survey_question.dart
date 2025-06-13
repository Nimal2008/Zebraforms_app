enum QuestionType { multipleChoice, trueFalse, rating, feedback }

class Survey {
  String id;
  String title;

  Survey({required this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  factory Survey.fromMap(Map<String, dynamic> map) {
    return Survey(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
    );
  }
}

class Question {
  int? id;
  String surveyId;
  String questionText;
  QuestionType type;
  List<String>? options; // Null for rating/feedback
  int? correctOptionIndex; // Null for rating/feedback

  Question({
    this.id,
    required this.surveyId,
    required this.questionText,
    required this.type,
    this.options,
    this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surveyId': surveyId,
      'questionText': questionText,
      'type': type.toString().split('.').last,
      'options': options?.join('|'),
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    final optionsRaw = map['options'];
    final type = QuestionType.values.firstWhere(
      (e) => e.toString().split('.').last == map['type'],
      orElse: () => QuestionType.feedback,
    );

    return Question(
      id: map['id'] as int?,
      surveyId: map['surveyId'] as String? ?? '',
      questionText: map['questionText'] as String? ?? '',
      type: type,
      options:
          optionsRaw is String && optionsRaw.isNotEmpty
              ? optionsRaw.split('|')
              : null,
      correctOptionIndex: map['correctOptionIndex'] as int?,
    );
  }
}

class Response {
  int? id;
  String surveyId;
  int questionId;
  String
  answer; // Stores index for multipleChoice/trueFalse, rating, or text for feedback
  String userId;

  Response({
    this.id,
    required this.surveyId,
    required this.questionId,
    required this.answer,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surveyId': surveyId,
      'questionId': questionId,
      'answer': answer,
      'userId': userId,
    };
  }

  factory Response.fromMap(Map<String, dynamic> map) {
    return Response(
      id: map['id'] as int?,
      surveyId: map['surveyId'] as String? ?? '',
      questionId: map['questionId'] as int? ?? 0,
      answer: map['answer'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
    );
  }
}
