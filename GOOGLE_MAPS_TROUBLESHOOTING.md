# 🚨 Google Maps Blank Screen - Troubleshooting Guide

## ❌ Current Error

```
W/m140.euz: urls for epoch -1 not available
I/m140.duy: requestLegend unsuccessful for epoch -1 legend ROADMAP
I/m140.buq: Request m140.jam failed with Status bzb{errorCode=REQUEST_TIMEOUT
```

**Translation:** Google Maps cannot load map tiles because the API key is not properly configured.

---

## ✅ Solution Steps

### Step 1: Enable Billing (CRITICAL!)

**This is the most common cause of the error!**

1. Go to: https://console.cloud.google.com/billing
2. Make sure you have a **billing account** linked to your project
3. Even though Google provides $200 free credit monthly, **you MUST add a credit card**
4. Without billing enabled, Maps SDK will NOT work!

---

### Step 2: Enable Required APIs

Go to: https://console.cloud.google.com/apis/library

Enable these APIs:

1. **Maps SDK for Android** ✅
   - https://console.cloud.google.com/apis/library/maps-android-backend.googleapis.com

2. **Maps SDK for iOS** ✅
   - https://console.cloud.google.com/apis/library/maps-ios-backend.googleapis.com

3. **Geocoding API** ✅
   - https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com

4. **Places API** ✅
   - https://console.cloud.google.com/apis/library/places-backend.googleapis.com

---

### Step 3: Configure API Key

Go to: https://console.cloud.google.com/apis/credentials

Click on your API key: `AIzaSyAvOH-ZezUrfmcPMHj-vf8-eJSypbFxLfI`

#### Option A: No Restrictions (For Testing)

**Application restrictions:**
- Select: **None**

**API restrictions:**
- Select: **Don't restrict key**

Click **SAVE**

#### Option B: Restricted (For Production)

**Application restrictions:**
- Select: **Android apps**
- Click **ADD AN ITEM**
- Package name: `com.example.mrsheaf`
- SHA-1 certificate fingerprint: Get it using:
  ```bash
  cd android
  ./gradlew signingReport
  ```
  Copy the SHA-1 from the output

**API restrictions:**
- Select: **Restrict key**
- Check these APIs:
  - ✅ Maps SDK for Android
  - ✅ Maps SDK for iOS
  - ✅ Geocoding API
  - ✅ Places API

Click **SAVE**

---

### Step 4: Wait for Changes to Propagate

After saving changes, **wait 5-10 minutes** for Google to propagate the changes globally.

---

### Step 5: Test the App

1. **Stop the app completely**
2. Run: `flutter clean`
3. Run: `flutter pub get`
4. Run: `flutter run`
5. Navigate to the location picker screen
6. The map should now load correctly!

---

## 🔍 Verification Checklist

- [ ] Billing account is enabled and linked to the project
- [ ] Credit card is added to billing account
- [ ] Maps SDK for Android is enabled
- [ ] Maps SDK for iOS is enabled
- [ ] Geocoding API is enabled
- [ ] API key restrictions are set correctly (or set to "None" for testing)
- [ ] Waited 5-10 minutes after making changes
- [ ] Ran `flutter clean` and `flutter pub get`
- [ ] Restarted the app completely

---

## 💰 Cost Information

**Don't worry about costs!**

- Google provides **$200 free credit** every month
- This covers approximately:
  - **28,000 map loads** per month (free)
  - **40,000 geocoding requests** per month (free)
- For a small to medium app, you'll likely stay within the free tier

---

## 🆘 Still Not Working?

### Check API Key Status

Go to: https://console.cloud.google.com/apis/dashboard

- Check if there are any **quota exceeded** errors
- Check if there are any **permission denied** errors
- Look at the **API usage** graphs to see if requests are being made

### Check Logcat for Specific Errors

Look for these specific error messages:

1. **"API key not found"** → API key is not configured correctly in AndroidManifest.xml
2. **"This API project is not authorized"** → Billing is not enabled
3. **"REQUEST_TIMEOUT"** → API key restrictions are blocking requests
4. **"PERMISSION_DENIED"** → Required APIs are not enabled

### Create a New API Key

If nothing works, create a completely new API key:

1. Go to: https://console.cloud.google.com/apis/credentials
2. Click **CREATE CREDENTIALS** → **API Key**
3. Copy the new key
4. Update the key in:
   - `mrchef/.env`
   - `mrchef/android/app/src/main/AndroidManifest.xml`
   - `mrchef/ios/Runner/AppDelegate.swift`
5. Set restrictions to **None** for testing
6. Wait 5 minutes
7. Test again

---

## 📞 Need More Help?

If you're still having issues:

1. **Check Google Cloud Console Status Page:**
   - https://status.cloud.google.com/

2. **Check Google Maps Platform Status:**
   - https://status.cloud.google.com/maps-platform/

3. **Review Google Maps Platform Documentation:**
   - https://developers.google.com/maps/documentation/android-sdk/start

4. **Check Stack Overflow:**
   - Search for: "google maps android blank screen REQUEST_TIMEOUT"

---

## 🎯 Quick Fix Summary

**Most likely cause:** Billing not enabled

**Quick fix:**
1. Enable billing: https://console.cloud.google.com/billing
2. Add credit card (required even for free tier)
3. Set API key restrictions to "None"
4. Wait 5 minutes
5. Restart app

**This should fix 90% of cases!**

