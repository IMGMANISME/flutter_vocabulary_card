import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {

  @MainActor
  func testLaunchCreatesFlutterSceneAndRegistersPlugins() throws {
    let scene = try XCTUnwrap(
      UIApplication.shared.connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
    )
    let window = try XCTUnwrap(scene.windows.first { $0.rootViewController is FlutterViewController })
    let controller = try XCTUnwrap(window.rootViewController as? FlutterViewController)
    let engine = try XCTUnwrap(controller.engine)

    // Check the running engine, rather than only checking the plist. A scene
    // can exist while plugins are still registered against the old delegate.
    XCTAssertTrue(engine.hasPlugin("FLTFirebaseCorePlugin"))
    XCTAssertTrue(engine.hasPlugin("FLTGoogleSignInPlugin"))
    XCTAssertTrue(engine.hasPlugin("SharedPreferencesPlugin"))
  }

}
