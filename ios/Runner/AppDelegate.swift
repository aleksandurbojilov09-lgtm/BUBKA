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
    let updates = FlutterMethodChannel(name: "bubka/updates",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())
    updates.setMethodCallHandler { call, result in
      guard call.method == "install" else { result(FlutterMethodNotImplemented); return }
      do {
        let support = try FileManager.default.url(for: .applicationSupportDirectory,
          in: .userDomainMask, appropriateFor: nil, create: false)
        let folder = support.appendingPathComponent("bubka-data/updates").resolvingSymlinksInPath()
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          result(FlutterError(code: "INVALID_PATH", message: nil, details: nil)); return
        }
        let file = URL(fileURLWithPath: path).resolvingSymlinksInPath()
        guard file.deletingLastPathComponent().path == folder.path,
              file.pathExtension == "ipa", FileManager.default.fileExists(atPath: file.path),
              let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              var controller = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
          result(FlutterError(code: "INVALID_PATH", message: nil, details: nil)); return
        }
        while let presented = controller.presentedViewController { controller = presented }
        let share = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        share.popoverPresentationController?.sourceView = controller.view
        share.popoverPresentationController?.sourceRect = controller.view.bounds
        controller.present(share, animated: true)
        result("opened")
      } catch {
        result(FlutterError(code: "UPDATE_SHARE_FAILED", message: nil, details: nil))
      }
    }
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
