import 'package:flutter/material.dart';

/// Semantic colour tokens for the app.
///
/// Screens read these rather than literal `Color(0x…)` values so that light and
/// dark can diverge in one place. Tokens are named for the role they play, not
/// the colour they happen to be — `panelBorder`, not `lightGrey` — because the
/// dark palette inverts most of the actual values.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Page background, top and bottom of the vertical gradient.
  final Color pageTop;
  final Color pageBottom;

  /// Decorative blobs behind the content. [blobBottomA] and [blobBottomB] sit
  /// under the floating controls and are what the glass panel refracts.
  final Color blobTop;
  final Color blobMid;
  final Color blobBottomA;
  final Color blobBottomB;

  /// Raised card surfaces (header card, flashcard) and their hairline border.
  final Color panel;
  final Color panelBorder;
  final Color panelShadow;

  /// Flashcard face gradient, and the tinted band across its top.
  final Color cardFaceTop;
  final Color cardFaceBottom;
  final Color cardBannerStart;
  final Color cardBannerEnd;

  /// Reverse (definition) side of the flashcard.
  final Color cardBackTop;
  final Color cardBackBottom;
  final Color cardBackPanel;
  final Color cardBackBorder;

  /// Primary text, and the muted variant used for secondary labels.
  final Color ink;
  final Color inkOnDarkCard;

  /// Brand accent, used for progress and active chips.
  final Color accent;
  final Color accentDeep;
  final Color accentSoft;
  final Color accentSoftBorder;

  /// Filled call-to-action (the Next button) and its disabled state.
  final Color actionFill;
  final Color actionFillEnd;
  final Color actionDisabled;
  final Color actionDisabledInk;

  /// Neutral chip / secondary button fill.
  final Color chipFill;
  final Color trackFill;

  /// Subdued surface for inline hints sitting on a card.
  final Color hintSurface;

  /// Destructive affordances.
  final Color danger;
  final Color dangerSurface;
  final Color dangerBorder;

  const AppColors({
    required this.pageTop,
    required this.pageBottom,
    required this.blobTop,
    required this.blobMid,
    required this.blobBottomA,
    required this.blobBottomB,
    required this.panel,
    required this.panelBorder,
    required this.panelShadow,
    required this.cardFaceTop,
    required this.cardFaceBottom,
    required this.cardBannerStart,
    required this.cardBannerEnd,
    required this.cardBackTop,
    required this.cardBackBottom,
    required this.cardBackPanel,
    required this.cardBackBorder,
    required this.ink,
    required this.inkOnDarkCard,
    required this.accent,
    required this.accentDeep,
    required this.accentSoft,
    required this.accentSoftBorder,
    required this.actionFill,
    required this.actionFillEnd,
    required this.actionDisabled,
    required this.actionDisabledInk,
    required this.chipFill,
    required this.trackFill,
    required this.hintSurface,
    required this.danger,
    required this.dangerSurface,
    required this.dangerBorder,
  });

  static const light = AppColors(
    pageTop: Color(0xFFF5F8FC),
    pageBottom: Color(0xFFBFD8DC),
    blobTop: Color(0xFF9CC8E5),
    blobMid: Color(0xFF9EE6D3),
    blobBottomA: Color(0xFF6FB3AA),
    blobBottomB: Color(0xFF8FA9E8),
    panel: Color(0xFFFFFFFF),
    panelBorder: Color(0xFFD4DFED),
    panelShadow: Color(0xFF0F172A),
    cardFaceTop: Color(0xFFFFFFFF),
    cardFaceBottom: Color(0xFFF4F8FD),
    cardBannerStart: Color(0xFFE4ECFF),
    cardBannerEnd: Color(0xFFD9F3EA),
    cardBackTop: Color(0xFF162B45),
    cardBackBottom: Color(0xFF0C1323),
    cardBackPanel: Color(0xFF2A3E5E),
    cardBackBorder: Color(0xFF334155),
    ink: Color(0xFF15243A),
    inkOnDarkCard: Color(0xFFEAF1F9),
    accent: Color(0xFF0F766E),
    accentDeep: Color(0xFF115E59),
    accentSoft: Color(0xFFECF6F4),
    accentSoftBorder: Color(0xFFC9E6E0),
    actionFill: Color(0xFF273A5D),
    actionFillEnd: Color(0xFF0F172A),
    actionDisabled: Color(0xFFF1F5F9),
    actionDisabledInk: Color(0xFF9DA8B8),
    chipFill: Color(0xFFF3F6FA),
    trackFill: Color(0xFFDDE6F1),
    hintSurface: Color(0xFFEAF1F9),
    danger: Color(0xFF8B1E2C),
    dangerSurface: Color(0xFFFDF2F2),
    dangerBorder: Color(0xFFE7D2D2),
  );

  /// Not a mechanical inversion of [light]: surfaces stay slightly lifted from
  /// the page so cards still read as raised, and the accent is brightened
  /// because the light teal loses contrast against dark backgrounds.
  static const dark = AppColors(
    pageTop: Color(0xFF0B1220),
    pageBottom: Color(0xFF10202B),
    blobTop: Color(0xFF2C5A82),
    blobMid: Color(0xFF1F6B5C),
    blobBottomA: Color(0xFF14776B),
    blobBottomB: Color(0xFF2B3E73),
    panel: Color(0xFF17233A),
    panelBorder: Color(0xFF2A3B57),
    panelShadow: Color(0xFF000000),
    cardFaceTop: Color(0xFF1B2942),
    cardFaceBottom: Color(0xFF141F35),
    cardBannerStart: Color(0xFF25355C),
    cardBannerEnd: Color(0xFF1B4A45),
    cardBackTop: Color(0xFF10203A),
    cardBackBottom: Color(0xFF070C18),
    cardBackPanel: Color(0xFF1E2E4C),
    cardBackBorder: Color(0xFF33456A),
    ink: Color(0xFFE6EDF7),
    inkOnDarkCard: Color(0xFFEAF1F9),
    accent: Color(0xFF2DD4BF),
    accentDeep: Color(0xFF14B8A6),
    accentSoft: Color(0xFF14313A),
    accentSoftBorder: Color(0xFF1F5A57),
    actionFill: Color(0xFF3B5C8F),
    actionFillEnd: Color(0xFF24406B),
    actionDisabled: Color(0xFF1B2942),
    actionDisabledInk: Color(0xFF5A6B85),
    chipFill: Color(0xFF1D2B45),
    trackFill: Color(0xFF243550),
    hintSurface: Color(0xFF223250),
    danger: Color(0xFFF87171),
    dangerSurface: Color(0xFF2A1720),
    dangerBorder: Color(0xFF5B2A34),
  );

  @override
  AppColors copyWith({
    Color? pageTop,
    Color? pageBottom,
    Color? blobTop,
    Color? blobMid,
    Color? blobBottomA,
    Color? blobBottomB,
    Color? panel,
    Color? panelBorder,
    Color? panelShadow,
    Color? cardFaceTop,
    Color? cardFaceBottom,
    Color? cardBannerStart,
    Color? cardBannerEnd,
    Color? cardBackTop,
    Color? cardBackBottom,
    Color? cardBackPanel,
    Color? cardBackBorder,
    Color? ink,
    Color? inkOnDarkCard,
    Color? accent,
    Color? accentDeep,
    Color? accentSoft,
    Color? accentSoftBorder,
    Color? actionFill,
    Color? actionFillEnd,
    Color? actionDisabled,
    Color? actionDisabledInk,
    Color? chipFill,
    Color? trackFill,
    Color? hintSurface,
    Color? danger,
    Color? dangerSurface,
    Color? dangerBorder,
  }) {
    return AppColors(
      pageTop: pageTop ?? this.pageTop,
      pageBottom: pageBottom ?? this.pageBottom,
      blobTop: blobTop ?? this.blobTop,
      blobMid: blobMid ?? this.blobMid,
      blobBottomA: blobBottomA ?? this.blobBottomA,
      blobBottomB: blobBottomB ?? this.blobBottomB,
      panel: panel ?? this.panel,
      panelBorder: panelBorder ?? this.panelBorder,
      panelShadow: panelShadow ?? this.panelShadow,
      cardFaceTop: cardFaceTop ?? this.cardFaceTop,
      cardFaceBottom: cardFaceBottom ?? this.cardFaceBottom,
      cardBannerStart: cardBannerStart ?? this.cardBannerStart,
      cardBannerEnd: cardBannerEnd ?? this.cardBannerEnd,
      cardBackTop: cardBackTop ?? this.cardBackTop,
      cardBackBottom: cardBackBottom ?? this.cardBackBottom,
      cardBackPanel: cardBackPanel ?? this.cardBackPanel,
      cardBackBorder: cardBackBorder ?? this.cardBackBorder,
      ink: ink ?? this.ink,
      inkOnDarkCard: inkOnDarkCard ?? this.inkOnDarkCard,
      accent: accent ?? this.accent,
      accentDeep: accentDeep ?? this.accentDeep,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSoftBorder: accentSoftBorder ?? this.accentSoftBorder,
      actionFill: actionFill ?? this.actionFill,
      actionFillEnd: actionFillEnd ?? this.actionFillEnd,
      actionDisabled: actionDisabled ?? this.actionDisabled,
      actionDisabledInk: actionDisabledInk ?? this.actionDisabledInk,
      chipFill: chipFill ?? this.chipFill,
      trackFill: trackFill ?? this.trackFill,
      hintSurface: hintSurface ?? this.hintSurface,
      danger: danger ?? this.danger,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      dangerBorder: dangerBorder ?? this.dangerBorder,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppColors(
      pageTop: mix(pageTop, other.pageTop),
      pageBottom: mix(pageBottom, other.pageBottom),
      blobTop: mix(blobTop, other.blobTop),
      blobMid: mix(blobMid, other.blobMid),
      blobBottomA: mix(blobBottomA, other.blobBottomA),
      blobBottomB: mix(blobBottomB, other.blobBottomB),
      panel: mix(panel, other.panel),
      panelBorder: mix(panelBorder, other.panelBorder),
      panelShadow: mix(panelShadow, other.panelShadow),
      cardFaceTop: mix(cardFaceTop, other.cardFaceTop),
      cardFaceBottom: mix(cardFaceBottom, other.cardFaceBottom),
      cardBannerStart: mix(cardBannerStart, other.cardBannerStart),
      cardBannerEnd: mix(cardBannerEnd, other.cardBannerEnd),
      cardBackTop: mix(cardBackTop, other.cardBackTop),
      cardBackBottom: mix(cardBackBottom, other.cardBackBottom),
      cardBackPanel: mix(cardBackPanel, other.cardBackPanel),
      cardBackBorder: mix(cardBackBorder, other.cardBackBorder),
      ink: mix(ink, other.ink),
      inkOnDarkCard: mix(inkOnDarkCard, other.inkOnDarkCard),
      accent: mix(accent, other.accent),
      accentDeep: mix(accentDeep, other.accentDeep),
      accentSoft: mix(accentSoft, other.accentSoft),
      accentSoftBorder: mix(accentSoftBorder, other.accentSoftBorder),
      actionFill: mix(actionFill, other.actionFill),
      actionFillEnd: mix(actionFillEnd, other.actionFillEnd),
      actionDisabled: mix(actionDisabled, other.actionDisabled),
      actionDisabledInk: mix(actionDisabledInk, other.actionDisabledInk),
      chipFill: mix(chipFill, other.chipFill),
      trackFill: mix(trackFill, other.trackFill),
      hintSurface: mix(hintSurface, other.hintSurface),
      danger: mix(danger, other.danger),
      dangerSurface: mix(dangerSurface, other.dangerSurface),
      dangerBorder: mix(dangerBorder, other.dangerBorder),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
