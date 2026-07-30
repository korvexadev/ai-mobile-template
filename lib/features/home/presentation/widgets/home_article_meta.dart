import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/homepage.dart';

class HomeArticleMeta extends StatelessWidget {
  const HomeArticleMeta({
    required this.article,
    this.onDark = false,
    super.key,
  });

  final HomeArticle article;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark
        ? Colors.white.withValues(alpha: 0.82)
        : AppTheme.muted;
    return Text(
      _label(article),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _label(HomeArticle value) {
    final time = _relativeTime(value.publishedAt);
    return time == null
        ? value.category.name
        : '${value.category.name}  ·  $time';
  }

  String? _relativeTime(DateTime? publishedAt) {
    if (publishedAt == null) {
      return null;
    }
    final elapsed = DateTime.now().toUtc().difference(publishedAt.toUtc());
    if (elapsed.isNegative || elapsed.inMinutes < 1) {
      return 'Now';
    }
    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} min';
    }
    if (elapsed.inHours < 24) {
      return '${elapsed.inHours} hr';
    }
    if (elapsed.inDays < 7) {
      return '${elapsed.inDays} d';
    }
    final month = publishedAt.month.toString().padLeft(2, '0');
    final day = publishedAt.day.toString().padLeft(2, '0');
    return '$day/$month/${publishedAt.year}';
  }
}
