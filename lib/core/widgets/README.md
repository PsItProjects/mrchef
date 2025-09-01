# Core Reusable Widgets

This directory contains reusable UI components that provide consistent styling and behavior across the MrSheaf application.

## 🎨 Available Widgets

### 1. **Buttons (app_button.dart)**
Comprehensive button system with multiple variants.

```dart
AppButton(
  text: 'Primary Button',
  onPressed: () => doSomething(),
  type: AppButtonType.primary,
)

AppSmallButton(text: 'Small', onPressed: () {})
AppIconButton(icon: Icons.favorite, onPressed: () {})
```

**Button Types:**
- `AppButtonType.primary` - Main action buttons
- `AppButtonType.secondary` - Secondary actions
- `AppButtonType.danger` - Destructive actions
- `AppButtonType.success` - Positive actions
- `AppButtonType.outline` - Outlined style

### 2. **Text Fields (app_text_field.dart)**
Form input components with consistent styling.

```dart
AppTextField(
  label: 'Email',
  hintText: 'Enter your email',
  controller: emailController,
)

AppPasswordField(label: 'Password')
AppPhoneField(label: 'Phone Number')
```

### 3. **Cards (app_card.dart)**
Flexible card component with consistent styling and shadows.

```dart
AppCard(
  child: Text('Content'),
  width: 200,
  height: 100,
  borderRadius: 16,
  onTap: () => print('Card tapped'),
)
```

**Specialized Cards:**
- `KitchenGradientCard` - Pre-styled card with kitchen gradient colors

### 2. **CircularIconButton**
Standardized circular buttons with icons, perfect for back buttons, favorites, etc.

```dart
CircularIconButton(
  iconPath: 'assets/icons/heart_icon.svg',
  onTap: () => toggleFavorite(),
  backgroundColor: AppColors.favoriteButtonColor,
  iconColor: AppColors.errorColor,
)
```

### 3. **AppSearchBar**
Consistent search bar component with icon and customizable styling.

```dart
AppSearchBar(
  hintText: 'Search products',
  onTap: () => openSearch(),
)
```

**With Filter:**
```dart
AppSearchBarWithFilter(
  hintText: 'Search products',
  onTap: () => openSearch(),
  onFilterTap: () => openFilters(),
)
```

### 4. **Filter Chips**
Reusable filter and category chips.

```dart
AppFilterChip(
  text: 'Popular',
  isSelected: true,
  onTap: () => selectFilter(),
  onRemove: () => removeFilter(),
)

CategoryFilterChip(
  name: 'Pizza',
  imagePath: 'assets/images/pizza.png',
  isSelected: false,
  onTap: () => selectCategory(),
)
```

### 5. **StatusBadge**
Status indicators with predefined colors and styles.

```dart
StatusBadge(
  text: 'Delivered',
  type: StatusType.success,
)
```

**Available Types:**
- `StatusType.success` - Green
- `StatusType.error` - Red  
- `StatusType.warning` - Yellow
- `StatusType.info` - Primary color

### 6. **TabIndicator**
Simple dot indicator for tabs.

```dart
TabIndicator(
  isSelected: true,
  size: 8,
)
```

### 7. **Social Buttons (social_button.dart)**
Social media login buttons with platform-specific styling.

```dart
SocialButton(
  platform: SocialPlatform.facebook,
  onTap: () => loginWithFacebook(),
)

SocialButtonRow(
  onFacebookTap: () => loginWithFacebook(),
  onGoogleTap: () => loginWithGoogle(),
)

SocialSignInSection(
  title: 'Or continue with',
  onFacebookTap: () => loginWithFacebook(),
  onGoogleTap: () => loginWithGoogle(),
)
```

### 8. **Layout Components (app_layout.dart)**
Common layout patterns and containers.

```dart
AppScaffold(
  title: 'Page Title',
  body: YourContent(),
  showBackButton: true,
)

AppSection(
  title: 'Section Title',
  child: YourContent(),
)

AppListTile(
  leading: Icon(Icons.person),
  title: Text('Profile'),
  onTap: () => openProfile(),
)

AppEmptyState(
  icon: Icons.shopping_cart,
  title: 'No items found',
  subtitle: 'Try adjusting your search',
  action: AppButton(text: 'Retry', onPressed: () {}),
)
```

### 9. **Theme Controls (theme_toggle_button.dart)**
Components for theme management.

```dart
ThemeToggleButton() // Simple toggle button

ThemeSelector() // Full theme selection widget
```

### 10. **Animations (app_animations.dart)**
Smooth animations for better user experience.

```dart
FadeInAnimation(
  duration: Duration(milliseconds: 500),
  child: YourWidget(),
)

SlideInAnimation(
  begin: Offset(0.0, 1.0),
  child: YourWidget(),
)

ScaleAnimation(
  curve: Curves.elasticOut,
  child: YourWidget(),
)

AnimatedListItem(
  index: 0,
  child: YourListItem(),
)

ShimmerLoading(
  child: YourSkeletonWidget(),
)

BounceAnimation(
  onTap: () => handleTap(),
  child: YourButton(),
)
```

### 11. **Loading States (app_loading.dart)**
Comprehensive loading and skeleton components.

```dart
AppLoading(message: 'Loading...')

AppSkeletonLoader(width: 200, height: 20)

ProductCardSkeleton()
KitchenCardSkeleton()
ListTileSkeleton()

AppLoadingOverlay(
  isLoading: true,
  child: YourContent(),
)

PullToRefreshWrapper(
  onRefresh: () async => await refreshData(),
  child: YourScrollableContent(),
)
```

### 12. **Notifications (app_notifications.dart)**
Toast notifications and dialogs.

```dart
// Notifications
AppNotifications.showSuccess('Success message');
AppNotifications.showError('Error message');
AppNotifications.showWarning('Warning message');
AppNotifications.showInfo('Info message');

// Dialogs
final confirmed = await AppDialog.showConfirmation(
  title: 'Delete Item',
  message: 'Are you sure?',
);

await AppDialog.showAlert(
  title: 'Information',
  message: 'This is an alert',
);

final input = await AppDialog.showInput(
  title: 'Enter Name',
  validator: Validators.name,
);

// Bottom Sheets
await AppBottomSheet.show(
  title: 'Options',
  content: YourBottomSheetContent(),
);
```

## 🎯 Design Principles

### Consistency
All widgets follow the same design patterns:
- Consistent border radius (8, 12, 16, 32)
- Standardized shadows and elevations
- Unified color usage from `AppColors`
- Common padding and margin patterns

### Flexibility
Widgets are designed to be flexible:
- Optional parameters for customization
- Sensible defaults that match the design system
- Support for both light and dark themes

### Reusability
Components are built to be reused:
- No hardcoded business logic
- Configurable through parameters
- Composable with other widgets

## 🚀 Usage Guidelines

### Import
```dart
import 'package:mrsheaf/core/widgets/index.dart';
```

### Color Usage
Always use colors from `AppColors` class:
```dart
// ✅ Good
backgroundColor: AppColors.primaryColor

// ❌ Avoid
backgroundColor: Color(0xFFFACD02)
```

### Theme Support
Widgets automatically support both light and dark themes:
```dart
// Colors adapt automatically
color: Theme.of(context).textTheme.bodyLarge?.color
```

### Responsive Design
Consider different screen sizes:
```dart
// Use flexible sizing when possible
width: MediaQuery.of(context).size.width * 0.8
```

## 🔧 Customization

### Extending Widgets
Create specialized versions by extending base widgets:

```dart
class ProductCard extends AppCard {
  ProductCard({required Product product}) : super(
    child: ProductContent(product),
    borderRadius: 32,
    // ... other customizations
  );
}
```

### Theme Customization
Modify `AppTheme` class to change global styling:
- Add new text styles
- Define new button styles  
- Update color schemes

## 📱 Examples

Check the `features/` directory for real-world usage examples of these widgets in action.

## 🛠️ Utilities

### **Validators (core/utils/validators.dart)**
Comprehensive form validation functions.

```dart
// Email validation
String? emailError = Validators.email('user@example.com');

// Password validation (8+ chars, uppercase, lowercase, number)
String? passwordError = Validators.password('MyPassword123');

// Phone validation (Saudi format)
String? phoneError = Validators.phoneNumber('501234567');

// Name validation
String? nameError = Validators.name('John Doe');

// Combine multiple validators
String? error = Validators.combine(value, [
  Validators.required,
  (v) => Validators.minLength(v, 3, 'Name'),
]);
```

### **App Helpers (core/utils/app_helpers.dart)**
Utility functions for common tasks.

```dart
// Date formatting
String formatted = AppHelpers.formatDate(DateTime.now());
String timeAgo = AppHelpers.timeAgo(DateTime.now().subtract(Duration(hours: 2)));

// String manipulation
String capitalized = AppHelpers.capitalize('hello world');
String truncated = AppHelpers.truncate('Long text...', 10);

// Number formatting
String currency = AppHelpers.formatCurrency(99.99);
String number = AppHelpers.formatNumber(1234567);

// Device info
bool isMobile = AppHelpers.isMobile;
double screenWidth = AppHelpers.screenWidth;

// URL launching
await AppHelpers.launchURL('https://example.com');
await AppHelpers.launchEmail('support@example.com');
await AppHelpers.launchPhone('+966501234567');

// Haptic feedback
AppHelpers.lightHaptic();
AppHelpers.mediumHaptic();

// Color manipulation
Color darker = AppHelpers.darken(Colors.blue, 0.2);
Color lighter = AppHelpers.lighten(Colors.blue, 0.2);
```

### **App Constants (core/utils/app_constants.dart)**
Centralized constants and configuration.

```dart
// Design constants
double padding = AppConstants.defaultPadding;
Duration animation = AppConstants.normalAnimation;

// Validation
bool isValidEmail = AppConstants.isValidEmail('test@example.com');
bool isMobileScreen = AppConstants.isMobile(screenWidth);

// Formatting
String formatted = AppConstants.formatCurrency(99.99);
String phone = AppConstants.formatPhone('501234567');
```

## 🎯 **Production Ready Features**

✅ **Complete Component Library** - 50+ reusable widgets
✅ **Advanced Animations** - Smooth transitions and effects
✅ **Loading States** - Skeletons and progress indicators
✅ **Form Validation** - Comprehensive validation system
✅ **Notifications** - Toast messages and dialogs
✅ **Theme System** - Light/dark mode with persistence
✅ **Utility Functions** - Helpers for common tasks
✅ **Constants Management** - Centralized configuration
✅ **Type Safety** - Proper enums and interfaces
✅ **Documentation** - Complete usage examples
