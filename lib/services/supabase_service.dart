
    import 'package:supabase_flutter/supabase_flutter.dart';

  
   

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance =>
      _instance ??= SupabaseService._internal();

  SupabaseService._internal();

  // 🔴 PUT YOUR REAL VALUES HERE
  static const String supabaseUrl =
      'https://rpyeyfzppjnakhbajgzn.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJweWV5ZnpwcGpuYWtoYmFqZ3puIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1ODIyODcsImV4cCI6MjA4MzE1ODI4N30.9hd_D_CSR7NPmD8D9M10Q4HBzntiw6KSPhyXPO_k6L4';

  /// Call this once in main()
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase URL or Anon Key is missing');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Access Supabase client anywhere
  SupabaseClient get client => Supabase.instance.client;
}
