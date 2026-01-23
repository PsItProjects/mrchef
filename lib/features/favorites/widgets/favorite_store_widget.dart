import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mrsheaf/features/favorites/models/favorite_store_model.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class FavoriteStoreWidget extends StatelessWidget {
  final FavoriteStoreModel store;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FavoriteStoreWidget({
    super.key,
    required this.store,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      // width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Background image
          Container(
            // width: 380,
            height: 129,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              color: const Color(0xFFC4C4C4),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: store.backgroundImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: store.backgroundImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFC4C4C4),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFACD02)),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFC4C4C4),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFC4C4C4),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
          ),
          
          // Store info section
          Container(
            width: 380,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Store details
                Row(
                  children: [
                    // Store logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFFC4C4C4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: store.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: store.image,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFC4C4C4),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFFC4C4C4),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFC4C4C4),
                                child: const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Store name
                    Container(
                      width: 166,
                      child: Text(
                        store.name,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF262626),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Rating and remove button section
                Row(
                  children: [
                    // Rating section
                    Container(
                      width: 54,
                      height: 26,
                      child: Row(
                        children: [
                          // Star icon
                          Container(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.star,
                              size: 18,
                              color: AppColors.primaryColor,
                            ),
                          ),

                          const SizedBox(width: 4),

                          // Rating text
                          Container(
                            width: 26,
                            height: 26,
                            child: Text(
                              store.rating.toString(),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF262626),
                                letterSpacing: -0.005,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Remove button (heart icon for favorites)
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 24,
                        height: 24,
                        child: const Icon(
                          Icons.favorite,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
