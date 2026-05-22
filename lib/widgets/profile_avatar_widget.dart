import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import 'custom_image_widget.dart';
import '../core/app_export.dart';

class ProfileAvatarWidget extends StatefulWidget {
  final String? initialImageUrl;
  final double radius;
  final bool canEdit;
  final Function(String)? onUploadComplete;

  const ProfileAvatarWidget({
    super.key,
    this.initialImageUrl,
    this.radius = 50,
    this.canEdit = true,
    this.onUploadComplete,
  });

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  
  String? _currentImageUrl;
  File? _localFile;
  Uint8List? _webImageBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
    _loadLocalImage();
  }

  @override
  void didUpdateWidget(ProfileAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      setState(() {
        _currentImageUrl = widget.initialImageUrl;
      });
    }
  }

  Future<void> _loadLocalImage() async {
    final file = await _profileService.getLocalProfileImage();
    if (mounted) {
      setState(() {
        _localFile = file;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _localFile = File(image.path);
        });
      }

      final newUrl = await _profileService.uploadProfilePicture(image);
      
      if (newUrl != null) {
        setState(() {
          _currentImageUrl = newUrl;
        });
        if (widget.onUploadComplete != null) {
          widget.onUploadComplete!(newUrl);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload failed. Please check your internet or Cloudinary settings.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('AVATAR_WIDGET: Caught Error: $e');
      String userMessage = 'Error: ${e.toString()}';
      
      if (e.toString().contains('MissingPluginException')) {
        userMessage = 'Plugin error: Please COMPLETELY STOP and RESTART the app (Full rebuild required).';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Holographic Glow Ring & Dark Backdrop ──
        Container(
          width: widget.radius * 2 + 12,
          height: widget.radius * 2 + 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface.withValues(alpha: 0.8), // Dark translucent backdrop
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              width: 2.5, // Neon border
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: theme.colorScheme.surface,
              child: _isUploading
                  ? CircularProgressIndicator(color: theme.colorScheme.primary)
                  : ClipOval(
                      child: kIsWeb && _webImageBytes != null
                          ? Image.memory(
                              _webImageBytes!,
                              width: widget.radius * 2,
                              height: widget.radius * 2,
                              fit: BoxFit.cover,
                            )
                          : !kIsWeb && _localFile != null && _localFile!.existsSync()
                              ? Image.file(
                                  _localFile!,
                                  width: widget.radius * 2,
                                  height: widget.radius * 2,
                                  fit: BoxFit.cover,
                                )
                              : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                  ? CustomImageWidget(
                                      imageUrl: _currentImageUrl,
                                      width: widget.radius * 2,
                                      height: widget.radius * 2,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: widget.radius,
                                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                    ),
                    ),
            ),
          ),
        ),
        // ── Edit Button ──
        if (widget.canEdit && !_isUploading)
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface, // Dark container
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary, 
                    width: 1.5, // Cyan highlight
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
