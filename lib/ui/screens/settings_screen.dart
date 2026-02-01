import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup_service.dart';

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
            subtitle: Text(languageProvider.currentLanguage.displayName),
            onTap: () {
              _showLanguageDialog(context, languageProvider);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.theme),
            subtitle: Text(
              '${l10n.current}: ${themeProvider.themeMode.name.capitalize()}',
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
                Text(l10n.creditsTitle, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24.0),
                Text(
                  l10n.sriGopalaSundaram,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n.thiruppugazhExplanatoryText,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24.0),
                Text(
                  l10n.thiruSendhan,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n.kaumaramFounder,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24.0),
                Text(
                  l10n.kaumaramTeam,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n.kaumaramCoFounders,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 24.0),
                Text(
                  l10n.appDevelopment,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(l10n.ayilavanAni, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24.0),
                Text(
                  l10n.contact,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(l10n.contactEmail, style: const TextStyle(fontSize: 16)),
              ],
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
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
