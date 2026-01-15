import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

/// Interactive star rating widget for selecting ratings
class StarRatingWidget extends StatefulWidget {
  /// Current rating value (0.0 to 5.0)
  final double rating;
  
  /// Callback when rating changes
  final ValueChanged<double>? onRatingChanged;
  
  /// Size of each star
  final double starSize;
  
  /// Whether the widget is read-only
  final bool isReadOnly;
  
  /// Color for filled stars
  final Color? activeColor;
  
  /// Color for empty stars
  final Color? inactiveColor;
  
  /// Spacing between stars
  final double spacing;
  
  /// Whether to allow half-star ratings
  final bool allowHalfRating;
  
  /// Whether to show animation
  final bool animateOnTap;

  const StarRatingWidget({
    super.key,
    this.rating = 0.0,
    this.onRatingChanged,
    this.starSize = 40.0,
    this.isReadOnly = false,
    this.activeColor,
    this.inactiveColor,
    this.spacing = 8.0,
    this.allowHalfRating = false,
    this.animateOnTap = true,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with SingleTickerProviderStateMixin {
  late double _currentRating;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _animatingStarIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void didUpdateWidget(StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rating != oldWidget.rating) {
      setState(() {
        _currentRating = widget.rating;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (widget.isReadOnly) return;
    
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();
    
    setState(() {
      _currentRating = index + 1.0;
      _animatingStarIndex = index;
    });
    
    if (widget.animateOnTap) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    
    widget.onRatingChanged?.call(_currentRating);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.primaryColor;
    final inactiveColor = widget.inactiveColor ?? const Color(0xFFE0E0E0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isActive = index < _currentRating;
        final isHalf = widget.allowHalfRating &&
            index == _currentRating.floor() &&
            _currentRating % 1 >= 0.5;

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = _animatingStarIndex == index
                ? _scaleAnimation.value
                : 1.0;

            return GestureDetector(
              onTap: () => _handleTap(index),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isActive
                          ? Icons.star_rounded
                          : (isHalf ? Icons.star_half_rounded : Icons.star_outline_rounded),
                      size: widget.starSize,
                      color: isActive || isHalf ? activeColor : inactiveColor,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Compact star rating display (read-only) for lists
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showRatingText;
  final TextStyle? ratingTextStyle;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 16.0,
    this.activeColor,
    this.inactiveColor,
    this.showRatingText = false,
    this.ratingTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final activeClr = activeColor ?? AppColors.primaryColor;
    final inactiveClr = inactiveColor ?? const Color(0xFFE0E0E0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final isActive = index < rating.floor();
          final isHalf = index == rating.floor() && rating % 1 >= 0.5;

          return Icon(
            isActive
                ? Icons.star_rounded
                : (isHalf ? Icons.star_half_rounded : Icons.star_outline_rounded),
            size: starSize,
            color: isActive || isHalf ? activeClr : inactiveClr,
          );
        }),
        if (showRatingText) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: ratingTextStyle ??
                TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: starSize * 0.9,
                  color: const Color(0xFF262626),
                ),
          ),
        ],
      ],
    );
  }
}

/// Rating labels for each star count
class RatingLabels {
  static String getLabel(int rating, {bool isArabic = false}) {
    if (isArabic) {
      switch (rating) {
        case 1:
          return 'سيء جداً';
        case 2:
          return 'سيء';
        case 3:
          return 'متوسط';
        case 4:
          return 'جيد';
        case 5:
          return 'ممتاز';
        default:
          return '';
      }
    } else {
      switch (rating) {
        case 1:
          return 'Terrible';
        case 2:
          return 'Poor';
        case 3:
          return 'Average';
        case 4:
          return 'Good';
        case 5:
          return 'Excellent';
        default:
          return '';
      }
    }
  }

  static Color getLabelColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFE53935); // Red
      case 2:
        return const Color(0xFFFF7043); // Orange
      case 3:
        return const Color(0xFFFFB300); // Amber
      case 4:
        return const Color(0xFF7CB342); // Light Green
      case 5:
        return const Color(0xFF43A047); // Green
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// Animated star rating with label
class AnimatedStarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double starSize;
  final bool isReadOnly;
  final bool showLabel;

  const AnimatedStarRating({
    super.key,
    this.rating = 0.0,
    this.onRatingChanged,
    this.starSize = 48.0,
    this.isReadOnly = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final ratingInt = rating.round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRatingWidget(
          rating: rating,
          onRatingChanged: onRatingChanged,
          starSize: starSize,
          isReadOnly: isReadOnly,
          spacing: 12,
          animateOnTap: true,
        ),
        if (showLabel && ratingInt > 0) ...[
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              RatingLabels.getLabel(ratingInt, isArabic: isArabic),
              key: ValueKey(ratingInt),
              style: TextStyle(
                fontFamily: isArabic ? 'Tajawal' : 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: RatingLabels.getLabelColor(ratingInt),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
