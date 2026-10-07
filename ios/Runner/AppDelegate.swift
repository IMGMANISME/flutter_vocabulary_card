import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // The scene's storyboard creates the engine after application launch.
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    GlassPanelFactory.register(with: engineBridge.applicationRegistrar)
  }
}
