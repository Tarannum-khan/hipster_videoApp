import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class UserService {
  static const String _baseUrl = 'https://reqres.in/api';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id TEXT PRIMARY KEY, email TEXT, first_name TEXT, last_name TEXT, avatar TEXT, isOnline INTEGER)',
        );
      },
    );
  }

  Future<List<User>> fetchUsers() async {
    try {
      // Try to fetch from API (combine multiple pages for a larger list)
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/users?page=1&per_page=12')),
        http.get(Uri.parse('$_baseUrl/users?page=2&per_page=12')),
      ]);

      final List<User> apiUsers = [];
      for (final response in responses) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final pageUsers = (data['data'] as List)
              .map((userData) => User.fromJson(userData))
              .toList();
          apiUsers.addAll(pageUsers);
        }
      }

      // Deduplicate by id/email
      final Map<String, User> byKey = {};
      for (final u in apiUsers) {
        final key = (u.email.isNotEmpty ? u.email : u.id).toString();
        byKey[key] = u;
      }

      var users = byKey.values.toList();

      // If still small, append mock users to make list feel larger
      if (users.length < 12) {
        final mocks = _getMockUsers();
        for (final mu in mocks) {
          final key = (mu.email.isNotEmpty ? mu.email : mu.id).toString();
          if (!byKey.containsKey(key)) {
            users.add(mu);
          }
        }
      }

      // Cache users locally
      await _cacheUsers(users);
      return users;
    } catch (e) {
      // If API fails, return mock data for testing
      return _getMockUsers();
    }
  }

  List<User> _getMockUsers() {
    return [
      User(
        id: 'john_doe',
        email: 'john.doe@test.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
      ),
      User(
        id: 'jane_smith',
        email: 'jane.smith@test.com',
        firstName: 'Jane',
        lastName: 'Smith',
        avatar: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
      ),
      User(
        id: 'michael_brown',
        email: 'michael.brown@test.com',
        firstName: 'Michael',
        lastName: 'Brown',
        avatar: 'https://i.pravatar.cc/150?img=3',
        isOnline: true,
      ),
      User(
        id: 'emily_johnson',
        email: 'emily.johnson@test.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        avatar: 'https://i.pravatar.cc/150?img=4',
        isOnline: true,
      ),
      User(
        id: 'david_wilson',
        email: 'david.wilson@test.com',
        firstName: 'David',
        lastName: 'Wilson',
        avatar: 'https://i.pravatar.cc/150?img=5',
        isOnline: false,
      ),
      User(
        id: 'sophia_martinez',
        email: 'sophia.martinez@test.com',
        firstName: 'Sophia',
        lastName: 'Martinez',
        avatar: 'https://i.pravatar.cc/150?img=6',
        isOnline: true,
      ),
      User(
        id: 'liam_garcia',
        email: 'liam.garcia@test.com',
        firstName: 'Liam',
        lastName: 'Garcia',
        avatar: 'https://i.pravatar.cc/150?img=7',
        isOnline: true,
      ),
      User(
        id: 'olivia_rodriguez',
        email: 'olivia.rodriguez@test.com',
        firstName: 'Olivia',
        lastName: 'Rodriguez',
        avatar: 'https://i.pravatar.cc/150?img=8',
        isOnline: true,
      ),
      User(
        id: 'noah_lee',
        email: 'noah.lee@test.com',
        firstName: 'Noah',
        lastName: 'Lee',
        avatar: 'https://i.pravatar.cc/150?img=9',
        isOnline: false,
      ),
      User(
        id: 'ava_walker',
        email: 'ava.walker@test.com',
        firstName: 'Ava',
        lastName: 'Walker',
        avatar: 'https://i.pravatar.cc/150?img=10',
        isOnline: true,
      ),
      User(
        id: 'james_hall',
        email: 'james.hall@test.com',
        firstName: 'James',
        lastName: 'Hall',
        avatar: 'https://i.pravatar.cc/150?img=11',
        isOnline: true,
      ),
      User(
        id: 'mia_allen',
        email: 'mia.allen@test.com',
        firstName: 'Mia',
        lastName: 'Allen',
        avatar: 'https://i.pravatar.cc/150?img=12',
        isOnline: true,
      ),
    ];
  }

  Future<List<User>> getCachedUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        email: maps[i]['email'],
        firstName: maps[i]['first_name'],
        lastName: maps[i]['last_name'],
        avatar: maps[i]['avatar'],
        isOnline: maps[i]['isOnline'] == 1,
      );
    });
  }

  Future<void> _cacheUsers(List<User> users) async {
    final db = await database;
    
    // Clear existing data
    await db.delete('users');
    
    // Insert new data
    for (final user in users) {
      await db.insert(
        'users',
        {
          'id': user.id,
          'email': user.email,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'avatar': user.avatar,
          'isOnline': user.isOnline ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('users');
  }
}


