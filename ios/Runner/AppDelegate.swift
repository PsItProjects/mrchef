import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load Google Maps API Key from .env file
    let apiKey = loadGoogleMapsApiKey()
    GMSServices.provideAPIKey(apiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func loadGoogleMapsApiKey() -> String {
    // Try to load from .env file
    if let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
       let envContents = try? String(contentsOfFile: envPath, encoding: .utf8) {
      let lines = envContents.components(separatedBy: .newlines)
      for line in lines {
        if line.hasPrefix("GOOGLE_MAPS_API_KEY=") {
          let key = line.replacingOccurrences(of: "GOOGLE_MAPS_API_KEY=", with: "")
          return key.trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }
    }
    // Fallback to empty string if not found
    return ""
  }
}
