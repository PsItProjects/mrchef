import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  /// Get customer orders with optional status filter
  Future<Map<String, dynamic>> getOrders({
    List<String>? statuses,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (statuses != null && statuses.isNotEmpty) {
        queryParams['status'] = statuses;
      }

      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.customerOrders}',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      print('❌ ORDER SERVICE: Error fetching orders - $e');
      rethrow;
    }
  }

  /// Get single order details
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.customerOrders}/$orderId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['order'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch order details');
      }
    } catch (e) {
      print('❌ ORDER SERVICE: Error fetching order details - $e');
      rethrow;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}${ApiConstants.customerOrders}/$orderId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      print('❌ ORDER SERVICE: Error canceling order - $e');
      rethrow;
    }
  }

  /// Confirm delivery of an order (customer confirms receipt)
  Future<Map<String, dynamic>> confirmDelivery(int orderId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}${ApiConstants.customerOrders}/$orderId/confirm-delivery',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to confirm delivery');
      }
    } catch (e) {
      print('❌ ORDER SERVICE: Error confirming delivery - $e');
      rethrow;
    }
  }

  /// Accept price proposal from merchant
  Future<Map<String, dynamic>> acceptPrice(int orderId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}${ApiConstants.customerOrders}/$orderId/accept-price',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to accept price');
      }
    } catch (e) {
      print('❌ ORDER SERVICE: Error accepting price - $e');
      rethrow;
    }
  }

  /// Reject price proposal from merchant
  Future<Map<String, dynamic>> rejectPrice(int orderId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}${ApiConstants.customerOrders}/$orderId/reject-price',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to reject price');
      }
    } catch (e) {
      print('❌ ORDER SERVICE: Error rejecting price - $e');
      rethrow;
    }
  }
}

