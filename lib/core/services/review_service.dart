import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/constants/api_constants.dart';
import 'package:mrsheaf/features/profile/models/review_model.dart';
import 'package:http_parser/http_parser.dart';

/// Service for handling review-related API calls
class ReviewService {
  final ApiClient _apiClient;

  ReviewService() : _apiClient = getx.Get.find<ApiClient>();

  /// Submit a review for a single product
  Future<Map<String, dynamic>> submitProductReview({
    required int productId,
    required int rating,
    String? comment,
    List<File>? images,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      });

      // Add images if any
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          String fileName = images[i].path.split('/').last;
          formData.files.add(
            MapEntry(
              'images[$i]',
              await MultipartFile.fromFile(
                images[i].path,
                filename: fileName,
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
        }
      }

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/products/$productId/reviews',
        data: formData,
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      throw Exception('Failed to submit review: ${e.toString()}');
    }
  }

  /// Submit reviews for an order (multiple products)
  Future<Map<String, dynamic>> submitOrderReviews({
    required int orderId,
    required List<Map<String, dynamic>> reviews,
  }) async {
    try {
      FormData formData = FormData();

      // Add each review to form data
      for (int i = 0; i < reviews.length; i++) {
        final review = reviews[i];
        
        formData.fields.add(MapEntry('reviews[$i][product_id]', review['product_id'].toString()));
        formData.fields.add(MapEntry('reviews[$i][rating]', review['rating'].toString()));
        
        if (review['comment'] != null && review['comment'].toString().isNotEmpty) {
          formData.fields.add(MapEntry('reviews[$i][comment]', review['comment'].toString()));
        }

        // Add images for this review if any
        if (review['images'] != null && review['images'] is List<File>) {
          List<File> images = review['images'] as List<File>;
          for (int j = 0; j < images.length; j++) {
            String fileName = images[j].path.split('/').last;
            formData.files.add(
              MapEntry(
                'reviews[$i][images][$j]',
                await MultipartFile.fromFile(
                  images[j].path,
                  filename: fileName,
                  contentType: MediaType('image', 'jpeg'),
                ),
              ),
            );
          }
        }
      }

      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/orders/$orderId/review',
        data: formData,
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit reviews');
      }
    } catch (e) {
      throw Exception('Failed to submit reviews: ${e.toString()}');
    }
  }

  /// Get customer's reviews
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/customer/shopping/reviews',
      );

      if (response.data['success'] == true) {
        final reviewsData = response.data['data'] as List? ?? [];
        return reviewsData
            .map((json) => ReviewModel.fromApiJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: ${e.toString()}');
    }
  }

  /// Get reviews for a specific product
  Future<List<ReviewModel>> getProductReviews(int productId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/customer/shopping/products/$productId/reviews',
      );

      if (response.data['success'] == true) {
        final reviewsData = response.data['data'] as List? ?? [];
        return reviewsData
            .map((json) => ReviewModel.fromApiJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load product reviews');
      }
    } catch (e) {
      throw Exception('Failed to load product reviews: ${e.toString()}');
    }
  }

  /// Like a review
  Future<void> likeReview(int reviewId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/reviews/$reviewId/like',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to like review');
      }
    } catch (e) {
      throw Exception('Failed to like review: ${e.toString()}');
    }
  }

  /// Dislike a review
  Future<void> dislikeReview(int reviewId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.baseUrl}/customer/shopping/reviews/$reviewId/dislike',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to dislike review');
      }
    } catch (e) {
      throw Exception('Failed to dislike review: ${e.toString()}');
    }
  }
}
