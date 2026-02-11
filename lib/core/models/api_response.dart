class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
      statusCode: json['status_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'status_code': statusCode,
    };
  }

  bool get isSuccess => success;
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Extract all validation error messages as a single string
  /// e.g. {email: ["Email taken"], name: ["Required"]} → "Email taken\nRequired"
  String get validationErrorsString {
    if (errors == null || errors!.isEmpty) return message;
    final List<String> allErrors = [];
    for (final entry in errors!.entries) {
      if (entry.value is List) {
        for (final msg in entry.value) {
          allErrors.add(msg.toString());
        }
      } else {
        allErrors.add(entry.value.toString());
      }
    }
    return allErrors.isNotEmpty ? allErrors.join('\n') : message;
  }
}
