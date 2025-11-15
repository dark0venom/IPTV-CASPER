import 'package:flutter/material.dart';

/// Widget for selecting app language
class LanguageSelectorWidget extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  static const languages = {
    'en': {'name': 'English', 'flag': '🇺🇸'},
    'es': {'name': 'Español', 'flag': '🇪🇸'},
    'fr': {'name': 'Français', 'flag': '🇫🇷'},
    'de': {'name': 'Deutsch', 'flag': '🇩🇪'},
    'ar': {'name': 'العربية', 'flag': '🇸🇦'},
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Language', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...languages.entries.map((entry) {
          final code = entry.key;
          final data = entry.value;
          final isSelected = currentLanguage == code;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: ListTile(
              leading: Text(
                data['flag']!,
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(
                data['name']!,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => onLanguageChanged(code),
            ),
          );
        }),
      ],
    );
  }
}

/// Dialog for selecting language
class LanguageSelectorDialog extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelectorDialog({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Language',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LanguageSelectorWidget(
              currentLanguage: currentLanguage,
              onLanguageChanged: (code) {
                onLanguageChanged(code);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
