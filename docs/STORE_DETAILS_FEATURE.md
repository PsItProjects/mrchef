# Store Details Feature Implementation

## Overview
This document describes the implementation of the Store Details feature in the Mr. Chef mobile application. The feature provides users with comprehensive information about restaurants/stores, including working hours, locations, and contact information.

## Feature Components

### 1. Main Store Details Screen
- **File**: `lib/features/store_details/pages/store_details_screen.dart`
- **Description**: Main screen displaying store information, products, and action buttons
- **Key Features**:
  - Store header with background image and profile picture
  - Store information section with name, location, and description
  - Action buttons (Message and More)
  - Product grid with "Add to Cart" functionality
  - Rating display

### 2. Store Details Controller
- **File**: `lib/features/store_details/controllers/store_details_controller.dart`
- **Description**: GetX controller managing state and business logic
- **Key Features**:
  - Store information management
  - Bottom sheet visibility control
  - Working hours data
  - Location data
  - Contact information
  - Product management
  - Notification settings

### 3. Interactive Components

#### Store Header
- **File**: `lib/features/store_details/widgets/store_details_header.dart`
- **Features**:
  - Background image with overlay
  - Navigation controls (back button, heart button)
  - Store name display
  - Circular profile image with yellow border

#### Store Actions Section
- **File**: `lib/features/store_details/widgets/store_actions_section.dart`
- **Features**:
  - Message button (yellow background)
  - More button (three dots) that triggers bottom sheet

#### Store Products Section
- **File**: `lib/features/store_details/widgets/store_products_section.dart`
- **Features**:
  - Product grid layout
  - Product cards with images, names, prices
  - "Add to Cart" buttons
  - Rating display

### 4. Bottom Sheet Modal
- **File**: `lib/features/store_details/widgets/store_info_bottom_sheet.dart`
- **Features**:
  - Draggable scrollable sheet
  - Navigation to detailed sections
  - Notification toggle
  - Block store option

#### Working Hours Section
- **File**: `lib/features/store_details/widgets/working_hours_section.dart`
- **Features**:
  - Day-by-day schedule display
  - Start/End time slots
  - OFF indicator for closed days
  - Responsive design

#### Locations Section
- **File**: `lib/features/store_details/widgets/locations_section.dart`
- **Features**:
  - Map background
  - Location markers with store images
  - Address cards
  - Navigation to map applications

#### Contact Information Section
- **File**: `lib/features/store_details/widgets/contact_info_section.dart`
- **Features**:
  - Phone number with call functionality
  - Email with email client integration
  - WhatsApp integration
  - Facebook page link
  - Custom icons for social platforms

## Navigation Integration

### Route Configuration
- **Route**: `/store-details`
- **File**: `lib/core/routes/app_routes.dart`
- **Binding**: `StoreDetailsBinding`
- **Transition**: Right to left slide

### Usage
```dart
// Navigate to store details
Get.toNamed(AppRoutes.STORE_DETAILS, parameters: {'storeId': 'store123'});
```

## Internationalization

### Supported Languages
- English (en)
- Arabic (ar)

### Translation Keys
- `store_details`: Store Details
- `store_information`: Store Information
- `working_hours`: Working Hours
- `location`: Location
- `contact_information`: Contact Information
- `turn_on_store_notifications`: Turn on store notifications
- `block_store`: Block Store
- `message`: Message
- `all_product`: All Product
- `add_to_cart`: Add to Cart
- `phone_number`: Phone Number
- `email`: Email
- `whatsapp`: WhatsApp
- `facebook`: Facebook
- `start_time`: Start time
- `end_time`: End time
- `off`: OFF
- Day names: `saturday`, `sunday`, `monday`, `tuesday`, `wednesday`, `thursday`, `friday`

## Design Specifications

### Colors
- Primary Yellow: `#FACD02`
- Background: `#F2F2F2`
- Text Primary: `#262626`
- Text Secondary: `#5E5E5E`
- Border: `#E3E3E3`
- Error/Block: `#EB5757`

### Typography
- **Lato**: Primary font for headings and labels
- **Givonic**: Secondary font for descriptions
- **Tajawal**: Product names and prices
- **Roboto**: System text (status bar)

### Layout
- **Store Header**: 333px height
- **Profile Image**: 155px diameter with 4px yellow border
- **Product Cards**: 182px width, responsive grid
- **Bottom Sheet**: Draggable with 50px border radius

## Testing

### Test Coverage
- **File**: `test/features/store_details/store_details_test.dart`
- **Coverage**:
  - Controller initialization
  - State management
  - Bottom sheet functionality
  - Data validation
  - Widget rendering
  - User interactions

### Running Tests
```bash
flutter test test/features/store_details/
```

## Future Enhancements

1. **Real API Integration**: Replace mock data with actual API calls
2. **Map Integration**: Implement Google Maps or Apple Maps
3. **Social Media Integration**: Add actual WhatsApp and Facebook functionality
4. **Push Notifications**: Implement store notification system
5. **Favorites**: Add store to favorites functionality
6. **Reviews**: Add customer reviews and ratings
7. **Photos Gallery**: Add store photos gallery
8. **Menu Integration**: Link to store menu/catalog

## Dependencies

- **GetX**: State management and navigation
- **Flutter SVG**: Icon rendering
- **Flutter**: UI framework

## File Structure
```
lib/features/store_details/
├── controllers/
│   └── store_details_controller.dart
├── pages/
│   └── store_details_screen.dart
├── widgets/
│   ├── store_details_header.dart
│   ├── store_info_section.dart
│   ├── store_actions_section.dart
│   ├── store_products_section.dart
│   ├── store_info_bottom_sheet.dart
│   ├── working_hours_section.dart
│   ├── locations_section.dart
│   └── contact_info_section.dart
└── bindings/
    └── store_details_binding.dart
```
