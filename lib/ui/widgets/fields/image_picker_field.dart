import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatelessWidget {
  final Uint8List? initialImage;
  final ValueChanged<Uint8List?> onImageSelected;
  final String label;
  final double size;

  const ImagePickerField({
    super.key,
    this.initialImage,
    required this.onImageSelected,
    this.label = 'Изображение',
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickImage(context),
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              image: initialImage != null
                  ? DecorationImage(
                image: MemoryImage(initialImage!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: initialImage == null
                ? Icon(
              Icons.add_a_photo,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            )
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        onImageSelected(bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе изображения: $e')),
      );
    }
  }
}