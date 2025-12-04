import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late DatabaseHelper _dbHelper;
  late SharedPreferences _prefs;
  User? _currentUser;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> init() async {
    print('AuthService.init(): Starting');
    // Initialize database helper
    _dbHelper = DatabaseHelper();
    // On web, sqflite is not supported — skip database initialization
    if (!kIsWeb) {
      // Initialize database factory first
      await _dbHelper.database;
      print('AuthService.init(): DatabaseHelper created and initialized');
    } else {
      print(
        'AuthService.init(): Running on web - skipping sqflite database init',
      );
    }

    _prefs = await SharedPreferences.getInstance();
    print('AuthService.init(): SharedPreferences loaded');

    // Ensure we fully load the saved user before completing init so
    // other UI code can rely on `AuthService().isLoggedIn` immediately.
    await _loadUserFromPrefs();
    print('AuthService.init(): Complete');
  }

  User? get currentUser => _currentUser;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userType,
    required String address,
  }) async {
    try {
      // Validate email format
      if (!email.contains('@')) {
        print('Register error: Email format invalid');
        return false;
      }

      if (kIsWeb) {
        print('Register: running web fallback (SharedPreferences)');
        final users = await _getWebUsers();
        final exists = users.any(
          (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
        );
        if (exists) {
          print('Register error: Email already exists (web)');
          return false;
        }

        final id = DateTime.now().millisecondsSinceEpoch;
        final userMap = {
          'id': id,
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'userType': userType,
          'address': address,
          'createdAt': DateTime.now().toIso8601String(),
          'isActive': 1,
        };
        users.add(userMap);
        await _saveWebUsers(users);

        _currentUser = User.fromMap(userMap);
        await _saveUserToPrefs(_currentUser!);
        print('Register success (web): $email');
        return true;
      }

      print('Checking if email exists: $email');
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        print('Register error: Email already exists');
        return false;
      }

      print('Creating new user with email: $email');
      final user = User(
        id: 0,
        name: name,
        email: email,
        password: password,
        phone: phone,
        userType: userType,
        address: address,
        createdAt: DateTime.now(),
      );

      print('Inserting user to database');
      final id = await _dbHelper.insertUser(user);
      print('Insert result: $id');

      if (id <= 0) {
        print('Register error: Insert failed, id=$id');
        return false;
      }

      print('Getting user by id: $id');
      final newUser = await _dbHelper.getUserById(id);

      if (newUser != null) {
        print('Register success: User ${newUser.email} created with id $id');
        _currentUser = newUser;
        await _saveUserToPrefs(newUser);
        return true;
      }
      print('Register error: User not found after insert');
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      if (kIsWeb) {
        final users = await _getWebUsers();
        Map<String, dynamic>? map;
        for (final u in users) {
          if ((u['email'] as String).toLowerCase() == email.toLowerCase()) {
            map = u;
            break;
          }
        }
        if (map != null) {
          final pwd = map['password'] as String? ?? '';
          final active = (map['isActive'] as int?) ?? 1;
          if (pwd == password && active == 1) {
            _currentUser = User.fromMap(map);
            await _saveUserToPrefs(_currentUser!);
            return true;
          }
        }
        return false;
      }

      final user = await _dbHelper.getUserByEmail(email);
      if (user != null && user.password == password && user.isActive) {
        _currentUser = user;
        await _saveUserToPrefs(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Web helpers: store user list in SharedPreferences as JSON
  Future<List<Map<String, dynamic>>> _getWebUsers() async {
    final raw = _prefs.getString('web_users');
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('AuthService: Failed to decode web users: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _saveWebUsers(List<Map<String, dynamic>> users) async {
    final encoded = jsonEncode(users);
    await _prefs.setString('web_users', encoded);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove('user_id');
    await _prefs.remove('user_email');
    await _prefs.remove('user_type');
  }

  Future<void> _saveUserToPrefs(User user) async {
    await _prefs.setInt('user_id', user.id);
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_type', user.userType);
    // Save a JSON snapshot of the user so we can restore even if DB lookup fails
    try {
      final json = user.toMap(includeId: true);
      await _prefs.setString('user_json', jsonEncode(json));
    } catch (_) {}
  }

  Future<void> _loadUserFromPrefs() async {
    final userId = _prefs.getInt('user_id');
    final userEmail = _prefs.getString('user_email');
    final userType = _prefs.getString('user_type');
    if (userId != null && userEmail != null && userType != null) {
      try {
        if (kIsWeb) {
          // Load from web users store
          final users = await _getWebUsers();
          final map = users.firstWhere(
            (u) => (u['id'] as int) == userId,
            orElse: () => {},
          );
          if (map.isNotEmpty) {
            _currentUser = User.fromMap(map);
          } else {
            // Clear stale prefs
            print(
              'AuthService: Stored web user_id=$userId not found. Clearing saved user prefs.',
            );
            // Try to restore from JSON snapshot if present
            final raw = _prefs.getString('user_json');
            if (raw != null && raw.isNotEmpty) {
              try {
                final map = jsonDecode(raw) as Map<String, dynamic>;
                _currentUser = User.fromMap(map);
                print(
                  'AuthService: Restored user from user_json snapshot (web)',
                );
              } catch (_) {
                await _prefs.remove('user_id');
                await _prefs.remove('user_email');
                await _prefs.remove('user_type');
                await _prefs.remove('user_json');
                _currentUser = null;
              }
            } else {
              await _prefs.remove('user_id');
              await _prefs.remove('user_email');
              await _prefs.remove('user_type');
              _currentUser = null;
            }
          }
        } else {
          // Native platforms: load from DB synchronously (await)
          final u = await _dbHelper.getUserById(userId);
          if (u != null) {
            _currentUser = u;
          } else {
            print(
              'AuthService: Stored user_id=$userId not found in DB. Clearing saved user prefs.',
            );
            // Try to restore from JSON snapshot if available
            final raw = _prefs.getString('user_json');
            if (raw != null && raw.isNotEmpty) {
              try {
                final map = jsonDecode(raw) as Map<String, dynamic>;
                _currentUser = User.fromMap(map);
                print(
                  'AuthService: Restored user from user_json snapshot (native)',
                );
              } catch (_) {
                await _prefs.remove('user_id');
                await _prefs.remove('user_email');
                await _prefs.remove('user_type');
                await _prefs.remove('user_json');
                _currentUser = null;
              }
            } else {
              await _prefs.remove('user_id');
              await _prefs.remove('user_email');
              await _prefs.remove('user_type');
              _currentUser = null;
            }
          }
        }
      } catch (e) {
        print('AuthService: Error loading user from prefs/db: $e');
        _currentUser = null;
      }
    } else {
      _currentUser = null;
    }
  }

  bool get isLoggedIn => _currentUser != null;

  String get userType => _currentUser?.userType ?? '';

  int get userId => _currentUser?.id ?? 0;
}
