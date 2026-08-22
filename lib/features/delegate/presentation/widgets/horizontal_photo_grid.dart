import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saas/core/app_theme.dart';

class HorizontalPhotoGrid extends StatefulWidget {
  final ValueChanged<List<String>>? onPhotosChanged;

  const HorizontalPhotoGrid({
    super.key,
    this.onPhotosChanged,
  });

  @override
  State<HorizontalPhotoGrid> createState() => _HorizontalPhotoGridState();
}

class _HorizontalPhotoGridState extends State<HorizontalPhotoGrid> {
  // ==========================================
  // IMAGE PICKER
  // ==========================================

  final ImagePicker imagePicker = ImagePicker();

  // ==========================================
  // SELECTED PHOTOS
  // ==========================================

  final List<String> photos = [];

  // ==========================================
  // ADD PHOTO
  // ==========================================

  Future<void> addPhoto() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      setState(() {
        photos.add(image.path);
      });

      // إرسال المسارات للصفحة الأب
      widget.onPhotosChanged?.call(
        List<String>.from(photos),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to select photo: $e"),
        ),
      );
    }
  }

  // ==========================================
  // REMOVE PHOTO
  // ==========================================

  void removePhoto(int index) {
    setState(() {
      photos.removeAt(index);
    });

    widget.onPhotosChanged?.call(
      List<String>.from(photos),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "On-site Documentation",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length + 1,
            itemBuilder: (context, index) {
              // ==================================
              // ADD PHOTO BUTTON
              // ==================================
              if (index == photos.length) {
                return GestureDetector(
                  onTap: addPhoto,
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppTheme.primaryColor,
                          size: 30,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Add Photo",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ==================================
              // PHOTO ITEM
              // ==================================
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2e8f0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ==============================
                      // ACTUAL IMAGE
                      // ==============================
                      Image.file(
                        File(photos[index]),
                        fit: BoxFit.cover,
                      ),

                      // ==============================
                      // REMOVE BUTTON
                      // ==============================
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}