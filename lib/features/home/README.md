# Home Feature

This feature implements the home screen with bottom tab navigation based on the Figma design.

## Structure

### Controllers
- `MainController`: Manages bottom navigation state
- `HomeController`: Manages home screen state and data

### Pages
- `MainScreen`: Main container with bottom navigation using awesome_bottom_bar
- `HomeScreen`: Home tab content with all sections
- `CategoriesScreen`: Categories tab placeholder
- `CartScreen`: Cart tab placeholder  
- `FavoritesScreen`: Favorites tab placeholder
- `ProfileScreen`: Profile tab placeholder

### Widgets
- `HomeHeader`: Header with chat and notification icons
- `SearchBarWidget`: Search bar component
- `CategoryFilter`: Category filter tabs (Popular, Vegan, etc.)
- `FeaturedBanner`: Featured content banner with carousel indicators
- `SectionHeader`: Reusable section header with "See All" button
- `KitchenCard`: Kitchen card component for horizontal list
- `ProductCard`: Product card component for best seller and back again sections

### Bindings
- `HomeBinding`: Dependency injection for home controllers

## Features Implemented

✅ Bottom tab navigation with awesome_bottom_bar package
✅ Home screen layout matching Figma design
✅ Header with chat and notification icons
✅ Search bar (tap to show coming soon message)
✅ Category filter with selection state
✅ Featured banner with carousel indicators
✅ Kitchens horizontal scrollable section
✅ Best seller products horizontal scrollable section
✅ Back again products horizontal scrollable section
✅ Add to cart functionality (shows snackbar)
✅ Responsive design without hardcoded dimensions
✅ GetView pattern for controllers
✅ No Stack widget in main UI as requested

## Navigation

The home feature is accessible via the `/home` route and is integrated into the main app navigation flow.

## Design Notes

- Colors and typography match the Figma design
- Uses existing app theme and color scheme
- Implements proper spacing and layout as per Figma
- All interactive elements show appropriate feedback
- Follows the existing project structure and patterns
