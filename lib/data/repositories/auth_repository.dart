import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Get current user from Auth
  User? get currentUser => _supabase.auth.currentUser;

  // Sign in with Email and Password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with Email and Password
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  // Sign in with Google (Web & Native handled by caller or separate logic)
  // This assumes the plumbing is done in the UI layer or specialized service
  Future<bool> signInWithGoogle() async {
    // This is a placeholder for the repository-level call
    // The actual implementation often involves native code or web redirects
    return false;
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Fetch User Profile from 'users' table
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Changed single() to maybeSingle() to handle missing profiles gracefully

      if (response == null) {
        print('AU_REPO: No profile found for userId: $userId');
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e, stack) {
      print('AU_REPO: Error fetching user profile: $e');
      print(stack);
      return null;
    }
  }

  // Create User Profile in 'users' table
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _supabase.from('users').insert(user.toJson());
    } catch (e, stack) {
      print('AU_REPO: Error creating user profile: $e');
      print(stack);
      rethrow;
    }
  }
}

