import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mobile_scanner_example/quiz/survey_question.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('survey.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE surveys (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL
)
''');
    await db.execute('''
CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  surveyId TEXT NOT NULL,
  questionText TEXT NOT NULL,
  type TEXT NOT NULL,
  options TEXT,
  correctOptionIndex INTEGER,
  FOREIGN KEY (surveyId) REFERENCES surveys(id)
)
''');
    await db.execute('''
CREATE TABLE responses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  surveyId TEXT NOT NULL,
  questionId INTEGER NOT NULL,
  answer TEXT NOT NULL,
  userId TEXT NOT NULL,
  FOREIGN KEY (surveyId) REFERENCES surveys(id),
  FOREIGN KEY (questionId) REFERENCES questions(id)
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS responses');
      await db.execute('DROP TABLE IF EXISTS questions');
      await db.execute('DROP TABLE IF EXISTS surveys');
      await _createDB(db, newVersion);
    }
  }

  Future<void> insertSurvey(Survey survey) async {
    final db = await database;
    await db.insert(
      'surveys',
      survey.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertQuestion(Question question) async {
    final db = await database;
    await db.insert(
      'questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertResponse(Response response) async {
    final db = await database;
    await db.insert(
      'responses',
      response.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Survey>> getSurveys() async {
    final db = await database;
    final maps = await db.query('surveys');
    return List.generate(maps.length, (i) => Survey.fromMap(maps[i]));
  }

  Future<List<Question>> getQuestions(String surveyId) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'surveyId = ?',
      whereArgs: [surveyId],
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<List<Response>> getResponses(String surveyId) async {
    final db = await database;
    final maps = await db.query(
      'responses',
      where: 'surveyId = ?',
      whereArgs: [surveyId],
    );
    return List.generate(maps.length, (i) => Response.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'survey.db');
    await deleteDatabase(path);
    _database = null;
  }
}
