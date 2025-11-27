import 'package:mrsheaf/features/profile/models/order_model.dart';
import 'package:mrsheaf/features/profile/models/order_item_model.dart';

class OrderDetailsModel extends OrderModel {
  final List<OrderItemModel> items;
  final Map<String, dynamic>? deliveryAddress;
  final String? notes;
  final String? rejectionReason;
  final double serviceFee;
  final double discountAmount;
  final String? restaurantLogo;
  final String? restaurantPhone;
  final String? restaurantAddress;

  OrderDetailsModel({
    required super.id,
    required super.orderNumber,
    required super.orderDate,
    required super.quantity,
    required super.totalAmount,
    required super.subtotal,
    required super.deliveryFee,
    required super.taxAmount,
    required super.status,
    required super.paymentStatus,
    required super.paymentMethod,
    super.restaurantName,
    super.restaurantId,
    required super.itemsCount,
    super.estimatedDeliveryTime,
    super.confirmedAt,
    super.deliveredAt,
    super.cancelledAt,
    required this.items,
    this.deliveryAddress,
    this.notes,
    this.rejectionReason,
    required this.serviceFee,
    required this.discountAmount,
    this.restaurantLogo,
    this.restaurantPhone,
    this.restaurantAddress,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    // Parse items
    List<OrderItemModel> itemsList = [];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    return OrderDetailsModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      orderDate: DateTime.parse(json['order_date'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      quantity: json['quantity'] ?? itemsList.fold(0, (sum, item) => sum + item.quantity),
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      serviceFee: double.tryParse(json['service_fee']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      status: _parseStatus(json['status']),
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cash',
      restaurantName: json['restaurant']?['name'] ?? json['restaurant']?['business_name'],
      restaurantId: json['restaurant']?['id'] ?? json['restaurant_id'],
      restaurantLogo: json['restaurant']?['logo'],
      restaurantPhone: json['restaurant']?['phone'],
      restaurantAddress: json['restaurant']?['address'],
      itemsCount: json['items_count'] ?? itemsList.length,
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
      items: itemsList,
      deliveryAddress: json['delivery_address'],
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
    );
  }

  String get formattedServiceFee => '${serviceFee.toStringAsFixed(2)} SAR';
  String get formattedDiscountAmount => '${discountAmount.toStringAsFixed(2)} SAR';
  
  String get deliveryAddressText {
    if (deliveryAddress == null) return 'No address provided';
    return '${deliveryAddress!['address_line_1'] ?? ''}, ${deliveryAddress!['city'] ?? ''}';
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
}

