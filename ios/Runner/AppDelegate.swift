import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(name: "bubka/local_storage",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup" else { result(FlutterMethodNotImplemented); return }
      do {
        let support = try FileManager.default.url(for: .applicationSupportDirectory,
          in: .userDomainMask, appropriateFor: nil, create: true)
        var folder = support.appendingPathComponent("bubka-data", isDirectory: true)
        guard let path = call.arguments as? String,
              URL(fileURLWithPath: path).standardizedFileURL.path == folder.standardizedFileURL.path else {
          result(FlutterError(code: "INVALID_PATH", message: "Invalid private directory", details: nil)); return
        }
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try folder.setResourceValues(values)
        let checked = try folder.resourceValues(forKeys: [.isExcludedFromBackupKey])
        guard checked.isExcludedFromBackup == true else {
          result(FlutterError(code: "BACKUP_EXCLUSION", message: "Backup exclusion not set", details: nil)); return
        }
        result(nil)
      } catch {
        result(FlutterError(code: "BACKUP_EXCLUSION", message: "Backup exclusion failed", details: nil))
      }
    }

  }
}
