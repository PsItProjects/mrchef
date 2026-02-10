import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/product_details/models/review_model.dart';

class ProductDetailsService {
  final ApiClient _apiClient = ApiClient.instance;

  // Store raw sizes data for ID mapping
  final List<Map<String, dynamic>> _rawSizes = [];
  // Store rating summary from reviews API (real breakdown)
  Map<String, dynamic> _ratingSummary = {};

  List<Map<String, dynamic>> get rawSizes => _rawSizes;
  Map<String, dynamic> get ratingSummary => _ratingSummary;

  /// Get product details by ID
  Future<ProductModel> getProductDetails(int productId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.productDetails(productId)}',
      );

      if (response.data['success'] == true) {
        final productData = response.data['data'];

        // Store raw sizes data for ID mapping
        if (kDebugMode) {
          print('🔍 RAW PRODUCT DATA SIZES: ${productData['sizes']}');
          print('🔍 SIZES TYPE: ${productData['sizes'].runtimeType}');
        }

        if (productData['sizes'] is List) {
          _rawSizes.clear();
          _rawSizes.addAll(
            List<Map<String, dynamic>>.from(
              productData['sizes'].map((size) => Map<String, dynamic>.from(size))
            )
          );

          if (kDebugMode) {
            print('🔍 STORED RAW SIZES: $_rawSizes');
          }
        } else {
          if (kDebugMode) {
            print('🔍 SIZES IS NOT A LIST!');
          }
        }

        return ProductModel.fromJson(productData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load product details');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load product details: $e');
    }
  }

  /// Get product reviews
  Future<List<ReviewModel>> getProductReviews(int productId, {int page = 1, int perPage = 10}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.productReviews(productId)}',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.data['success'] == true) {
        final reviewsData = response.data['data']['reviews'] as List;
        // Store rating summary with REAL breakdown from backend
        if (response.data['data']['rating_summary'] != null) {
          _ratingSummary = Map<String, dynamic>.from(response.data['data']['rating_summary']);
        }
        return reviewsData.map((review) => ReviewModel.fromJson(review)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load reviews');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No reviews found
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  /// Add product review (requires authentication)
  Future<bool> addProductReview(int productId, {
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/products/$productId/reviews',
        data: {
          'rating': rating,
          'comment': comment,
          if (images != null) 'images': images,
        },
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Please login to add a review');
      } else if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Invalid review data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  /// Like a review (requires authentication)
  Future<Map<String, int>> likeReview(int reviewId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/reviews/$reviewId/like',
      );

      if (response.data['success'] == true) {
        return {
          'likes_count': response.data['data']['likes_count'],
          'dislikes_count': response.data['data']['dislikes_count'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to like review');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Please login to like reviews');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to like review: $e');
    }
  }

  /// Dislike a review (requires authentication)
  Future<Map<String, int>> dislikeReview(int reviewId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/reviews/$reviewId/dislike',
      );

      if (response.data['success'] == true) {
        return {
          'likes_count': response.data['data']['likes_count'],
          'dislikes_count': response.data['data']['dislikes_count'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to dislike review');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Please login to dislike reviews');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to dislike review: $e');
    }
  }

  /// Calculate product price with selected options
  Future<Map<String, dynamic>> calculateProductPrice(
    int productId, {
    required int quantity,
    List<int>? selectedOptionIds,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/products/$productId/calculate-price',
        data: {
          'quantity': quantity,
          if (selectedOptionIds != null) 'selected_options': selectedOptionIds,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to calculate price');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Invalid data: ${e.response?.data['message'] ?? 'Validation failed'}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to calculate price: $e');
    }
  }
}
