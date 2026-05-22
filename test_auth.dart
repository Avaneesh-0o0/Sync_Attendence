import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  try {
    // We need to load from the specific path if .env is in the root
    dotenv.testLoad(fileInput: File('.env').readAsStringSync());
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabase = SupabaseClient(url, key);

    print('Testing Sign Up...');
    try {
      final res = await supabase.auth.signUp(
        email: 'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'password123',
        data: {'name': 'Test User', 'role': 'student'},
      );
      print('Sign Up Success: \${res.user?.id}');

      // Test inserting into users table
      if (res.user != null) {
        try {
          await supabase.from('users').insert({
            'id': res.user!.id,
            'email': res.user!.email,
            'name': 'Test User',
            'role': 'student',
            'created_at': DateTime.now().toIso8601String(),
          });
          print('User profile created successfully.');
        } catch (e) {
          print('User profile creation error: $e');
        }
      }
    } catch (e) {
      print('Sign Up Error: $e');
    }

    exit(0);
  } catch (e) {
    print('Initialization Error: $e');
    exit(1);
  }
}
