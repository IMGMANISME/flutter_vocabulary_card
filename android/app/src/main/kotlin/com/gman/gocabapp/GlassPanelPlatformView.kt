package com.gman.gocabapp

import android.content.Context
import android.view.ContextThemeWrapper
import android.view.View
import com.google.android.material.card.MaterialCardView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

const val GLASS_PANEL_VIEW_TYPE = "gocab/glass_panel"

/**
 * Android counterpart of the iOS glass panel.
 *
 * Android has no view-level backdrop blur — [android.view.View.setRenderEffect]
 * blurs a view's own content and `Window.setBackgroundBlurRadius` works per
 * window — so this does not imitate glass. It uses a Material 3 tonal surface,
 * which expresses the same floating-above-content hierarchy through colour and
 * elevation and reads as native on Android.
 */
class GlassPanelPlatformView(
    context: Context,
    args: Map<*, *>?,
) : PlatformView {

    private val density = context.resources.displayMetrics.density

    // The app runs on a plain framework theme, which Material components reject
    // at inflate time. Scope a Material theme to this view rather than switching
    // the app theme, which would also affect the splash screen.
    private val card = MaterialCardView(
        ContextThemeWrapper(
            context,
            com.google.android.material.R.style.Theme_Material3_DayNight_NoActionBar,
        ),
    ).apply {
        radius = ((args?.get("cornerRadius") as? Number)?.toFloat() ?: 24f) * density
        cardElevation = 6f * density
        setCardBackgroundColor(
            com.google.android.material.color.MaterialColors.getColor(
                this,
                com.google.android.material.R.attr.colorSurfaceContainerHigh,
            ),
        )
    }

    override fun getView(): View = card

    override fun dispose() = Unit
}

class GlassPanelFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        requireNotNull(context) { "GlassPanel platform view needs a Context" }
        return GlassPanelPlatformView(context, args as? Map<*, *>)
    }
}
