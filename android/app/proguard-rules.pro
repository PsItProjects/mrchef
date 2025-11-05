# Google Maps ProGuard Rules
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.maps.** { *; }
-keep interface com.google.maps.** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Geocoding
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.common.** { *; }

