import 'package:flutter/material.dart';
import 'package:mrsheaf/core/widgets/index.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/core/utils/index.dart';

/// This file demonstrates how to use all the reusable widgets
/// It can be used as a reference for developers
class WidgetShowcase extends StatefulWidget {
  const WidgetShowcase({super.key});

  @override
  State<WidgetShowcase> createState() => _WidgetShowcaseState();
}

class _WidgetShowcaseState extends State<WidgetShowcase> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Widget Showcase',
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Buttons Section
            AppSection(
              title: 'Buttons',
              child: Column(
                children: [
                  AppButton(
                    text: 'Primary Button',
                    onPressed: () => _showSnackBar('Primary button pressed'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Secondary Button',
                    type: AppButtonType.secondary,
                    onPressed: () => _showSnackBar('Secondary button pressed'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Danger Button',
                    type: AppButtonType.danger,
                    onPressed: () => _showSnackBar('Danger button pressed'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Loading Button',
                    isLoading: _isLoading,
                    onPressed: () => _toggleLoading(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppSmallButton(
                          text: 'Small',
                          onPressed: () => _showSnackBar('Small button pressed'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppIconButton(
                        icon: Icons.favorite,
                        onPressed: () => _showSnackBar('Icon button pressed'),
                        tooltip: 'Favorite',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Text Fields Section
            AppSection(
              title: 'Text Fields',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 16),
                  AppPasswordField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 16),
                  AppPhoneField(
                    label: 'Phone Number',
                    hintText: '5XXXXXXXX',
                    controller: _phoneController,
                  ),
                ],
              ),
            ),

            // Cards Section
            AppSection(
              title: 'Cards',
              child: Column(
                children: [
                  AppCard(
                    child: const Text('Basic Card'),
                    padding: const EdgeInsets.all(16),
                    onTap: () => _showSnackBar('Card tapped'),
                  ),
                  const SizedBox(height: 12),
                  KitchenGradientCard(
                    width: double.infinity,
                    height: 120,
                    child: const Center(
                      child: Text(
                        'Kitchen Gradient Card',
                        style: TextStyle(
                          color: AppColors.textLightColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bars Section
            AppSection(
              title: 'Search Bars',
              child: Column(
                children: [
                  AppSearchBar(
                    hintText: 'Search products',
                    onTap: () => _showSnackBar('Search tapped'),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  AppSearchBarWithFilter(
                    hintText: 'Search with filter',
                    onTap: () => _showSnackBar('Search tapped'),
                    onFilterTap: () => _showSnackBar('Filter tapped'),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Filter Chips Section
            AppSection(
              title: 'Filter Chips',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppFilterChip(
                    text: 'Popular',
                    isSelected: true,
                    onTap: () => _showSnackBar('Popular filter tapped'),
                  ),
                  AppFilterChip(
                    text: 'Vegan',
                    onTap: () => _showSnackBar('Vegan filter tapped'),
                    onRemove: () => _showSnackBar('Vegan filter removed'),
                  ),
                  AppFilterChip(
                    text: 'Gluten Free',
                    onTap: () => _showSnackBar('Gluten Free filter tapped'),
                  ),
                ],
              ),
            ),

            // Status Badges Section
            AppSection(
              title: 'Status Badges',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(text: 'Success', type: StatusType.success),
                  StatusBadge(text: 'Error', type: StatusType.error),
                  StatusBadge(text: 'Warning', type: StatusType.warning),
                  StatusBadge(text: 'Info', type: StatusType.info),
                ],
              ),
            ),

            // Social Buttons Section
            AppSection(
              title: 'Social Buttons',
              child: SocialButtonRow(
                onFacebookTap: () => _showSnackBar('Facebook login'),
                onGoogleTap: () => _showSnackBar('Google login'),
                onAppleTap: () => _showSnackBar('Apple login'),
              ),
            ),

            // Theme Controls Section
            AppSection(
              title: 'Theme Controls',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Theme Toggle:', style: AppTheme.bodyStyle),
                      ThemeToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ThemeSelector(),
                ],
              ),
            ),

            // Empty State Section
            AppSection(
              title: 'Empty State',
              child: SizedBox(
                height: 200,
                child: AppEmptyState(
                  icon: Icons.shopping_cart,
                  title: 'No items in cart',
                  subtitle: 'Add some items to get started',
                  action: AppSmallButton(
                    text: 'Browse Products',
                    onPressed: () => _showSnackBar('Browse products'),
                  ),
                ),
              ),
            ),

            // Animations Section
            AppSection(
              title: 'Animations',
              child: Column(
                children: [
                  FadeInAnimation(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Fade In Animation'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideInAnimation(
                    begin: const Offset(1.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.successColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Slide In Animation', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ScaleAnimation(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.errorColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Scale Animation', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading States Section
            AppSection(
              title: 'Loading States',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppSkeletonLoader(width: double.infinity, height: 60),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppSkeletonLoader(width: double.infinity, height: 60),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ProductCardSkeleton(),
                  const SizedBox(height: 12),
                  const ListTileSkeleton(),
                ],
              ),
            ),

            // Notifications Section
            AppSection(
              title: 'Notifications',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppSmallButton(
                    text: 'Success',
                    type: AppButtonType.success,
                    onPressed: () => AppNotifications.showSuccess('Operation completed successfully!'),
                  ),
                  AppSmallButton(
                    text: 'Error',
                    type: AppButtonType.danger,
                    onPressed: () => AppNotifications.showError('Something went wrong!'),
                  ),
                  AppSmallButton(
                    text: 'Warning',
                    onPressed: () => AppNotifications.showWarning('Please check your input!'),
                  ),
                  AppSmallButton(
                    text: 'Info',
                    type: AppButtonType.secondary,
                    onPressed: () => AppNotifications.showInfo('Here is some information'),
                  ),
                ],
              ),
            ),

            // Dialogs Section
            AppSection(
              title: 'Dialogs',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppSmallButton(
                    text: 'Confirm',
                    onPressed: () async {
                      final result = await AppDialog.showConfirmation(
                        title: 'Delete Item',
                        message: 'Are you sure you want to delete this item?',
                      );
                      if (result == true) {
                        AppNotifications.showSuccess('Item deleted!');
                      }
                    },
                  ),
                  AppSmallButton(
                    text: 'Alert',
                    onPressed: () => AppDialog.showAlert(
                      title: 'Information',
                      message: 'This is an alert dialog',
                    ),
                  ),
                  AppSmallButton(
                    text: 'Input',
                    onPressed: () async {
                      final result = await AppDialog.showInput(
                        title: 'Enter Name',
                        hintText: 'Your name',
                        validator: Validators.name,
                      );
                      if (result != null) {
                        AppNotifications.showInfo('Hello, $result!');
                      }
                    },
                  ),
                ],
              ),
            ),

            // Validation Section
            AppSection(
              title: 'Validation Examples',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Email with Validation',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      final error = Validators.email(value);
                      if (error != null) {
                        // Handle validation error
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone with Validation',
                    hintText: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      final error = Validators.phoneNumber(value);
                      if (error != null) {
                        // Handle validation error
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
    
    if (_isLoading) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
