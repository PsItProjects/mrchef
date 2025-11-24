import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/address_model.dart';

class AddressService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get all addresses for the authenticated customer
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiConstants.addresses);
      
      if (response.data['success'] == true) {
        final List<dynamic> addressesJson = response.data['data'];
        return addressesJson.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch addresses');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch addresses');
    }
  }

  /// Add a new address
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addresses,
        data: address.toJson(),
      );
      
      if (response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add address');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add address');
    }
  }

  /// Update an existing address
  Future<AddressModel> updateAddress(int id, AddressModel address) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.addresses}/$id',
        data: address.toJson(),
      );
      
      if (response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update address');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update address');
    }
  }

  /// Delete an address
  Future<void> deleteAddress(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.addresses}/$id');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete address');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete address');
    }
  }

  /// Set an address as default
  Future<AddressModel> setDefaultAddress(int id) async {
    try {
      final response = await _apiClient.put('${ApiConstants.addresses}/$id/default');
      
      if (response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to set default address');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to set default address');
    }
  }
}

