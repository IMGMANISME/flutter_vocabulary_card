import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A translucent surface rendered by the host platform.
///
/// It draws nothing of its own beyond the surface, and is meant to sit at the
/// bottom of a [Stack] with ordinary Flutter widgets on top — platform views
/// cannot host Flutter children, so composing this way is what lets a native
/// surface sit behind Flutter controls. Controls layered above it stay
/// interactive.
///
/// * iOS 26+ — SwiftUI `.glassEffect(.regular)` (Liquid Glass). Refracts
///   whatever Flutter paints behind it, live.
/// * iOS 15–25 — SwiftUI `.ultraThinMaterial`. Blur and lift, no refraction.
/// * Android — Material 3 tonal surface. Android has no view-level backdrop
///   blur, and imitating glass there reads as foreign, so it expresses the same
///   hierarchy through colour and elevation.
/// * Anything else — a plain translucent [Container], so the widget stays
///   usable in tests and on web/desktop.
class GlassPanel extends StatelessWidget {
  final double cornerRadius;

  const GlassPanel({super.key, this.cornerRadius = 24});

  static const String _viewType = 'gocab/glass_panel';

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _fallback();

    final params = <String, dynamic>{'cornerRadius': cornerRadius};

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _viewType,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.android:
        return AndroidView(
          viewType: _viewType,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return _fallback();
    }
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
    );
  }
}
