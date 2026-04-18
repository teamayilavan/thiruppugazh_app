import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup_service.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.translate_outlined),
            title: Text(l10n.language),
            subtitle: Text(_getLanguageDisplayName(context, languageProvider.currentLanguage)),
            onTap: () {
              _showLanguageDialog(context, languageProvider);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.theme),
            subtitle: Text(
              '${l10n.current}: ${_getThemeDisplayName(context, themeProvider.themeMode)}',
            ),
            onTap: () {
              _showThemeDialog(context, themeProvider);
            },
          ),
          const Divider(),
          _buildDataManagementSection(context, l10n),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.creditsTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 24.0),
                Text(
                  l10n.sriGopalaSundaram,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n.thiruppugazhExplanatoryText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24.0),
                Text(
                  l10n.thiruSendhan,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n.kaumaramFounder,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24.0),
                Text(
                  l10n.kaumaramTeam,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n.kaumaramCoFounders,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: 24.0),
                Text(
                  l10n.appDevelopment,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(l10n.ayilavanAni, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24.0),
                Text(
                  l10n.contact,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(l10n.contactEmail, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
                child: Text(l10n.privacyPolicy),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppLanguage>(
                title: Text(l10n.tamil),
                value: AppLanguage.tamil,
                groupValue: provider.currentLanguage,
                onChanged: (AppLanguage? value) {
                  provider.setLanguage(value!);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppLanguage>(
                title: Text(l10n.english),
                value: AppLanguage.english,
                groupValue: provider.currentLanguage,
                onChanged: (AppLanguage? value) {
                  provider.setLanguage(value!);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.chooseTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.light),
                value: ThemeMode.light,
                groupValue: provider.themeMode,
                onChanged: (ThemeMode? value) {
                  provider.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.dark),
                value: ThemeMode.dark,
                groupValue: provider.themeMode,
                onChanged: (ThemeMode? value) {
                  provider.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.systemDefault),
                value: ThemeMode.system,
                groupValue: provider.themeMode,
                onChanged: (ThemeMode? value) {
                  provider.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataManagementSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.storage_outlined),
          title: Text(l10n.dataManagement),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => BackupService().exportData(context),
                  icon: const Icon(Icons.upload),
                  label: Text(l10n.exportData),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _confirmAndImport(context, l10n),
                  icon: const Icon(Icons.download),
                  label: Text(l10n.importData),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmAndImport(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importConfirmationTitle),
        content: Text(l10n.importConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              BackupService().importData(context);
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }
  String _getLanguageDisplayName(BuildContext context, AppLanguage language) {
    final l10n = AppLocalizations.of(context)!;
    switch (language) {
      case AppLanguage.tamil:
        return l10n.tamil;
      case AppLanguage.english:
        return l10n.english;
    }
  }

  String _getThemeDisplayName(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }
}
