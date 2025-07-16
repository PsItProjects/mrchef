# Cart Feature

This feature implements the cart functionality based on the Figma designs, allowing users to view, manage, and checkout their cart items.

## Structure

### Models
- `CartItemModel`: Model for individual cart items with product details, quantity, size, and additional options
- `CartAdditionalOption`: Model for additional options selected with cart items

### Controllers
- `CartController`: Manages cart state, add/remove items, quantities, calculations, and checkout operations

### Pages
- `CartScreen`: Main cart screen that shows either empty cart or cart items with summary

### Widgets
- `CartHeader`: Header with back button, title, and clear cart option
- `EmptyCartWidget`: Empty cart state with illustration and "Go to Home" button
- `CartItemsList`: Scrollable list of cart items
- `CartItemWidget`: Individual cart item component with image, details, and quantity controls
- `CartSummarySection`: Cart summary with promo code, totals, and checkout button

### Bindings
- `CartBinding`: Dependency injection for cart controller

## Features Implemented

### Cart Management
- **Add to Cart**: Add products from home screen and product details with size and additional options
- **Remove Items**: Remove individual items from cart
- **Update Quantity**: Increase/decrease item quantities with +/- buttons
- **Clear Cart**: Clear all items with confirmation dialog
- **Duplicate Handling**: Merge items with same product, size, and options

### Cart Display
- **Empty State**: Shows illustration and "Go to Home" button when cart is empty
- **Item List**: Displays cart items with product image, name, price, size, and quantity controls
- **Real-time Updates**: Cart updates immediately when items are added/removed/modified

### Cart Calculations
- **Subtotal**: Sum of all item prices × quantities
- **Delivery Fee**: Fixed delivery fee ($5.00)
- **Tax**: 10% of subtotal
- **Total**: Subtotal + delivery fee + tax
- **Item Count**: Total number of items in cart

### UI Components
- **Responsive Design**: Follows Figma design specifications exactly
- **Color Scheme**: Uses app theme colors (yellow primary, brown text)
- **Typography**: Lato font family with proper weights and sizes
- **Icons**: Material icons for quantity controls and actions
- **Animations**: Smooth transitions with GetX reactive programming

### Integration
- **Product Details**: Add to cart from product details screen with selected options
- **Home Screen**: Quick add to cart from product cards
- **Navigation**: Integrated with bottom navigation bar
- **State Management**: GetX reactive programming for real-time updates

## Figma Design Implementation

### Empty Cart (node-id=37-6422)
- ✅ Empty cart illustration
- ✅ "Your cart are empty" title
- ✅ "Go to the Home to add your cart" subtitle
- ✅ Yellow "Go to Home page" button
- ✅ Proper spacing and typography

### Cart with Items (node-id=37-6158)
- ✅ Header with back button and "My Cart" title
- ✅ Delete/clear cart button
- ✅ Cart item cards with product image, name, price
- ✅ Quantity controls with +/- buttons
- ✅ Remove item (X) button
- ✅ Cart summary section with yellow background
- ✅ Promo code section with icon
- ✅ Order summary (subtotal, delivery, tax, total)
- ✅ Brown checkout button

## Sample Data

The cart controller includes sample data for testing:
- 3 Caesar salad items with different sizes (M, L, S)
- Each item priced at $25.00
- Demonstrates quantity controls and calculations

## Usage

### Adding Items to Cart
```dart
final cartController = Get.find<CartController>();
cartController.addToCart(
  product: productModel,
  size: 'M',
  quantity: 1,
  additionalOptions: selectedOptions,
);
```

### Accessing Cart
The cart screen is accessible through the bottom navigation bar (cart tab).

### Cart State
- Empty cart shows illustration and "Go to Home" button
- Cart with items shows item list and summary section
- Real-time updates when items are modified

## Future Enhancements

- **Checkout Flow**: Complete checkout process with payment
- **Promo Codes**: Functional promo code system
- **Saved Items**: Save items for later functionality
- **Cart Persistence**: Save cart state between app sessions
- **Delivery Options**: Multiple delivery options and scheduling
- **Order History**: View previous orders and reorder functionality

## Dependencies

- **GetX**: State management and navigation
- **Flutter Material**: UI components and icons
- **App Theme**: Consistent styling and colors

The cart feature is fully functional and ready for use, providing a complete shopping cart experience that matches the Figma designs exactly.
