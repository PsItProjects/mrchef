import 'dart:ui';
import 'package:get/get.dart';
import 'package:mrsheaf/core/localization/currency_helper.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

enum OrderStatus {
  pending,
  awaitingCustomerApproval,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  completed, // Customer confirmed delivery
  cancelled,
  rejected,
}

class OrderModel {
  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final int quantity;
  final double totalAmount;
  final double subtotal;
  final double deliveryFee;
  final double taxAmount;
  final OrderStatus status;
  final String paymentStatus;
  final String paymentMethod;
  final String? restaurantName;
  final int? restaurantId;
  final int itemsCount;
  final DateTime? estimatedDeliveryTime;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? customerConfirmedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.quantity,
    required this.totalAmount,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.restaurantName,
    this.restaurantId,
    required this.itemsCount,
    this.estimatedDeliveryTime,
    this.confirmedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.customerConfirmedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toIso8601String()),
      quantity: json['quantity'] ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      status: _parseStatus(json['status']),
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cash',
      restaurantName: json['restaurant']?['name'],
      restaurantId: json['restaurant']?['id'],
      itemsCount: json['items_count'] ?? 0,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.tryParse(json['estimated_delivery_time'])
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'])
          : null,
      customerConfirmedAt: json['customer_confirmed_at'] != null
          ? DateTime.tryParse(json['customer_confirmed_at'])
          : null,
    );
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'awaiting_customer_approval':
        return OrderStatus.awaitingCustomerApproval;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'rejected':
        return OrderStatus.rejected;
      default:
        return OrderStatus.pending;
    }
  }

  // Helper getters
  String get orderCode => orderNumber; // Backward compatibility

  String get formattedDate {
    return '${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')}/${orderDate.year}';
  }

  String get formattedQuantity => '${'quantity'.tr}: ${quantity.toString().padLeft(2, '0')}';

  String get formattedAmount => '${'total_amount'.tr}: ${CurrencyHelper.formatPriceShort(totalAmount)}';

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'pending'.tr;
      case OrderStatus.awaitingCustomerApproval:
        return 'awaiting_customer_approval'.tr;
      case OrderStatus.confirmed:
        return 'confirmed'.tr;
      case OrderStatus.preparing:
        return 'preparing'.tr;
      case OrderStatus.ready:
        return 'ready'.tr;
      case OrderStatus.outForDelivery:
        return 'out_for_delivery'.tr;
      case OrderStatus.delivered:
        return 'awaiting_confirmation'.tr;
      case OrderStatus.completed:
        return 'completed'.tr;
      case OrderStatus.cancelled:
        return 'cancelled'.tr;
      case OrderStatus.rejected:
        return 'rejected'.tr;
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.awaitingCustomerApproval:
        return AppColors.primaryColor; // Yellow - awaiting price approval
      case OrderStatus.delivered:
        return AppColors.warningColor; // Yellow - awaiting confirmation
      case OrderStatus.completed:
        return AppColors.successColor;
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.ready:
      case OrderStatus.outForDelivery:
        return AppColors.warningColor;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return AppColors.errorColor;
    }
  }

  Color get statusBackgroundColor {
    return statusColor;
  }

  Color get statusTextColor {
    switch (status) {
      case OrderStatus.awaitingCustomerApproval:
        return AppColors.primaryColor; // Yellow - awaiting price approval
      case OrderStatus.delivered:
        return AppColors.warningColor; // Yellow - awaiting confirmation
      case OrderStatus.completed:
        return AppColors.successColor;
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.ready:
      case OrderStatus.outForDelivery:
        return AppColors.lightGreyTextColor;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return AppColors.errorColor;
    }
  }

  // Check if order is in "processing" state (for tab filtering)
  bool get isProcessing {
    return status == OrderStatus.pending ||
        status == OrderStatus.awaitingCustomerApproval ||
        status == OrderStatus.confirmed ||
        status == OrderStatus.preparing ||
        status == OrderStatus.ready ||
        status == OrderStatus.outForDelivery;
  }

  // Check if order is cancelled
  bool get isCancelled {
    return status == OrderStatus.cancelled || status == OrderStatus.rejected;
  }

  // Check if order is delivered (awaiting customer confirmation)
  bool get isDelivered {
    return status == OrderStatus.delivered;
  }

  // Check if order is completed (customer confirmed)
  bool get isCompleted {
    return status == OrderStatus.completed;
  }

  // Check if customer can confirm delivery
  bool get canConfirmDelivery {
    return status == OrderStatus.delivered;
  }

  // Check if customer can accept/reject price
  bool get canAcceptOrRejectPrice {
    return status == OrderStatus.awaitingCustomerApproval;
  }

  // Check if customer can review this order
  bool get canReview {
    return status == OrderStatus.completed;
  }
}
