import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'supabase_service.dart';
import '../data/models/user_model.dart';

import '../core/config/cloudinary_config.dart';

class ProfileService {
  final SupabaseClient _supabase = SupabaseService.instance.client;
  
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  /// Fetch user profile from Supabase
  Future<UserModel?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('PROFILE_SERVICE: Error fetching profile: $e');
      return null;
    }
  }

  /// Update user profile data
  Future<bool> updateProfile({String? name, String? avatarUrl, String? department}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (department != null) updates['department'] = department;

      if (updates.isEmpty) return true;

      await _supabase.from('users').update(updates).eq('id', userId);
      return true;
    } catch (e) {
      print('PROFILE_SERVICE: Error updating profile: $e');
      return false;
    }
  }

  /// Upload image to Cloudinary and update profile
  Future<String?> uploadProfilePicture(XFile xFile) async {
    print('PROFILE_SERVICE: Starting upload for ${xFile.path}');
    try {
      CloudinaryFile cloudinaryFile;
      
      if (kIsWeb) {
        final bytes = await xFile.readAsBytes();
        // CloudinaryPublic on web often works better with bytes
        cloudinaryFile = CloudinaryFile.fromByteData(
          ByteData.view(bytes.buffer),
          identifier: xFile.name,
          folder: 'profile_pictures',
        );
      } else {
        cloudinaryFile = CloudinaryFile.fromFile(xFile.path, folder: 'profile_pictures');
      }

      CloudinaryResponse response = await _cloudinary.uploadFile(cloudinaryFile);

      final avatarUrl = response.secureUrl;
      print('PROFILE_SERVICE: Upload success, URL: $avatarUrl');
      
      // Update in Supabase
      final dbSuccess = await updateProfile(avatarUrl: avatarUrl);
      print('PROFILE_SERVICE: Database update success: $dbSuccess');
      
      // Save locally for offline access (mobile/desktop only)
      if (!kIsWeb) {
        await saveImageLocally(File(xFile.path));
      }

      return avatarUrl;
    } catch (e, stack) {
      print('PROFILE_SERVICE: Error uploading to Cloudinary: $e');
      print(stack);
      return null;
    }
  }

  /// Save image file locally for offline access
  Future<void> saveImageLocally(File imageFile) async {
    if (kIsWeb) return; // path_provider not supported on web for this usage
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = p.join(directory.path, 'profile_v1.jpg');
      await imageFile.copy(localPath);
    } catch (e) {
      print('PROFILE_SERVICE: Error saving image locally: $e');
    }
  }

  /// Get locally saved profile image if exists
  Future<File?> getLocalProfileImage() async {
    if (kIsWeb) return null; // path_provider not supported on web for this usage
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = p.join(directory.path, 'profile_v1.jpg');
      final file = File(localPath);
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      print('PROFILE_SERVICE: Error getting local image: $e');
    }
    return null;
  }
}
