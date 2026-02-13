import 'package:flutter/material.dart';

/// A professional skeleton/shimmer loading widget that mimics
/// the real product details screen layout for a seamless UX.
class ProductDetailsShimmer extends StatefulWidget {
  const ProductDetailsShimmer({super.key});

  @override
  State<ProductDetailsShimmer> createState() => _ProductDetailsShimmerState();
}

class _ProductDetailsShimmerState extends State<ProductDetailsShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmerPosition = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerPosition,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero image area ──
                      Stack(
                        children: [
                          _box(double.infinity, 340, radius: 0),
                          // Back button
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 12,
                            left: 16,
                            child: _circle(40),
                          ),
                          // Favorite button
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 12,
                            right: 16,
                            child: _circle(40),
                          ),
                          // Image counter
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: _box(48, 26, radius: 13),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Name + Price ──
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _box(180, 24, radius: 8),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _box(48, 18, radius: 6),
                                    const SizedBox(height: 6),
                                    _box(80, 24, radius: 8),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── Chips row ──
                            Row(
                              children: [
                                _box(72, 32, radius: 16),
                                const SizedBox(width: 10),
                                _box(115, 32, radius: 16),
                                const SizedBox(width: 10),
                                _box(95, 32, radius: 16),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Description lines ──
                            _box(double.infinity, 13, radius: 6),
                            const SizedBox(height: 10),
                            _box(double.infinity, 13, radius: 6),
                            const SizedBox(height: 10),
                            _box(180, 13, radius: 6),

                            const SizedBox(height: 20),

                            // ── Product code ──
                            _box(130, 11, radius: 4),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // ── Separator ──
                      _divider(),

                      // ── Reviews section ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _box(95, 18, radius: 6),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  _circle(48),
                                  const SizedBox(height: 14),
                                  _box(150, 14, radius: 6),
                                  const SizedBox(height: 10),
                                  _box(100, 12, radius: 6),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom bar ──
              Container(
                padding: EdgeInsets.fromLTRB(
                  20, 14, 20,
                  MediaQuery.of(context).padding.bottom + 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _box(90, 26, radius: 8),
                    const Spacer(),
                    _box(100, 44, radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _box(double.infinity, 48, radius: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  Widget _box(double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: _shimmerGradient(),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _shimmerGradient(),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFF0F0F0),
    );
  }

  LinearGradient _shimmerGradient() {
    final v = _shimmerPosition.value;
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [
        Color(0xFFEEEEEE),
        Color(0xFFF7F7F7),
        Color(0xFFEEEEEE),
      ],
      stops: [
        (v - 1).clamp(0.0, 1.0),
        v.clamp(0.0, 1.0),
        (v + 1).clamp(0.0, 1.0),
      ],
    );
  }
}
