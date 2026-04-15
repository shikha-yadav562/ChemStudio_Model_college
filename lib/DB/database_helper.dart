import 'dart:io';
import 'package:chemstudio/models/group_status.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = 'chemstudio.db';
  static const _dbVersion = 2;

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final tables = [
      'SaltA_DryTest',
      'SaltA_PreliminaryTest',
      'SaltB_DryTest',
      'SaltB_PreliminaryTest',
      'SaltC_DryTest',
      'SaltC_PreliminaryTest',
      'SaltD_DryTest',
      'SaltD_PreliminaryTest',
      'SaltA_WetTest',
      'SaltB_WetTest',
      'SaltC_WetTest',
      'SaltD_WetTest',
    ];

    for (var table in tables) {
      await db.execute('''
        CREATE TABLE $table (
          question_id INTEGER PRIMARY KEY,
          student_answer TEXT,
          correct_answer TEXT
        )
      ''');
    }

    // Group decisions table
    await db.execute('''
      CREATE TABLE WetTestGroups (
        salt TEXT NOT NULL,
        group_number INTEGER NOT NULL,
        student_status TEXT NOT NULL,
        PRIMARY KEY (salt, group_number)
      )
    ''');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final tables = [
        'SaltA_DryTest',
        'SaltA_PreliminaryTest',
        'SaltB_DryTest',
        'SaltB_PreliminaryTest',
        'SaltC_DryTest',
        'SaltC_PreliminaryTest',
        'SaltD_DryTest',
        'SaltD_PreliminaryTest',
        'SaltA_WetTest',
        'SaltB_WetTest',
        'SaltC_WetTest',
        'SaltD_WetTest',
      ];

      for (var table in tables) {
        await db.execute('DROP TABLE IF EXISTS $table');
      }

      await _onCreate(db, newVersion);
    }
  }

  // Save correct answer using UPDATE or INSERT
  Future<void> saveCorrectAnswer(
    String tableName,
    int questionId,
    String correctAnswer,
  ) async {
    final db = await database;

    final existing = await db.query(
      tableName,
      where: 'question_id = ?',
      whereArgs: [questionId],
    );

    if (existing.isEmpty) {
      await db.insert(tableName, {
        'question_id': questionId,
        'correct_answer': correctAnswer,
      });
    } else {
      await db.update(
        tableName,
        {'correct_answer': correctAnswer},
        where: 'question_id = ?',
        whereArgs: [questionId],
      );
    }
  }

  // Save student answer using UPDATE or INSERT
  Future<void> saveStudentAnswer(
    String tableName,
    int questionId,
    String studentAnswer,
  ) async {
    final db = await database;

    final existing = await db.query(
      tableName,
      where: 'question_id = ?',
      whereArgs: [questionId],
    );

    if (existing.isEmpty) {
      await db.insert(tableName, {
        'question_id': questionId,
        'student_answer': studentAnswer,
      });
    } else {
      await db.update(
        tableName,
        {'student_answer': studentAnswer},
        where: 'question_id = ?',
        whereArgs: [questionId],
      );
    }
  }

  // Get student answer
  Future<String?> getStudentAnswer(String tableName, int questionId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      columns: ['student_answer'],
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
    if (result.isNotEmpty) return result.first['student_answer'] as String?;
    return null;
  }

  // Get correct answer
  Future<String?> getCorrectAnswer(String tableName, int questionId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      columns: ['correct_answer'],
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
    if (result.isNotEmpty) return result.first['correct_answer'] as String?;
    return null;
  }

  // Get all answers (for review or final result)
  Future<List<Map<String, dynamic>>> getAnswers(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  // ----------------------
  // Wet Test Group Decision Logic

  /// Save student's decision for a group
  /// Converts GroupStatus enum to string for storage
  Future<void> insertGroupDecision({
    required String salt,
    required int groupNumber,
    required GroupStatus status,
  }) async {
    final db = await database;
    await db.insert('WetTestGroups', {
      'salt': salt,
      'group_number': groupNumber,
      'student_status': status.name, // Stores 'present' or 'absent'
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Read all group decisions for a salt
  /// Converts string from database back to GroupStatus enum
  Future<Map<int, GroupStatus>> getStudentGroupDecisions(String salt) async {
    final db = await database;

    final result = await db.query(
      'WetTestGroups',
      where: 'salt = ?',
      whereArgs: [salt],
    );

    Map<int, GroupStatus> groupStatuses = {};

    for (final row in result) {
      final groupNumber = row['group_number'] as int;
      final statusString = row['student_status'] as String;

      // Convert string back to enum
      // Using byName which throws if not found, or use a safer approach:
      GroupStatus status;
      try {
        status = GroupStatus.values.byName(statusString);
      } catch (e) {
        print(
          'Warning: Invalid status "$statusString" for group $groupNumber, defaulting to absent',
        );
        status = GroupStatus.absent;
      }

      groupStatuses[groupNumber] = status;
    }

    return groupStatuses;
  }

  // ----------------------
  // Clear specific test table
  Future<void> clearTest(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  // Clear all answers
  Future<void> clearAllAnswers() async {
    final db = await database;
    final tables = [
      'SaltA_DryTest',
      'SaltA_PreliminaryTest',
      'SaltB_DryTest',
      'SaltB_PreliminaryTest',
      'SaltC_DryTest',
      'SaltC_PreliminaryTest',
      'SaltD_DryTest',
      'SaltD_PreliminaryTest',
      'SaltA_WetTest',
      'SaltB_WetTest',
      'SaltC_WetTest',
      'SaltD_WetTest',
      'WetTestGroups',
    ];
    for (var table in tables) {
      await db.delete(table);
    }
  }

  // Reset database completely
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = null;
  }

  // ----------------------
  // Export database
  Future<void> exportDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final sourcePath = join(dbPath, _dbName);
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        print('❌ Database file not found at: $sourcePath');
        return;
      }

      String targetPath;

      if (Platform.isAndroid) {
        targetPath = "/storage/emulated/0/Download/$_dbName";
      } else if (Platform.isWindows) {
        final downloads = "${Platform.environment['USERPROFILE']}\\Downloads";
        targetPath = "$downloads\\$_dbName";
      } else if (Platform.isMacOS || Platform.isLinux) {
        final home = Platform.environment['HOME'];
        targetPath = "$home/Downloads/$_dbName";
      } else {
        throw Exception("❌ Unsupported platform");
      }

      await sourceFile.copy(targetPath);
      print("✅ Database successfully exported to: $targetPath");
    } catch (e) {
      print("❌ Error exporting database: $e");
    }
  }
}
