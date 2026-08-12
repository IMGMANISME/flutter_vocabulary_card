import Flutter
import SwiftUI
import UIKit

/// A bare translucent surface exposed to Flutter as a platform view.
///
/// Platform views cannot host Flutter children, so this is designed to sit at
/// the bottom of a Stack with ordinary Flutter widgets drawn on top: the panel
/// samples whatever Flutter paints *behind* it, and the widgets composite
/// above it.
///
/// iOS 26 renders Liquid Glass, which refracts the content behind it and
/// updates live. Earlier versions fall back to `.ultraThinMaterial`: blur and
/// lift, but no refraction or specular edge.
enum GlassPanelIds {
    static let viewType = "gocab/glass_panel"
}

private struct GlassPanelContent: View {
    let cornerRadius: CGFloat

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Color.clear.glassEffect(
                    .regular,
                    in: .rect(cornerRadius: cornerRadius)
                )
            } else {
                Color.clear
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: cornerRadius)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        // The hosting view must stay transparent: an opaque background would
        // both hide the Flutter layer and starve the effect of anything to
        // sample.
        .background(Color.clear)
    }
}

final class GlassPanelPlatformView: NSObject, FlutterPlatformView {
    private let hostingController: UIHostingController<GlassPanelContent>

    init(frame: CGRect, arguments args: Any?) {
        let params = args as? [String: Any]
        let radius = params?["cornerRadius"] as? Double ?? 24

        hostingController = UIHostingController(
            rootView: GlassPanelContent(cornerRadius: CGFloat(radius))
        )
        super.init()

        hostingController.view.backgroundColor = .clear
        hostingController.view.isOpaque = false
        hostingController.view.frame = frame
    }

    func view() -> UIView {
        hostingController.view
    }
}

final class GlassPanelFactory: NSObject, FlutterPlatformViewFactory {
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        GlassPanelPlatformView(frame: frame, arguments: args)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    static func register(with registrar: FlutterPluginRegistrar) {
        registrar.register(GlassPanelFactory(), withId: GlassPanelIds.viewType)
    }
}
