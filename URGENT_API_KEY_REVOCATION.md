# 🚨 URGENT: API Key Revocation Required

## ⚠️ Security Alert

The Google Maps API key was accidentally exposed in the GitHub repository. **You must revoke it immediately and create a new one.**

---

## 🔴 Step 1: Revoke the Exposed API Key

1. Go to [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)
2. Find the API key: `AIzaSyAE8QqJfHHu_KHxyNeBZ418O1ymMmQrWcM`
3. Click on the key name
4. Click **DELETE** or **REGENERATE KEY**
5. Confirm the deletion

**Why?** The key was exposed in Git history and could be used by unauthorized parties.

---

## 🟢 Step 2: Create a New API Key

1. In Google Cloud Console, click **Create Credentials** → **API Key**
2. Copy the new API key
3. Click **RESTRICT KEY** (very important!)

### Restrict the Key:

#### Application Restrictions:
- Select **Android apps**
- Add your package name: `com.example.mrsheaf`
- Add your SHA-1 certificate fingerprint (see below)

#### API Restrictions:
- Select **Restrict key**
- Enable only these APIs:
  - ✅ Maps SDK for Android
  - ✅ Maps SDK for iOS
  - ✅ Geocoding API
  - ✅ Places API (optional)

---

## 🔑 Step 3: Get SHA-1 Certificate Fingerprint

### For Debug Build:

```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** under `Variant: debug` → `Config: debug`

### Alternative Method (using keytool):

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA-1** fingerprint.

---

## 📝 Step 4: Update Your .env File

1. Open `mrchef/.env`
2. Replace the old key with the new one:

```env
GOOGLE_MAPS_API_KEY=your_new_api_key_here
```

3. Save the file

---

## 🧪 Step 5: Test the New Key

1. Stop the app completely
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run the app: `flutter run`
5. Navigate to the location picker screen
6. Verify the map loads correctly

---

## 📊 Step 6: Monitor API Usage

1. Go to [Google Cloud Console - APIs Dashboard](https://console.cloud.google.com/apis/dashboard)
2. Monitor your API usage
3. Set up billing alerts to avoid unexpected charges
4. Review the [Pricing Calculator](https://mapsplatform.google.com/pricing/)

---

## 🔒 Security Best Practices Going Forward

1. ✅ **Never commit `.env` file** - It's now in `.gitignore`
2. ✅ **Always restrict API keys** - Limit by app and API
3. ✅ **Use different keys** for dev and production
4. ✅ **Rotate keys regularly** - Every 90 days recommended
5. ✅ **Monitor usage** - Set up alerts in Google Cloud Console
6. ✅ **Review Git history** - Ensure no other secrets are exposed

---

## 📚 Additional Resources

- [Google Maps API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [Restricting API Keys](https://cloud.google.com/docs/authentication/api-keys#api_key_restrictions)
- [API Key Security](https://cloud.google.com/docs/authentication/api-keys#securing_an_api_key)

---

## ✅ Checklist

- [ ] Revoked the exposed API key in Google Cloud Console
- [ ] Created a new API key
- [ ] Restricted the new key (app + API restrictions)
- [ ] Added SHA-1 fingerprint for Android
- [ ] Updated `.env` file with new key
- [ ] Tested the app with new key
- [ ] Set up billing alerts
- [ ] Verified `.env` is in `.gitignore`

---

**After completing all steps, delete this file to avoid confusion.**

