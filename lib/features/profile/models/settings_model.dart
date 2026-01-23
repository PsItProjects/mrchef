class SettingsModel {
  final bool isDarkMode;
  final String currency;
  final String language;
  final bool notificationsEnabled;
  final String cacheSize;
  final String appVersion;

  SettingsModel({
    required this.isDarkMode,
    required this.currency,
    required this.language,
    required this.notificationsEnabled,
    required this.cacheSize,
    required this.appVersion,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: json['isDarkMode'] ?? false,
      currency: json['currency'] ?? 'SAR',
      language: json['language'] ?? 'ar',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      cacheSize: json['cacheSize'] ?? '7.65 MB',
      appVersion: json['appVersion'] ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'currency': currency,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'cacheSize': cacheSize,
      'appVersion': appVersion,
    };
  }

  SettingsModel copyWith({
    bool? isDarkMode,
    String? currency,
    String? language,
    bool? notificationsEnabled,
    String? cacheSize,
    String? appVersion,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      cacheSize: cacheSize ?? this.cacheSize,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
