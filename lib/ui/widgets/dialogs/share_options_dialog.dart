import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

class ShareOptionsDialog extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShareFile;
  final VoidCallback? onExportPdf;

  const ShareOptionsDialog({
    super.key,
    required this.onCopy,
    required this.onShareFile,
    this.onExportPdf,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCopy,
    required VoidCallback onShareFile,
    VoidCallback? onExportPdf,
  }) {
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => ShareOptionsDialog(
        onCopy: onCopy,
        onShareFile: onShareFile,
        onExportPdf: onExportPdf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.share),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy_rounded),
            title: Text(s.copy),
            onTap: () {
              Navigator.pop(context);
              onCopy();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: Text(s.share),
            onTap: () {
              Navigator.pop(context);
              onShareFile();
            },
          ),
          if (onExportPdf != null)
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: Text(s.file_pdf),
              onTap: () {
                Navigator.pop(context);
                onExportPdf!();
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}
