import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Exposes launch environment (COMPONENT, SCREENSHOT) used to capture README screenshots.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ExampleLaunchEnvironment") {
      let channel = FlutterMethodChannel(name: "glassy_ui_ios_example/launch", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        let environment = ProcessInfo.processInfo.environment
        result(call.method == "environment" ? ["COMPONENT": environment["COMPONENT"], "SCREENSHOT": environment["SCREENSHOT"]] : nil)
      }
    }
  }
}
