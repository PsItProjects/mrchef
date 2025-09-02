# Localization System

This directory contains the localization system for the MrSheaf app, supporting both Arabic and English languages.

## Files Structure

- `app_translations.dart` - Main translations file with all text strings
- `translation_helper.dart` - Helper class with utility methods for translations
- `language_switcher.dart` - Widget for switching between languages
- `localization_binding.dart` - GetX binding for language service

## Usage

### Basic Translation
```dart
import 'package:mrsheaf/core/localization/translation_helper.dart';

// Simple translation
Text(TranslationHelper.tr('welcome'))

// Translation with arguments
Text(TranslationHelper.tr('hello_user', args: {'name': 'John'}))
```

### Language Switching
```dart
import 'package:mrsheaf/core/widgets/language_switcher.dart';

// Full language switcher
LanguageSwitcher()

// Compact version
LanguageSwitcher(isCompact: true, showLabel: false)
```

### Helper Methods
```dart
// Check current language
if (TranslationHelper.isArabic) {
  // Arabic-specific logic
}

// Format currency
String price = TranslationHelper.formatCurrency(25.50);

// Format date
String date = TranslationHelper.formatDate(DateTime.now());

// Get localized greeting
String greeting = TranslationHelper.getGreeting();
```

## Adding New Translations

1. Add the key-value pair to both English and Arabic maps in `app_translations.dart`
2. Add the key to the helper maps in `translation_helper.dart` if needed
3. Use `TranslationHelper.tr('your_key')` in your widgets

## Supported Languages

- English (en) - Default
- Arabic (ar) - RTL support included

## Features

- ✅ RTL/LTR support
- ✅ Currency formatting
- ✅ Date/time formatting
- ✅ Number formatting (Arabic numerals)
- ✅ Pluralization support
- ✅ Dynamic language switching
- ✅ Persistent language preference
- ✅ Fallback to English if translation missing
