import 'package:dio/dio.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/features/product_details/models/product_model.dart';
import 'package:mrsheaf/features/product_details/models/review_model.dart';

class ProductDetailsService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get product details by ID
  Future<ProductModel> getProductDetails(int productId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}${ApiConstants.productDetails(productId)}',
      );

      if (response.data['success'] == true) {
        final productData = response.data['data'];

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
}
