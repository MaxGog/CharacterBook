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

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: pickImage,
      child: Ink(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
          child: imageBytes == null
              ? Icon(
            placeholderIcon ?? Icons.add_a_photo,
            size: radius * 0.6,
            color: theme.colorScheme.onSurfaceVariant,
          )
              : null,
        ),
      ),
    );
  }
}