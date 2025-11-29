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
      id: json['id'] ?? 0,
      customer: json['customer'] != null
          ? CustomerInfo.fromJson(json['customer'])
          : CustomerInfo(id: 0, name: 'عميل'),
      merchant: json['merchant'] != null
          ? MerchantInfo.fromJson(json['merchant'])
          : MerchantInfo(id: 0, name: 'مطعم'),
      restaurant: json['restaurant'] != null
          ? RestaurantInfo.fromJson(json['restaurant'])
          : RestaurantInfo(id: 0, businessName: 'مطعم'),
      orderId: json['order_id'],
      conversationType: json['conversation_type'] ?? 'order_chat',
      productDetails: json['product_details'],
      status: json['status'] ?? 'active',
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      // Support both customer_unread_count and merchant_unread_count
      unreadCount: json['merchant_unread_count'] ??
          json['customer_unread_count'] ??
          json['unread_count'] ??
          0,
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
    // Handle name which could be String or Map
    String name = 'عميل';
    final nameData = json['name'];
    if (nameData is String) {
      name = nameData;
    } else if (nameData is Map) {
      name = nameData['current']?.toString() ??
          nameData['ar']?.toString() ??
          nameData['en']?.toString() ??
          'عميل';
    }

    return CustomerInfo(
      id: json['id'] ?? 0,
      name: name,
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
    // Handle name which could be String or Map
    String name = 'مطعم';
    final nameData = json['name'];
    if (nameData is String) {
      name = nameData;
    } else if (nameData is Map) {
      name = nameData['current']?.toString() ??
          nameData['ar']?.toString() ??
          nameData['en']?.toString() ??
          'مطعم';
    }

    return MerchantInfo(
      id: json['id'] ?? 0,
      name: name,
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
      id: json['id'] ?? 0,
      businessName: json['business_name'] is String
          ? json['business_name']
          : json['business_name']?['ar'] ??
              json['business_name']?['en'] ??
              'مطعم',
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
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      repliedToMessageId: json['replied_to_message_id'],
      repliedToMessage: json['replied_to_message'] != null
          ? RepliedMessageModel.fromJson(json['replied_to_message'])
          : null,
      senderType: json['sender_type'] ?? 'customer',
      senderId: json['sender_id'] ?? 0,
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

  /// Create from Firestore document
  factory MessageModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return MessageModel(
      id: int.tryParse(docId) ?? 0,
      conversationId: data['conversation_id'] ?? 0,
      repliedToMessageId: data['replied_to_message_id'],
      repliedToMessage: null,
      senderType: data['sender_type'] ?? 'customer',
      senderId: data['sender_id'] ?? 0,
      message: data['message'] ?? '',
      messageType: data['message_type'] ?? 'text',
      attachments: data['attachments'],
      isReadByCustomer: data['is_read_by_customer'] ?? false,
      isReadByMerchant: data['is_read_by_merchant'] ?? false,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as dynamic).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'conversation_id': conversationId,
      'replied_to_message_id': repliedToMessageId,
      'sender_type': senderType,
      'sender_id': senderId,
      'message': message,
      'message_type': messageType,
      'attachments': attachments,
      'is_read_by_customer': isReadByCustomer,
      'is_read_by_merchant': isReadByMerchant,
      'created_at': createdAt,
    };
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
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      attachments: json['attachments'],
      senderType: json['sender_type'] ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
