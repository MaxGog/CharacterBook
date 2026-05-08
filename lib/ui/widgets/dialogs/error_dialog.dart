import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showErrorDialog({
  required BuildContext context,
  required String message,
  String? title,
  String buttonText = 'OK',
  String reportButtonText = 'Сообщить об ошибке',
  bool barrierDismissible = true,
  Color? barrierColor,
  VoidCallback? onConfirmed,
  String supportEmail = 'max.gog2005@outlook.com',
  String emailSubject = 'Сообщение об ошибке',
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              borderRadius: BorderRadius.circular(28),
              color: colorScheme.surfaceContainerHigh,
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 130),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            _sendErrorReport(
                              context: context,
                              email: supportEmail,
                              subject: emailSubject,
                              errorMessage: message,
                            );
                          },
                          child: Text(reportButtonText),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirmed?.call();
                          },
                          child: Text(buttonText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                'assets/maxupshur.png',
                height: 180,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.auto_awesome,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 10,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                    ),
                    child: Text(
                      title!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _sendErrorReport({
  required BuildContext context,
  required String email,
  required String subject,
  required String errorMessage,
}) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {
      'subject': subject,
      'body': 'Ошибка: $errorMessage\n\nОписание проблемы: ',
    },
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showEmailError(context);
    }
  } catch (e) {
    _showEmailError(context);
  }
}

void _showEmailError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Не удалось открыть почтовое приложение'),
    ),
  );
}
