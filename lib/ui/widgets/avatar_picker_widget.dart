import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final Function(Uint8List) onImageSelected;
  final double radius;
  final Color? backgroundColor;
  final IconData? placeholderIcon;

  const AvatarPicker({
    super.key,
    required this.imageBytes,
    required this.onImageSelected,
    this.radius = 60,
    this.backgroundColor,
    this.placeholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final picker = ImagePicker();

    Future<void> pickImage() async {
      try {
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final bytes = await image.readAsBytes();
          onImageSelected(bytes);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Center(
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: pickImage,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
              ),
              child: imageBytes != null
                  ? Image.memory(
                imageBytes!,
                fit: BoxFit.cover,
              )
                  : Icon(
                placeholderIcon ?? Icons.add_a_photo,
                size: radius * 0.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}