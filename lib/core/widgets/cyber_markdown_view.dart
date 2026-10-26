/// Cyber Markdown & Rich Text Formatter for ShadowWall AI.
///
/// Intelligently parses raw Markdown (headers ###, bold **, bullets *, dividers ---)
/// into beautiful, native Flutter styled components with zero raw markdown syntax artifacts.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CyberTextFormatter {
  CyberTextFormatter._();

  /// Clean all raw markdown artifacts (** , ###, ---, *) into clean readable text
  static String clean(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1')
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll(RegExp(r'^\s*[\*\-]\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\s*---\s*$', multiLine: true), '')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .trim();
  }
}

class CyberMarkdownView extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final Color? accentColor;

  const CyberMarkdownView({
    super.key,
    required this.text,
    this.baseStyle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // 1. Horizontal Rules (---)
      if (RegExp(r'^---+|\*\*\*+|___+$').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          ),
        );
        continue;
      }

      // 2. Headers (###, ##, #)
      if (line.startsWith('#')) {
        final headerLevel = line.indexOf(' ');
        final headerText = headerLevel != -1
            ? line.substring(headerLevel).trim()
            : line.replaceAll('#', '').trim();

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: accentColor ?? AppColors.primaryCyan,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _stripBold(headerText),
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.darkOnSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 3. Bullet list items (*, -, •)
      if (RegExp(r'^[\*\-\•]\s+').hasMatch(line)) {
        final content = line.replaceFirst(RegExp(r'^[\*\-\•]\s+'), '').trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: accentColor ?? AppColors.primaryCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRichText(content),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 4. Numbered list items (1., 2., etc.)
      final numMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(line);
      if (numMatch != null) {
        final numStr = numMatch.group(1)!;
        final content = numMatch.group(2)!;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: (accentColor ?? AppColors.primaryCyan).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    numStr,
                    style: TextStyle(
                      color: accentColor ?? AppColors.primaryCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRichText(content),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 5. Standard paragraph text with inline bold formatting
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildRichText(line),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  static String _stripBold(String input) {
    return input.replaceAll('**', '').replaceAll('*', '').replaceAll('`', '').trim();
  }

  Widget _buildRichText(String line) {
    final spans = <TextSpan>[];
    final defaultStyle = baseStyle ??
        AppTypography.bodySmall.copyWith(
          color: AppColors.darkOnSurface,
          height: 1.5,
          fontSize: 13,
        );

    final pattern = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`)');
    int lastIndex = 0;

    for (final match in pattern.allMatches(line)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: line.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }

      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        final boldContent = matchedText.substring(2, matchedText.length - 2);
        spans.add(TextSpan(
          text: boldContent,
          style: defaultStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        final codeContent = matchedText.substring(1, matchedText.length - 1);
        spans.add(TextSpan(
          text: ' $codeContent ',
          style: defaultStyle.copyWith(
            color: AppColors.primaryCyan,
            backgroundColor: AppColors.darkSurfaceVariant,
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastIndex),
        style: defaultStyle,
      ));
    }

    if (spans.isEmpty) {
      return Text(line, style: defaultStyle);
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
