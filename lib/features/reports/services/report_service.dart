import 'package:dio/dio.dart';
import 'package:mrsheaf/core/network/api_client.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient.instance;

  String _basePathForUserType(String userType) {
    if (userType == 'merchant') return '/merchant';
    return '/customer';
  }

  /// List all reports for the current user
  Future<List<Map<String, dynamic>>> listReports({required String userType}) async {
    final base = _basePathForUserType(userType);
    final res = await _apiClient.get('$base/reports');
    final data = res.data;
    if (data is Map && data['success'] == true) {
      final reports = (data['data']?['reports'] as List?) ?? const [];
      return reports.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }

  /// Get a single report with all messages
  Future<Map<String, dynamic>> getReport({
    required String userType,
    required int reportId,
  }) async {
    final base = _basePathForUserType(userType);
    final res = await _apiClient.get('$base/reports/$reportId');
    final data = res.data;
    if (data is Map && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']?['report'] as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }

  /// Send a message/reply to a report
  Future<Map<String, dynamic>> sendReportMessage({
    required String userType,
    required int reportId,
    required String message,
  }) async {
    final base = _basePathForUserType(userType);
    final res = await _apiClient.post(
      '$base/reports/$reportId/messages',
      data: {
        'message': message,
      },
    );
    final data = res.data;
    if (data is Map && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']?['message'] as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: data,
      type: DioExceptionType.badResponse,
    );
  }
}
