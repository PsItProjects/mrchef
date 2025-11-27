class ConversationModel {
  final int id;
  final CustomerInfo customer;
  final MerchantInfo merchant;
  final RestaurantInfo restaurant;
  final int? orderId;
  final String conversationType;
  final Map<String, dynamic>? productDetails;
  final String status;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageAt;

  ConversationModel({
    required this.id,
    required this.customer,
    required this.merchant,
    required this.restaurant,
    this.orderId,
    required this.conversationType,
    this.productDetails,
    required this.status,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      customer: CustomerInfo.fromJson(json['customer']),
      merchant: MerchantInfo.fromJson(json['merchant']),
      restaurant: RestaurantInfo.fromJson(json['restaurant']),
      orderId: json['order_id'],
      conversationType: json['conversation_type'] ?? 'order_chat',
      productDetails: json['product_details'],
      status: json['status'] ?? 'active',
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
    );
  }
}

class CustomerInfo {
  final int id;
  final String name;
  final String? avatar;

  CustomerInfo({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'],
      name: json['name'] ?? 'عميل',
      avatar: json['avatar'],
    );
  }
}

class MerchantInfo {
  final int id;
  final String name;
  final String? avatar;

  MerchantInfo({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      id: json['id'],
      name: json['name'] ?? 'مطعم',
      avatar: json['avatar'],
    );
  }
}

class RestaurantInfo {
  final int id;
  final String businessName;
  final String? logo;

  RestaurantInfo({
    required this.id,
    required this.businessName,
    this.logo,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      id: json['id'],
      businessName: json['business_name'] is String
          ? json['business_name']
          : json['business_name']?['ar'] ?? json['business_name']?['en'] ?? 'مطعم',
      logo: json['logo'],
    );
  }
}

class MessageModel {
  final int id;
  final int conversationId;
  final int? repliedToMessageId;
  final RepliedMessageModel? repliedToMessage;
  final String senderType;
  final int senderId;
  final String message;
  final String messageType;
  final Map<String, dynamic>? attachments;
  final bool isReadByCustomer;
  final bool isReadByMerchant;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    this.repliedToMessageId,
    this.repliedToMessage,
    required this.senderType,
    required this.senderId,
    required this.message,
    required this.messageType,
    this.attachments,
    required this.isReadByCustomer,
    required this.isReadByMerchant,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      repliedToMessageId: json['replied_to_message_id'],
      repliedToMessage: json['replied_to_message'] != null
          ? RepliedMessageModel.fromJson(json['replied_to_message'])
          : null,
      senderType: json['sender_type'],
      senderId: json['sender_id'],
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      attachments: json['attachments'],
      isReadByCustomer: json['is_read_by_customer'] ?? false,
      isReadByMerchant: json['is_read_by_merchant'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  bool get isFromCustomer => senderType == 'customer';
  bool get isFromMerchant => senderType == 'merchant';
}

class RepliedMessageModel {
  final int id;
  final String message;
  final String messageType;
  final Map<String, dynamic>? attachments;
  final String senderType;
  final DateTime? createdAt;

  RepliedMessageModel({
    required this.id,
    required this.message,
    required this.messageType,
    this.attachments,
    required this.senderType,
    this.createdAt,
  });

  factory RepliedMessageModel.fromJson(Map<String, dynamic> json) {
    return RepliedMessageModel(
      id: json['id'],
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      attachments: json['attachments'],
      senderType: json['sender_type'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

