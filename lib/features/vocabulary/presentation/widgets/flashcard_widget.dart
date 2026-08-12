import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

import '../../domain/entities/vocabulary_word.dart';

class FlashcardWidget extends StatelessWidget {
  final VocabularyWord word;

  const FlashcardWidget({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: c.panelShadow.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: FlipCard(
          flipOnTouch: true,
          direction: FlipDirection.HORIZONTAL,
          side: CardSide.FRONT,
          front: _buildFront(context),
          back: _buildBack(context),
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.cardFaceTop, c.cardFaceBottom],
        ),
        border: Border.all(color: c.panelBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.cardBannerStart, c.cardBannerEnd],
                ),
              ),
            ),
          ),
          Positioned(
            top: -24,
            right: -14,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.blobMid.withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showWordInfo(context),
                borderRadius: BorderRadius.circular(999),
                child: Ink(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.panel,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.panelBorder),
                    boxShadow: [
                      BoxShadow(
                        color: c.panelShadow.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: c.ink.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      word.word,
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: c.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: c.hintSurface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: c.panelBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: c.ink.withValues(alpha: 0.75),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap card to reveal definition',
                        style: TextStyle(
                          color: c.ink.withValues(alpha: 0.74),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.panelBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.cardBackTop, c.cardBackBottom],
        ),
        border: Border.all(color: c.cardBackPanel),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -36,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            bottom: -88,
            left: -34,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        word.word,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Text(
                        'Definition & Example',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildContentCard(
                        c,
                        icon: Icons.menu_book_rounded,
                        label: 'DEFINITION',
                        content: word.definition,
                      ),
                      const SizedBox(height: 14),
                      _buildContentCard(
                        c,
                        icon: Icons.format_quote_rounded,
                        label: 'EXAMPLE',
                        content: '"${word.example}"',
                        isItalic: true,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
                child: const Text(
                  'Tap card to flip back',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    AppColors c, {
    required IconData icon,
    required String label,
    required String content,
    bool isItalic = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 19),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showWordInfo(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    // Built per-frame from the dialog's own context. Building it once up front
    // bakes in the palette that was current at open time, so the body keeps
    // light colours after the system flips to dark (or the reverse) while the
    // dialog is on screen.
    Widget buildContent(BuildContext dialogContext) {
      final c = dialogContext.colors;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoRow(c, 'Part of Speech', word.partOfSpeech),
          const SizedBox(height: 16),
          _buildInfoRow(c, 'Translation', word.chineseTranslation),
        ],
      );
    }

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(
            word.word,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: buildContent(dialogContext),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              // CupertinoDialogAction defaults to the theme's primary colour,
              // which is the teal accent. Dismissal is not an accent action.
              textStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: dialogContext.colors.ink,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            word.word,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: buildContent(dialogContext),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: dialogContext.colors.ink,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(AppColors c, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.hintSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.ink.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: c.ink,
            ),
          ),
        ],
      ),
    );
  }
}
