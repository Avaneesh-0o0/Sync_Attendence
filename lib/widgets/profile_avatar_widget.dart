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
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: _isUploading
                ? const CircularProgressIndicator()
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
                                    color: theme.colorScheme.primary,
                                  ),
                  ),
          ),
        ),
        if (widget.canEdit && !_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
