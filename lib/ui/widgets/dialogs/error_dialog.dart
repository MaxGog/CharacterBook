import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/services/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void showErrorDialog({
  required BuildContext context,
  required String message,
  String? title,
  String? buttonText,
  String? reportButtonText,
  bool barrierDismissible = true,
  Color? barrierColor,
  VoidCallback? onConfirmed,
  String supportEmail = 'max.gog2005@outlook.com',
  String? emailSubject,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? const Color(0x80000000),
    builder: (BuildContext context) {
      final s = S.of(context);
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      final okText = buttonText ?? s.ok;
      final reportText = reportButtonText ?? s.report_error;
      final subject = emailSubject ?? s.error_report_subject;

      final buttonStyle = FilledButton.styleFrom(
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            backgroundColor: Colors.transparent,
            child: Material(
              borderRadius: BorderRadius.circular(28),
              color: colorScheme.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.errorContainer,
                            child: Icon(
                              Icons.error_outline,
                              color: colorScheme.onErrorContainer,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title ?? s.error,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.error_dialog_description,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          FilledButton.icon(
                            style: buttonStyle,
                            onPressed: () async {
                              await _copyErrorToClipboard(context, title ?? s.error, message);
                            },
                            icon: Icon(Icons.copy_outlined, color: colorScheme.onPrimary),
                            label: Text(s.copy_error_text),
                          ),
                          FilledButton.icon(
                            style: buttonStyle,
                            onPressed: () {
                              _sendErrorReport(
                                context: context,
                                email: supportEmail,
                                subject: subject,
                                errorMessage: message,
                              );
                            },
                            icon: Icon(Icons.send_outlined, color: colorScheme.onPrimary),
                            label: Text(reportText),
                          ),
                          FilledButton.icon(
                            style: buttonStyle,
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirmed?.call();
                            },
                            icon: Icon(Icons.check, color: colorScheme.onPrimary),
                            label: Text(okText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: -35,
            child: SizedBox(
              width: 320,
              height: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/maxupshur.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 128,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _copyErrorToClipboard(
  BuildContext context,
  String title,
  String message,
) async {
  final s = S.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final backgroundColor = Theme.of(context).colorScheme.surfaceTint.withAlpha(26);
  final text = '$title\n\n$message';

  await Clipboard.setData(ClipboardData(text: text));
  messenger.showSnackBar(
    SnackBar(
      content: Text(s.copied_to_clipboard),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
    ),
  );
}

Future<void> _sendErrorReport({
  required BuildContext context,
  required String email,
  required String subject,
  required String errorMessage,
}) async {
  final body = S.current.error_report_body(errorMessage);
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {
      'subject': subject,
      'body': body,
    },
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showEmailError();
    }
  } catch (_) {
    _showEmailError();
  }
}

void _showEmailError() {
  AppNavigator.showError(S.current.email_open_error);
}
