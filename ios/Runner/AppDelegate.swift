import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  var window: UIWindow?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  @objc func applicationWillResignActive() {
    let privacyView = UIView(frame: window!.bounds)
    privacyView.tag = 999
    privacyView.backgroundColor = UIColor.systemBackground
    let label = UILabel(frame: privacyView.bounds)
    label.text = "PassesBox"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
    label.textColor = UIColor.label
    privacyView.addSubview(label)
    window?.addSubview(privacyView)
  }

  @objc func applicationDidBecomeActive() {
    window?.viewWithTag(999)?.removeFromSuperview()
  }
}
