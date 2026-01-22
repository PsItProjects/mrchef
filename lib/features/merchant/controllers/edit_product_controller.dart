import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/merchant/services/merchant_products_service.dart';
import 'package:mrsheaf/features/merchant/models/merchant_product_model.dart';
import 'package:mrsheaf/features/merchant/widgets/add_option_group_modal.dart';
import 'package:mrsheaf/features/merchant/controllers/merchant_products_controller.dart';
import '../../../core/services/toast_service.dart';

class EditProductController extends GetxController {
  final MerchantProductsService _productsService = MerchantProductsService();
  final ImagePicker _imagePicker = ImagePicker();

  // Product ID being edited
  late int productId;
  final Rx<MerchantProductModel?> currentProduct = Rx<MerchantProductModel?>(null);

  // Form Controllers
  final nameEnController = TextEditingController();
  final nameArController = TextEditingController();
  final descriptionEnController = TextEditingController();
  final descriptionArController = TextEditingController();
  final basePriceController = TextEditingController();
  final discountPercentageController = TextEditingController();
  final preparationTimeController = TextEditingController();
  final caloriesController = TextEditingController();
  final ingredientsController = TextEditingController();

  // Observable States
  final isLoading = false.obs;
  final isPickingImages = false.obs; // Flag to prevent multiple image picker calls
  final selectedImages = <File>[].obs; // New images selected from device
  final existingImages = <String>[].obs; // Existing images from server
  final selectedCategoryId = Rxn<int>();
  final categories = <CategoryModel>[].obs;

  // Boolean Flags
  final isAvailable = true.obs;
  final isFeatured = false.obs;
  final isVegetarian = false.obs;
  final isVegan = false.obs;
  final isGlutenFree = false.obs;
  final isSpicy = false.obs;

  // Option Groups
  final optionGroups = <ProductOptionGroupInput>[].obs;

  // Validation Errors Map
  final validationErrors = <String, String>{}.obs;

  // ScrollController for auto-scrolling to errors
  final scrollController = ScrollController();

  // GlobalKeys for each field to enable scrolling
  final nameEnKey = GlobalKey();
  final nameArKey = GlobalKey();
  final priceKey = GlobalKey();
  final descriptionEnKey = GlobalKey();
  final descriptionArKey = GlobalKey();
  final preparationTimeKey = GlobalKey();
  final caloriesKey = GlobalKey();
  final ingredientsKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    // Get product ID from route parameters
    productId = int.parse(Get.parameters['id'] ?? '0');
    _loadCategories();
    _loadProductData();
  }

  /// Load product data from API
  Future<void> _loadProductData() async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print('📦 EDIT PRODUCT: Loading product $productId...');
      }

      final product = await _productsService.getProduct(productId);

      if (product != null) {
        currentProduct.value = product;
        _populateFormFields(product);

        if (kDebugMode) {
          print('✅ Product loaded: ${product.name}');
        }
      } else {
        ToastService.showError('failed_to_load_product'.tr);
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading product: $e');
      }
      ToastService.showError('failed_to_load_product'.tr);
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  /// Populate form fields with product data
  void _populateFormFields(MerchantProductModel product) {
    // Basic info
    nameEnController.text = product.nameEn;
    nameArController.text = product.nameAr;
    descriptionEnController.text = product.descriptionEn ?? '';
    descriptionArController.text = product.descriptionAr ?? '';

    // Pricing
    basePriceController.text = product.basePrice.toString();
    discountPercentageController.text = product.discountPercentage?.toString() ?? '';
    preparationTimeController.text = product.preparationTime.toString();

    // Details
    caloriesController.text = product.calories?.toString() ?? '';
    if (product.ingredients != null && product.ingredients!.isNotEmpty) {
      ingredientsController.text = product.ingredients!.join(', ');
    }

    // Category
    selectedCategoryId.value = product.categoryId;

    // Flags
    isAvailable.value = product.isAvailable;
    isFeatured.value = product.isFeatured;
    isVegetarian.value = product.isVegetarian;
    isVegan.value = product.isVegan;
    isGlutenFree.value = product.isGlutenFree;
    isSpicy.value = product.isSpicy;

    // Images
    existingImages.value = product.images.toList();

    // Option Groups
    optionGroups.value = product.optionGroups.map((og) {
      return ProductOptionGroupInput(
        nameEn: og.nameEn,
        nameAr: og.nameAr,
        type: og.type,
        isRequired: og.isRequired,
        minSelections: og.minSelections,
        maxSelections: og.maxSelections,
        options: og.options.map((opt) {
          return ProductOptionInput(
            nameEn: opt.nameEn,
            nameAr: opt.nameAr,
            priceModifier: opt.priceModifier,
            isAvailable: true,
            sortOrder: 0,
          );
        }).toList(),
      );
    }).toList();

    if (kDebugMode) {
      print('✅ Form fields populated');
      print('   Existing images: ${existingImages.length}');
      print('   Option groups: ${optionGroups.length}');
    }
  }

  @override
  void onClose() {
    nameEnController.dispose();
    nameArController.dispose();
    descriptionEnController.dispose();
    descriptionArController.dispose();
    basePriceController.dispose();
    discountPercentageController.dispose();
    preparationTimeController.dispose();
    caloriesController.dispose();
    ingredientsController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Clear validation error for a specific field
  void clearFieldError(String fieldName) {
    validationErrors.remove(fieldName);
    update([fieldName]); // Update GetBuilder with this specific ID
  }

  /// Clear all validation errors
  void clearAllErrors() {
    validationErrors.clear();
  }

  /// Scroll to first error field
  void scrollToFirstError() {
    if (validationErrors.isEmpty) return;

    final firstErrorField = validationErrors.keys.first;
    GlobalKey? targetKey;

    switch (firstErrorField) {
      case 'name_en':
        targetKey = nameEnKey;
        break;
      case 'name_ar':
        targetKey = nameArKey;
        break;
      case 'price':
      case 'base_price':
        targetKey = priceKey;
        break;
      case 'description_en':
        targetKey = descriptionEnKey;
        break;
      case 'description_ar':
        targetKey = descriptionArKey;
        break;
      case 'preparation_time':
        targetKey = preparationTimeKey;
        break;
      case 'calories':
        targetKey = caloriesKey;
        break;
      case 'ingredients_en':
      case 'ingredients_ar':
        targetKey = ingredientsKey;
        break;
    }

    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  /// Load categories from API
  Future<void> _loadCategories() async {
    try {
      // TODO: Implement category loading from API
      // For now, using mock data
      categories.value = [
        CategoryModel(id: 1, nameEn: 'Main Dishes', nameAr: 'الأطباق الرئيسية'),
        CategoryModel(id: 2, nameEn: 'Appetizers', nameAr: 'المقبلات'),
        CategoryModel(id: 3, nameEn: 'Desserts', nameAr: 'الحلويات'),
        CategoryModel(id: 4, nameEn: 'Beverages', nameAr: 'المشروبات'),
      ];
    } catch (e) {
      print('❌ Error loading categories: $e');
    }
  }

  /// Pick images from gallery
  Future<void> pickImages() async {
    // Prevent multiple simultaneous calls
    if (isPickingImages.value) {
      if (kDebugMode) {
        print('⚠️ Image picker is already active, ignoring request');
      }
      return;
    }

    try {
      isPickingImages.value = true;

      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Limit to 10 images total
        final remainingSlots = 10 - selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).map((xFile) => File(xFile.path)).toList();
        selectedImages.addAll(imagesToAdd);

        if (images.length > remainingSlots) {
          ToastService.showWarning('max_images_reached'.tr);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking images: $e');
      }

      // Only show error if it's not the "already_active" error
      if (!e.toString().contains('already_active')) {
        ToastService.showError('image_upload_failed'.tr);
      }
    } finally {
      // Always reset the flag after a delay to ensure cleanup
      Future.delayed(const Duration(milliseconds: 500), () {
        isPickingImages.value = false;
      });
    }
  }

  /// Remove image at index
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  /// Remove existing image
  void removeExistingImage(int index) {
    if (index >= 0 && index < existingImages.length) {
      existingImages.removeAt(index);
    }
  }

  /// Set image at index as primary (move to first position)
  void setAsPrimaryImage(int index) {
    if (index > 0 && index < selectedImages.length) {
      final image = selectedImages.removeAt(index);
      selectedImages.insert(0, image);

      ToastService.showSuccess('primary_image_set'.tr);
    }
  }

  /// Add new option group - Opens modal
  Future<void> addOptionGroup() async {
    final result = await Get.bottomSheet(
      const AddOptionGroupModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );

    if (result != null && result is ProductOptionGroupInput) {
      optionGroups.add(result);
    }
  }

  /// Edit existing option group - Opens modal
  Future<void> editOptionGroup(int index) async {
    if (index < 0 || index >= optionGroups.length) return;

    final result = await Get.bottomSheet(
      AddOptionGroupModal(
        existingGroup: optionGroups[index],
        groupIndex: index,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );

    if (result != null && result is ProductOptionGroupInput) {
      optionGroups[index] = result;
      optionGroups.refresh();
    }
  }

  /// Remove option group at index
  void removeOptionGroup(int index) {
    if (index >= 0 && index < optionGroups.length) {
      Get.dialog(
        AlertDialog(
          title: Text('confirm_delete'.tr),
          content: Text('confirm_delete_option_group'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                optionGroups.removeAt(index);
                Get.back();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('delete'.tr),
            ),
          ],
        ),
      );
    }
  }

  /// Validate form
  bool _validateForm() {
    clearAllErrors();

    // List to track which fields have errors for update
    final List<String> errorFields = [];

    // Validate images (at least one image required - existing or new)
    if (existingImages.isEmpty && selectedImages.isEmpty) {
      ToastService.showError('at_least_one_image_required'.tr);
      return false;
    }

    // Validate category
    if (selectedCategoryId.value == null) {
      validationErrors['category_id'] = 'category_required'.tr;
      errorFields.add('category_id');
    }

    // Validate name
    if (nameEnController.text.trim().isEmpty) {
      validationErrors['name_en'] = 'product_name_required'.tr;
      errorFields.add('name_en');
    }

    // Validate price
    if (basePriceController.text.trim().isEmpty) {
      validationErrors['price'] = 'base_price_required'.tr;
      errorFields.add('price');
    } else {
      // Validate price is a valid number
      final price = double.tryParse(basePriceController.text.trim());
      if (price == null || price <= 0) {
        validationErrors['price'] = 'invalid_price'.tr;
        errorFields.add('price');
      }
    }

    // Validate preparation time
    if (preparationTimeController.text.trim().isEmpty) {
      validationErrors['preparation_time'] = 'preparation_time_required'.tr;
      errorFields.add('preparation_time');
    } else {
      // Validate preparation time is a valid number
      final prepTime = int.tryParse(preparationTimeController.text.trim());
      if (prepTime == null || prepTime <= 0) {
        validationErrors['preparation_time'] = 'invalid_preparation_time'.tr;
        errorFields.add('preparation_time');
      } else if (prepTime > 300) {
        // Validate preparation time max (300 minutes = 5 hours)
        validationErrors['preparation_time'] = 'preparation_time_max_300'.tr;
        errorFields.add('preparation_time');
      }
    }

    // Validate calories if provided (max 9999)
    if (caloriesController.text.trim().isNotEmpty) {
      final calories = int.tryParse(caloriesController.text.trim());
      if (calories != null && calories > 9999) {
        validationErrors['calories'] = 'calories_max_9999'.tr;
        errorFields.add('calories');
      }
    }

    // Update all error fields at once
    if (errorFields.isNotEmpty) {
      update(errorFields);
    }

    // If there are errors, show snackbar and scroll to first error
    if (validationErrors.isNotEmpty) {
      ToastService.showError('validation_error'.tr);
      scrollToFirstError();
      return false;
    }

    return true;
  }

  /// Update product
  Future<void> updateProduct() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      // Calculate price and discount_price
      final basePrice = double.parse(basePriceController.text.trim());
      final discountPercentage = discountPercentageController.text.trim().isEmpty
          ? 0.0
          : double.parse(discountPercentageController.text.trim());

      double? discountPrice;
      if (discountPercentage > 0) {
        discountPrice = basePrice - (basePrice * discountPercentage / 100);
      }

      // Prepare product data matching API expectations
      final productData = {
        // Required fields
        'category_id': selectedCategoryId.value, // ← Fixed: was 'internal_category_id'
        'name_en': nameEnController.text.trim(),
        'price': basePrice, // ← Fixed: was 'base_price'

        // Optional basic info
        'name_ar': nameArController.text.trim().isEmpty
            ? nameEnController.text.trim()
            : nameArController.text.trim(),
        'description_en': descriptionEnController.text.trim().isEmpty
            ? null
            : descriptionEnController.text.trim(),
        'description_ar': descriptionArController.text.trim().isEmpty
            ? null
            : descriptionArController.text.trim(),

        // Pricing
        'discount_price': discountPrice,

        // Other fields
        'preparation_time': int.parse(preparationTimeController.text.trim()),
        'calories': caloriesController.text.trim().isEmpty
            ? null
            : int.parse(caloriesController.text.trim()),

        // Ingredients and allergens as arrays
        'ingredients_en': ingredientsController.text.trim().isEmpty
            ? null
            : ingredientsController.text.trim().split(',').map((e) => e.trim()).toList(),
        'ingredients_ar': ingredientsController.text.trim().isEmpty
            ? null
            : ingredientsController.text.trim().split(',').map((e) => e.trim()).toList(),

        // Boolean flags
        'is_available': isAvailable.value,
        'is_featured': isFeatured.value,
        'is_vegetarian': isVegetarian.value,
        'is_vegan': isVegan.value,
        'is_gluten_free': isGlutenFree.value,
        'is_spicy': isSpicy.value,

        // Sort order
        'sort_order': 0,
      };

      // Remove null values to avoid sending unnecessary data
      productData.removeWhere((key, value) => value == null);

      // Upload new images if any and combine with existing
      List<String> allImagePaths = List.from(existingImages);
      if (selectedImages.isNotEmpty) {
        print('📤 Uploading ${selectedImages.length} new images...');
        final uploadedImagePaths = await _uploadImages(selectedImages);
        print('✅ Uploaded ${uploadedImagePaths.length} images');
        allImagePaths.addAll(uploadedImagePaths);
      }

      if (allImagePaths.isNotEmpty) {
        productData['images'] = allImagePaths;
      }

      // Add option groups if any (only if they have valid data)
      if (optionGroups.isNotEmpty) {
        // Validate each option group
        for (var i = 0; i < optionGroups.length; i++) {
          final group = optionGroups[i];

          if (group.nameEn.isEmpty) {
            isLoading.value = false;
            ToastService.showError('Option group ${i + 1}: Name is required');
            return;
          }

          if (group.options.isEmpty) {
            isLoading.value = false;
            ToastService.showError('Option group "${group.nameEn}": At least one option is required');
            return;
          }
        }

        // Add valid groups with proper sort_order
        final groupsWithSortOrder = optionGroups.asMap().entries.map((entry) {
          final group = entry.value;
          return ProductOptionGroupInput(
            nameEn: group.nameEn,
            nameAr: group.nameAr,
            type: group.type,
            isRequired: group.isRequired,
            minSelections: group.minSelections,
            maxSelections: group.maxSelections,
            sortOrder: entry.key,
            options: group.options.asMap().entries.map((optEntry) {
              final opt = optEntry.value;
              return ProductOptionInput(
                nameEn: opt.nameEn,
                nameAr: opt.nameAr,
                priceModifier: opt.priceModifier,
                isAvailable: opt.isAvailable,
                sortOrder: optEntry.key,
              );
            }).toList(),
          );
        }).toList();

        productData['option_groups'] = groupsWithSortOrder.map((group) => group.toJson()).toList();
      }

      print('📦 Updating product $productId with data: ${productData.keys}');

      final product = await _productsService.updateProduct(productId, productData);

      if (product != null) {
        print('✅ Product updated successfully, navigating to products list...');

        // Show success message
        ToastService.showSuccess('product_updated_successfully'.tr);

        // Wait a bit for the snackbar to show
        await Future.delayed(const Duration(milliseconds: 500));

        // Try to refresh products list if controller exists
        try {
          if (Get.isRegistered<MerchantProductsController>()) {
            final productsController = Get.find<MerchantProductsController>();
            await productsController.refreshProducts();
          }
        } catch (e) {
          print('⚠️ Could not refresh products controller: $e');
        }

        // Navigate back to products list screen (preserve navigation history)
        Get.until((route) => route.settings.name == '/merchant/products' || route.settings.name == '/merchant-home' || route.isFirst);
        
        // If we're not already on products screen, navigate to it
        if (Get.currentRoute != '/merchant/products') {
          Get.toNamed('/merchant/products');
        }
      } else {
        print('❌ Product update returned null');
        ToastService.showError('error_updating_product'.tr);
      }
    } catch (e) {
      print('❌ Error updating product: $e');

      // Try to parse validation errors from API response
      if (e.toString().contains('422')) {
        _handleValidationErrors(e);
      } else {
        // Try to extract and translate error message
        String errorMessage = 'error_updating_product'.tr;

        if (e.toString().contains('DioException')) {
          final errorString = e.toString();

          // Check for specific validation errors and translate them
          if (errorString.contains('Preparation time cannot exceed 300 minutes')) {
            errorMessage = 'Preparation time cannot exceed 300 minutes.'.tr;
          } else if (errorString.contains('calories must not be greater than 9999')) {
            errorMessage = 'The calories must not be greater than 9999.'.tr;
          } else if (errorString.contains('500')) {
            errorMessage = 'server_error'.tr;
          }
        }

        ToastService.showError(errorMessage);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle validation errors from API (422 response)
  void _handleValidationErrors(dynamic error) {
    clearAllErrors();

    try {
      // Try to extract errors from DioException
      final errorString = error.toString();
      final List<String> errorFields = [];

      // Parse the response data if available
      if (errorString.contains('errors:')) {
        // Extract the errors object from the string
        final errorsStart = errorString.indexOf('errors:');
        final errorsSubstring = errorString.substring(errorsStart);

        // Common Laravel validation error field mappings
        final fieldMappings = {
          'name_en': 'name_en',
          'name_ar': 'name_ar',
          'price': 'price',
          'base_price': 'price',
          'description_en': 'description_en',
          'description_ar': 'description_ar',
          'preparation_time': 'preparation_time',
          'calories': 'calories',
          'ingredients_en': 'ingredients_en',
          'ingredients_ar': 'ingredients_ar',
          'category_id': 'category_id',
        };

        // Check each field for errors
        fieldMappings.forEach((apiField, localField) {
          if (errorsSubstring.contains(apiField)) {
            // Extract the error message
            final fieldStart = errorsSubstring.indexOf(apiField);
            final fieldSubstring = errorsSubstring.substring(fieldStart);
            final bracketStart = fieldSubstring.indexOf('[');
            final bracketEnd = fieldSubstring.indexOf(']');

            if (bracketStart != -1 && bracketEnd != -1) {
              final errorMsg = fieldSubstring.substring(bracketStart + 1, bracketEnd);
              validationErrors[localField] = errorMsg.replaceAll('"', '').trim();
              errorFields.add(localField);
            }
          }
        });
      }

      // Update all error fields at once
      if (errorFields.isNotEmpty) {
        update(errorFields);
      }

      // If we found validation errors, scroll to first error
      if (validationErrors.isNotEmpty) {
        scrollToFirstError();

        ToastService.showError('validation_error'.tr);
      } else {
        // Fallback if we couldn't parse the errors
        ToastService.showError('validation_error'.tr);
      }
    } catch (parseError) {
      print('❌ Error parsing validation errors: $parseError');
      ToastService.showError('validation_error'.tr);
    }
  }

  /// Upload images and return their paths
  Future<List<String>> _uploadImages(List<File> images) async {
    final uploadedPaths = <String>[];

    try {
      for (final image in images) {
        final imagePath = await _productsService.uploadProductImage(image);
        if (imagePath != null) {
          uploadedPaths.add(imagePath);
        }
      }
    } catch (e) {
      print('❌ Error uploading images: $e');
      ToastService.showError('image_upload_failed'.tr);
    }

    return uploadedPaths;
  }
}

// Helper Models
class CategoryModel {
  final int id;
  final String nameEn;
  final String nameAr;

  CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  String get name => Get.locale?.languageCode == 'ar' ? nameAr : nameEn;
}
