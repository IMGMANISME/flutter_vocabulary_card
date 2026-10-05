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
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.cardBannerStart, c.cardBannerEnd],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 84).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          word.word,
                          style: TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            color: c.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        word.partOfSpeech,
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 28),
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
                        child: Text(
                          'Tap to reveal the meaning',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: c.ink.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton.filledTonal(
              tooltip: 'Word details and reference',
              onPressed: () => _showWordInfo(context),
              icon: const Icon(Icons.info_outline_rounded),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              word.word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              word.partOfSpeech,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
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
              content: word.example,
              isItalic: true,
            ),
            if (word.usageNote.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildContentCard(
                c,
                icon: Icons.lightbulb_outline_rounded,
                label: 'USAGE NOTE',
                content: word.usageNote,
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Tap to return to the word',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
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
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
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
          if (word.chineseTranslation.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(c, 'Translation', word.chineseTranslation),
          ],
          if (word.sourceUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(c, 'Dictionary reference', word.sourceUrl),
          ],
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
          content: SingleChildScrollView(child: buildContent(dialogContext)),
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
          SelectableText(
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
