import 'dart:ui';
import 'package:mrsheaf/core/theme/app_theme.dart';

enum OrderStatus {
  delivered,
  processing,
  canceled,
}

class OrderModel {
  final String orderCode;
  final DateTime orderDate;
  final int quantity;
  final double totalAmount;
  final OrderStatus status;

  OrderModel({
    required this.orderCode,
    required this.orderDate,
    required this.quantity,
    required this.totalAmount,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderCode: json['orderCode'],
      orderDate: DateTime.parse(json['orderDate']),
      quantity: json['quantity'],
      totalAmount: json['totalAmount'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.processing,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderCode': orderCode,
      'orderDate': orderDate.toIso8601String(),
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
    };
  }

  OrderModel copyWith({
    String? orderCode,
    DateTime? orderDate,
    int? quantity,
    double? totalAmount,
    OrderStatus? status,
  }) {
    return OrderModel(
      orderCode: orderCode ?? this.orderCode,
      orderDate: orderDate ?? this.orderDate,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
    );
  }

  // Helper getters
  String get formattedDate {
    return '${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')}/${orderDate.year}';
  }

  String get formattedQuantity => 'Quantity: ${quantity.toString().padLeft(2, '0')}';

  String get formattedAmount => 'Total Amount: \$${totalAmount.toStringAsFixed(0)}';

  String get statusText {
    switch (status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.canceled:
        return 'Canceled';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.delivered:
        return AppColors.successColor;
      case OrderStatus.processing:
        return AppColors.warningColor;
      case OrderStatus.canceled:
        return AppColors.errorColor;
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case OrderStatus.delivered:
        return AppColors.successColor;
      case OrderStatus.processing:
        return AppColors.warningColor;
      case OrderStatus.canceled:
        return AppColors.errorColor;
    }
  }

  Color get statusTextColor {
    switch (status) {
      case OrderStatus.delivered:
        return AppColors.successColor;
      case OrderStatus.processing:
        return AppColors.lightGreyTextColor;
      case OrderStatus.canceled:
        return AppColors.errorColor;
    }
  }
}
