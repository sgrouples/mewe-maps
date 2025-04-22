import UIKit
import Flutter
import background_location_tracker
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    BackgroundLocationTrackerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }

    WorkmanagerPlugin.registerTask(withIdentifier: "com.mewe.maps.periodicLocationTask")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
