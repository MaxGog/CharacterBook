import 'dart:typed_data';
import 'package:flutter/material.dart';

class CharacterImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final double size;
  final IconData icon;

  const CharacterImagePicker({
    super.key,
    required this.imageBytes,
    required this.onTap,
    this.size = 120,
    this.icon = Icons.add_a_photo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: imageBytes != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.memory(
            imageBytes!,
            fit: BoxFit.cover,
          ),
        )
            : Icon(
          icon,
          size: size / 3,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}