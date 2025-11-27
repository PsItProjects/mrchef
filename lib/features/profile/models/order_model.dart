import 'dart:ui';
import 'package:mrsheaf/core/theme/app_theme.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
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
    );
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
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

  String get formattedQuantity => 'Quantity: ${quantity.toString().padLeft(2, '0')}';

  String get formattedAmount => 'Total Amount: \$${totalAmount.toStringAsFixed(0)}';

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.delivered:
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
      case OrderStatus.delivered:
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
        status == OrderStatus.confirmed ||
        status == OrderStatus.preparing ||
        status == OrderStatus.ready ||
        status == OrderStatus.outForDelivery;
  }

  // Check if order is cancelled
  bool get isCancelled {
    return status == OrderStatus.cancelled || status == OrderStatus.rejected;
  }

  // Check if order is delivered
  bool get isDelivered {
    return status == OrderStatus.delivered;
  }
}
