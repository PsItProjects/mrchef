import 'package:mrsheaf/core/localization/currency_helper.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic>? productSnapshot;
  final List<dynamic>? customizations;
  final Map<String, dynamic>? optionsSummary;
  final String? specialInstructions;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.productSnapshot,
    this.customizations,
    this.optionsSummary,
    this.specialInstructions,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? json['name'] ?? 'Product',
      productImage: json['product_image'] ?? json['image'],
      quantity: json['quantity'] ?? 1,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      productSnapshot: json['product_snapshot'],
      customizations: json['customizations'],
      optionsSummary: json['options_summary'],
      specialInstructions: json['special_instructions'],
    );
  }

  String get formattedUnitPrice => CurrencyHelper.formatPrice(unitPrice);
  String get formattedTotalPrice => CurrencyHelper.formatPrice(totalPrice);
}

