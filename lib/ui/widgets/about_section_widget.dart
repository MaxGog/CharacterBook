import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:characterbook/generated/l10n.dart';

class AboutSection extends StatelessWidget {

  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(32)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primary,
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: const AssetImage('assets/avatardeveloper.png'),
                )
              ),
              const SizedBox(height: 16),
              Text(
                "${s.developer}: Максим Гоглов",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.title, color: colorScheme.onSurfaceVariant),
          title: Text(s.name),
          trailing: Text(s.app_name, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading:
              Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
          title: Text(s.version),
          trailing: Text('1.8.0', style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.code, color: colorScheme.onSurfaceVariant),
          title: Text(s.flutterLicense),
          onTap: () => _launchUrl(
              'https://github.com/flutter/flutter/blob/master/LICENSE'),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.article, color: colorScheme.onSurfaceVariant),
          title: Text(s.characterbookLicense),
          onTap: () => _launchUrl('https://www.gnu.org/licenses/gpl-3.0.html'),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.list, color: colorScheme.onSurfaceVariant),
          title: Text(s.usedLibraries),
          onTap: () => showLicensePage(
              context: context,
              applicationName: s.app_name,
              applicationVersion: '1.8.0',
              applicationIcon:
                  Image.asset('assets/iconapp.png', width: 50, height: 50),
              useRootNavigator: true),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            s.acknowledgements.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildContributorChip(context, '🐺Артём Голубев'),
            _buildContributorChip(context, '😎Евгений Стратий'),
            _buildContributorChip(context, 'Максим Семенков'),
            _buildContributorChip(context, '🐼Богдан Чернов'),
            _buildContributorChip(context, 'Александр Черняев'),
            _buildContributorChip(context, 'Мария Война'),
            _buildContributorChip(context, 'Дарья Воробьёва'),
            _buildContributorChip(context, '🦊Михаил Антонюк'),
            _buildContributorChip(context, 'Алексей Головкин'),
            _buildContributorChip(context, 'Никита Жевнерович'),
            _buildContributorChip(context, '🦝Данила Ганьков'),
            _buildContributorChip(context, 'KellSmiley'),
            _buildContributorChip(context, 'Участники EnA'),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: () =>
              _launchUrl('https://github.com/MaxGog/CharacterBook'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/github-mark.png', width: 24, height: 24),
              const SizedBox(width: 12),
              Text(s.githubRepo, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => _launchUrl('https://hipolink.net/maxupshur/'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: colorScheme.tertiaryContainer,
            foregroundColor: colorScheme.onTertiaryContainer,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 24),
              const SizedBox(width: 12),
              Text(
                'Поддержать разработчика',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContributorChip(BuildContext context, String name) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
