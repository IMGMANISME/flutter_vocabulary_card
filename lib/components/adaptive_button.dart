import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isFilled;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AdaptiveButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.icon,
    this.isFilled = true,
    this.color,
    this.textColor,
    this.padding,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    if (isIOS) {
      return _buildCupertinoButton(context);
    } else {
      return _buildMaterialButton();
    }
  }

  Widget _buildCupertinoButton(BuildContext context) {
    // Determine the default color from the Theme
    final defaultColor = color ?? Theme.of(context).primaryColor;

    // If not filled, return standard CupertinoButton (text/icon only)
    if (!isFilled) {
      final content = icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [icon!, const SizedBox(width: 8), child],
            )
          : child;

      return CupertinoButton(
        onPressed: onPressed,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        borderRadius: BorderRadius.circular(borderRadius),
        color: color,
        disabledColor: CupertinoColors.quaternarySystemFill,
        child: IconTheme(
          data: IconThemeData(color: textColor ?? defaultColor),
          child: DefaultTextStyle(
            style: TextStyle(
              color: textColor ?? defaultColor,
              fontWeight: FontWeight.w600,
            ),
            child: content,
          ),
        ),
      );
    }

    // "Liquid Glass" Style for Filled Buttons
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: defaultColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: defaultColor.withOpacity(0.7),
            child: CupertinoButton(
              onPressed: onPressed,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              borderRadius: BorderRadius.circular(borderRadius),
              // Set color to transparent because the Container handles the background color
              color: Colors.transparent,
              disabledColor: CupertinoColors.quaternarySystemFill,
              child: IconTheme(
                data: IconThemeData(color: textColor ?? Colors.white),
                child: icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon!,
                          const SizedBox(width: 8),
                          DefaultTextStyle(
                            style: TextStyle(
                              color: textColor ?? Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            child: child,
                          ),
                        ],
                      )
                    : DefaultTextStyle(
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        child: child,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialButton() {
    final style = ElevatedButton.styleFrom(
      backgroundColor: isFilled ? color : Colors.transparent,
      foregroundColor: textColor ?? (isFilled ? Colors.white : color),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      elevation: isFilled ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: !isFilled && color != null
            ? BorderSide(color: color!.withOpacity(0.5))
            : BorderSide.none,
      ),
    );

    if (icon != null) {
      if (isFilled) {
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon!,
          label: child,
          style: style,
        );
      } else {
        return TextButton.icon(
          onPressed: onPressed,
          icon: icon!,
          label: child,
          style: style,
        );
      }
    } else {
      if (isFilled) {
        return ElevatedButton(onPressed: onPressed, style: style, child: child);
      } else {
        return TextButton(
          onPressed: onPressed,
          style: style, // TextButton style is slightly different but compatible
          child: child,
        );
      }
    }
  }
}
