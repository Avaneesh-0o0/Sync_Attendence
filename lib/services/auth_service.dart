import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _repository = AuthRepository(SupabaseService.instance.client);
  }

  late final AuthRepository _repository;
  final SupabaseClient _supabase = SupabaseService.instance.client;

  /// Current User
  User? get currentUser => _repository.currentUser;

  /// Sign In with Email
  Future<void> signInWithEmail(String email, String password) async {
    await _repository.signInWithEmail(email, password);
  }

  /// Sign Up with Email
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    String role,
  ) async {
    await _repository.signUpWithEmail(
      email,
      password,
      data: {'name': name, 'role': role},
    );

    // Profile creation is now automatically handled by a PostgreSQL
    // database trigger (`on_auth_user_created`) in Supabase.
  }

  /// Sign in with Google
  /// Returns null if cancelled or failed
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web flow
        await _supabase.auth.signInWithOAuth(OAuthProvider.google);
        return null; // Will redirect
      } else {
        // Native Android/iOS flow
        // Provided by user or environment
        const webClientId = 'my-web.apps.googleusercontent.com'; // Placeholder
        const iosClientId = 'my-ios.apps.googleusercontent.com'; // Placeholder

        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: defaultTargetPlatform == TargetPlatform.iOS
              ? iosClientId
              : null,
          serverClientId: webClientId,
        );

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // User cancelled

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null) throw 'No Access Token found.';
        if (idToken == null) throw 'No ID Token found.';

        return _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow; // Let UI handle "Unsupported provider" if specific
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _repository.signOut();
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
  }

  /// Get User Role from 'users' table or metadata fallback
  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) {
      print('AU_SERVICE: No current user, cannot fetch role');
      return null;
    }

    print('AU_SERVICE: Fetching role for user: ${user.id}');
    final userModel = await _repository.getUserProfile(user.id);
    if (userModel != null) {
      print('AU_SERVICE: Role found in DB: ${userModel.role}');
      return userModel.role;
    }

    // Fallback to metadata
    final metadataRole = user.userMetadata?['role'] as String?;
    print('AU_SERVICE: DB role missing, metadata fallback: $metadataRole');
    return metadataRole;
  }

  /// Get Full User Profile
  Future<UserModel?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return await _repository.getUserProfile(user.id);
  }

  /// Update user role (e.g. for Google Sign In users who need to pick a role)
  Future<void> updateUserRole(String role) async {
    final user = currentUser;
    if (user == null) return;
    await _repository.updateUserRole(user.id, role);

    // Attempt to update the user metadata in auth too
    try {
      await _supabase.auth.updateUser(UserAttributes(data: {'role': role}));
    } catch (_) {
      // It's okay if this fails, the db holds the main truth now
    }
  }
}
