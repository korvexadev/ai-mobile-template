import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/article_share_service.dart';

class ArticleFloatingHeader extends StatelessWidget {
  const ArticleFloatingHeader({
    required this.onBack,
    required this.onShare,
    required this.onSave,
    required this.isSaved,
    required this.isSharing,
    required this.isSaving,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<ArticleShareAnchor>? onShare;
  final VoidCallback? onSave;
  final bool isSaved;
  final bool isSharing;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            _HeaderAction(
              buttonKey: const ValueKey('article-back-action'),
              label: 'Back',
              icon: HugeIconsStrokeRounded.arrowLeft01,
              onPressed: (_) => onBack(),
            ),
            const Spacer(),
            _HeaderAction(
              buttonKey: const ValueKey('article-save-action'),
              label: isSaved ? 'Remove saved article' : 'Save article',
              icon: isSaved
                  ? HugeIconsStrokeRounded.bookmarkCheck02
                  : HugeIconsStrokeRounded.bookmark02,
              selected: isSaved,
              busy: isSaving,
              onPressed: onSave == null ? null : (_) => onSave!(),
            ),
            const SizedBox(width: AppSpacing.xs),
            _HeaderAction(
              buttonKey: const ValueKey('article-share-action'),
              label: 'Share article',
              icon: HugeIconsStrokeRounded.share08,
              busy: isSharing,
              onPressed: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.busy = false,
  });

  final Key buttonKey;
  final String label;
  final List<List<dynamic>> icon;
  final ValueChanged<ArticleShareAnchor>? onPressed;
  final bool selected;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppTheme.brandRed : AppTheme.inkOf(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context).withValues(alpha: 0.88),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppTheme.brandRed.withValues(alpha: 0.28)
                : AppTheme.borderOf(context),
          ),
        ),
        child: CupertinoButton(
          key: buttonKey,
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(44),
          onPressed: onPressed == null || busy
              ? null
              : () => onPressed!(_anchorFor(context)),
          child: busy
              ? CupertinoActivityIndicator(color: foreground, radius: 9)
              : HugeIcon(icon: icon, color: foreground, size: 20),
        ),
      ),
    );
  }
}

ArticleShareAnchor _anchorFor(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) {
    return const ArticleShareAnchor(left: 0, top: 0, width: 1, height: 1);
  }
  final origin = box.localToGlobal(Offset.zero);
  return ArticleShareAnchor(
    left: origin.dx,
    top: origin.dy,
    width: box.size.width,
    height: box.size.height,
  );
}
