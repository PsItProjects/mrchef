class ReviewModel {
  final int id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> images;
  final int likes;
  final int dislikes;
  final int replies;
  final bool isLiked;
  final bool isDisliked;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.images,
    required this.likes,
    required this.dislikes,
    required this.replies,
    this.isLiked = false,
    this.isDisliked = false,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userName: json['userName'] ?? json['user_name'] ?? 'Anonymous',
      userAvatar: json['userAvatar'] ?? json['user_avatar'] ?? '',
      rating: (json['rating'] ?? 5).toDouble(),
      comment: json['comment'] ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      images: List<String>.from(json['images'] ?? []),
      likes: json['likes'] ?? json['likes_count'] ?? 0,
      dislikes: json['dislikes'] ?? json['dislikes_count'] ?? 0,
      replies: json['replies'] ?? json['replies_count'] ?? 0,
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      isDisliked: json['isDisliked'] ?? json['is_disliked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'images': images,
      'likes': likes,
      'dislikes': dislikes,
      'replies': replies,
      'isLiked': isLiked,
      'isDisliked': isDisliked,
    };
  }

  ReviewModel copyWith({
    int? id,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    DateTime? date,
    List<String>? images,
    int? likes,
    int? dislikes,
    int? replies,
    bool? isLiked,
    bool? isDisliked,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
    );
  }
}
