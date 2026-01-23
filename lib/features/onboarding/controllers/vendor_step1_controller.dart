import 'package:get/get.dart';
import 'package:mrsheaf/core/network/api_client.dart';
import 'package:mrsheaf/core/routes/app_routes.dart';
import '../../../core/services/toast_service.dart';

/// Controller for Vendor Step 1: Subscription Plan Selection
class VendorStep1Controller extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Loading state
  final isLoading = false.obs;
  final isLoadingPlans = true.obs;
  final isSubmitting = false.obs;

  // Selected plan index (0: Annual, 1: Half year, 2: Monthly)
  final selectedPlanIndex = 0.obs;

  // Subscription plans from backend
  final subscriptionPlans = <SubscriptionPlan>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptionPlans();
  }

  /// Load subscription plans from backend
  Future<void> loadSubscriptionPlans() async {
    try {
      isLoadingPlans.value = true;

      print('📤 Loading subscription plans...');

      final response = await _apiClient.get('/merchant/onboarding/plans');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Subscription plans loaded successfully');
        print('📥 Response: ${response.data}');

        final data = response.data['data'];
        if (data != null && data['plans'] != null) {
          final plansList = data['plans'] as List;

          subscriptionPlans.value = plansList
              .map((plan) => SubscriptionPlan.fromJson(plan))
              .toList();

          print('✅ Loaded ${subscriptionPlans.length} plans');

          // Auto-select the first plan (usually Annual)
          if (subscriptionPlans.isNotEmpty) {
            selectedPlanIndex.value = 0;
          }
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading subscription plans: $e');

      // Use fallback plans if API fails
      _useFallbackPlans();

      ToastService.showInfo('تم تحميل الباقات الافتراضية');
    } finally {
      isLoadingPlans.value = false;
    }
  }

  /// Use fallback plans if API fails
  void _useFallbackPlans() {
    subscriptionPlans.value = [
      SubscriptionPlan(
        id: 4,
        name: 'Premium Annual',
        price: '299.99 ر.س',
        period: 'Annual',
        durationMonths: 12,
        isRecommended: true,
        isFree: false,
        benefits: [
          'All Premium features included',
          'Enterprise-grade security',
          'Advanced analytics & insights',
          'White-label solutions',
          'Custom integrations',
          'Training and onboarding',
          '24/7 premium support',
          'Early access to new features',
          '50% savings compared to monthly'
        ],
      ),

      SubscriptionPlan(
        id: 2,
        name: 'Premium Monthly',
        price: '29.99 ر.س',
        period: 'Monthly',
        durationMonths: 1,
        isRecommended: false,
        isFree: false,
        benefits: [
          'Unlimited menu items',
          'Advanced analytics and reports',
          'Real-time order notifications',
          'Customer management system',
          'Inventory tracking',
          'Multi-location support',
          'Priority customer support',
          'Custom branding options'
        ],
      ),
      SubscriptionPlan(
        id: 1,
        name: 'Free Plan',
        price: 'Free',
        period: 'Monthly',
        durationMonths: 1,
        isRecommended: false,
        isFree: true,
        benefits: [
          'Basic restaurant management',
          'Up to 10 menu items',
          'Basic order tracking',
          'Email support'
        ],
      ),
    ];
  }

  /// Select a plan by index
  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  /// Get the currently selected plan
  SubscriptionPlan? get selectedPlan {
    if (subscriptionPlans.isEmpty ||
        selectedPlanIndex.value >= subscriptionPlans.length) {
      return null;
    }
    return subscriptionPlans[selectedPlanIndex.value];
  }

  /// Submit selected subscription plan
  Future<void> submitSubscriptionPlan() async {
    final plan = selectedPlan;
    if (plan == null) {
      ToastService.showError('الرجاء اختيار باقة');
      return;
    }

    try {
      isSubmitting.value = true;

      print('📤 Submitting subscription plan: ${plan.name} (ID: ${plan.id})');

      final response = await _apiClient.post(
        '/merchant/onboarding/step1',
        data: {
          'plan_id': plan.id,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Subscription plan selected successfully');
        print('📥 Response: ${response.data}');

        ToastService.showSuccess('تم اختيار الباقة بنجاح');

        // Navigate to next step
        Get.toNamed(AppRoutes.VENDOR_STEP2);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error submitting subscription plan: $e');

      ToastService.showError('حدث خطأ أثناء اختيار الباقة');
    } finally {
      isSubmitting.value = false;
    }
  }
}

/// Subscription Plan Model
class SubscriptionPlan {
  final int id;
  final String name;
  final String price;
  final String period;
  final int durationMonths;
  final bool isRecommended;
  final bool isFree;
  final List<String> benefits;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.durationMonths,
    required this.isRecommended,
    required this.isFree,
    required this.benefits,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Plan',
      price: json['price'] as String? ?? 'Free',
      period: json['period'] as String? ?? 'Monthly',
      durationMonths: json['duration_months'] as int? ?? 1,
      isRecommended: json['is_recommended'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? false,
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'period': period,
      'duration_months': durationMonths,
      'is_recommended': isRecommended,
      'is_free': isFree,
      'benefits': benefits,
    };
  }
}

