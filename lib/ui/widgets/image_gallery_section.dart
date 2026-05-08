import 'dart:typed_data';

import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

class ImageGallerySection extends StatelessWidget {
  final List<Uint8List> images;
  final VoidCallback onAddImage;
  final ValueChanged<int> onRemoveImage;
  final String title;
  final String emptyText;
  final String addTooltip;

  const ImageGallerySection({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.title,
    required this.emptyText,
    required this.addTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(title, style: textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: onAddImage,
              tooltip: addTooltip,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (images.isEmpty)
          Text(
            emptyText,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        if (images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        Semantics(
                          label: '${title} ${index + 1}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              images[index],
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Semantics(
                            label: S.of(context).delete,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => onRemoveImage(index),
                              tooltip: 'Удалить',
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
