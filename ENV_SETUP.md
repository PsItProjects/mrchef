# Environment Variables Setup Guide

## 🔐 Security Notice

This project uses environment variables to store sensitive information like API keys. **Never commit the `.env` file to version control!**

---

## 📋 Setup Instructions

### 1. Create `.env` File

Copy the `.env.example` file and rename it to `.env`:

```bash
cp .env.example .env
```

### 2. Add Your API Keys

Open the `.env` file and replace the placeholder values with your actual API keys:

```env
# Google Maps API Key
GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here
```

### 3. Get Your Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API (optional)
4. Go to **APIs & Services** → **Credentials**
5. Click **Create Credentials** → **API Key**
6. Copy the API key and paste it in your `.env` file

### 4. Restrict Your API Key (Recommended)

For security, restrict your API key:

1. In Google Cloud Console, click on your API key
2. Under **Application restrictions**, select:
   - **Android apps** for Android
   - **iOS apps** for iOS
3. Add your app's package name and SHA-1 certificate fingerprint
4. Under **API restrictions**, select **Restrict key** and choose the APIs you enabled

---

## 🔒 Security Best Practices

1. ✅ **Never commit `.env` file** - It's already in `.gitignore`
2. ✅ **Use different keys** for development and production
3. ✅ **Restrict API keys** in Google Cloud Console
4. ✅ **Rotate keys regularly** if they're exposed
5. ✅ **Monitor API usage** in Google Cloud Console

---

## 🚨 What to Do If Your Key Is Exposed

If you accidentally commit your API key to GitHub:

1. **Immediately revoke the key** in Google Cloud Console
2. **Create a new API key**
3. **Update your `.env` file** with the new key
4. **Remove the key from Git history**:
   ```bash
   git filter-branch --force --index-filter \
   "git rm --cached --ignore-unmatch .env" \
   --prune-empty --tag-name-filter cat -- --all
   ```
5. **Force push** to remote:
   ```bash
   git push origin --force --all
   ```

---

## 📝 Files That Use Environment Variables

- `lib/main.dart` - Loads `.env` file on app startup
- `lib/core/constants/api_constants.dart` - Reads Google Maps API key
- `android/app/build.gradle.kts` - Injects key into Android manifest
- `android/app/src/main/AndroidManifest.xml` - Uses key placeholder
- `ios/Runner/AppDelegate.swift` - Loads key for iOS

---

## 🧪 Testing

After setting up your `.env` file:

1. Run `flutter pub get` to ensure dependencies are installed
2. Run the app: `flutter run`
3. Navigate to the location picker screen
4. The map should load correctly with your API key

---

## 💡 Troubleshooting

### Map not loading?

1. Check that `.env` file exists in the project root
2. Verify the API key is correct
3. Ensure the required APIs are enabled in Google Cloud Console
4. Check that the API key is not restricted incorrectly

### "API key not found" error?

1. Make sure you ran `flutter pub get` after creating `.env`
2. Restart the app completely (stop and run again)
3. Check that the `.env` file is in the correct location (project root)

---

## 📚 Additional Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Environment Variables](https://pub.dev/packages/flutter_dotenv)
- [API Key Best Practices](https://cloud.google.com/docs/authentication/api-keys)

