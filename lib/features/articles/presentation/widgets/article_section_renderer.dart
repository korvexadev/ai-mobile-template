import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../../../shared/widgets/mikozi_cached_network_image.dart';
import '../../domain/reader_article.dart';

class ArticleSectionRenderer extends StatelessWidget {
  const ArticleSectionRenderer({required this.section, super.key});

  final ReaderArticleSection section;

  @override
  Widget build(BuildContext context) {
    return switch (section.type) {
      ReaderArticleSectionType.richText => _RichTextSection(body: section.body),
      ReaderArticleSectionType.image => _ImageSection(section: section),
      ReaderArticleSectionType.youtube => _YoutubeSection(
        videoId: section.youtubeVideoId,
        caption: section.caption,
      ),
      ReaderArticleSectionType.advert => _AdvertSection(
        placementCode: section.advertPlacementCode,
      ),
      ReaderArticleSectionType.unsupported => const SizedBox.shrink(),
    };
  }
}

class _RichTextSection extends StatelessWidget {
  const _RichTextSection({required this.body});

  final String? body;

  @override
  Widget build(BuildContext context) {
    final markdown = body?.trim();
    if (markdown == null || markdown.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final paragraph = theme.textTheme.bodyLarge?.copyWith(
      color: AppTheme.ink,
      fontSize: 17,
      height: 1.72,
    );
    return MarkdownBody(
      data: markdown,
      selectable: true,
      softLineBreak: true,
      onTapLink: (text, href, title) {
        _openSafeLink(href);
      },
      styleSheet: MarkdownStyleSheet(
        a: paragraph?.copyWith(
          color: AppTheme.brandRed,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.brandRed,
        ),
        p: paragraph,
        pPadding: const EdgeInsets.only(bottom: AppSpacing.md),
        h1: theme.textTheme.headlineLarge,
        h1Padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        h2: theme.textTheme.headlineMedium,
        h2Padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        h3: theme.textTheme.headlineSmall,
        h3Padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.xs,
        ),
        strong: const TextStyle(fontWeight: FontWeight.w700),
        em: const TextStyle(fontStyle: FontStyle.italic),
        blockSpacing: AppSpacing.sm,
        listIndent: AppSpacing.lg,
        listBullet: paragraph,
        blockquote: paragraph?.copyWith(
          color: AppTheme.muted,
          fontWeight: FontWeight.w600,
        ),
        blockquotePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        blockquoteDecoration: const BoxDecoration(
          color: AppTheme.softSurface,
          border: Border(left: BorderSide(color: AppTheme.brandRed, width: 3)),
        ),
        code: paragraph?.copyWith(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: AppTheme.softSurface,
        ),
        codeblockPadding: const EdgeInsets.all(AppSpacing.md),
        codeblockDecoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
      ),
    );
  }

  Future<void> _openSafeLink(String? value) async {
    final uri = Uri.tryParse(value ?? '');
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.section});

  final ReaderArticleSection section;

  @override
  Widget build(BuildContext context) {
    final url = section.mediaUrl?.trim();
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }
    final caption = section.caption?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: MikoziCachedNetworkImage(
              url: url,
              semanticLabel: section.altText?.trim().isNotEmpty == true
                  ? section.altText!.trim()
                  : caption,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (caption != null && caption.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.muted, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _YoutubeSection extends StatefulWidget {
  const _YoutubeSection({required this.videoId, required this.caption});

  final String? videoId;
  final String? caption;

  @override
  State<_YoutubeSection> createState() => _YoutubeSectionState();
}

class _YoutubeSectionState extends State<_YoutubeSection> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(covariant _YoutubeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _controller?.close();
      _createController();
    }
  }

  void _createController() {
    final videoId = widget.videoId?.trim();
    if (videoId == null || videoId.isEmpty) {
      _controller = null;
      return;
    }
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        playsInline: true,
        privacyEnhancedMode: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    final caption = widget.caption?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
        ),
        if (caption != null && caption.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.muted, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _AdvertSection extends StatelessWidget {
  const _AdvertSection({required this.placementCode});

  final String? placementCode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Advertisement',
      container: true,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 112),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          'ADVERTISEMENT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.muted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}
