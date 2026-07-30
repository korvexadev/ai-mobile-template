import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/home_banner_auto_advance.dart';
import '../../domain/homepage.dart';
import '../home_layout.dart';
import 'home_article_image.dart';
import 'home_story_gradient.dart';

class HomeLeadSection extends StatelessWidget {
  const HomeLeadSection({
    required this.section,
    required this.onArticleSelected,
    super.key,
  });

  final HomeSection section;
  final ValueChanged<String> onArticleSelected;

  @override
  Widget build(BuildContext context) {
    if (section.articles.isEmpty) {
      return const SizedBox.shrink();
    }
    if (section.articles.length == 1) {
      return SizedBox(
        height: HomeLayout.leadCardHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeLayout.horizontalPadding,
          ),
          child: _LeadStoryCard(
            article: section.articles.single,
            onPressed: () {
              onArticleSelected(section.articles.single.slug);
            },
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth =
            constraints.maxWidth - HomeLayout.horizontalPadding;
        final cardWidth =
            constraints.maxWidth -
            (HomeLayout.horizontalPadding * 2) -
            HomeLayout.trailingCardPeek;
        final pageExtent = cardWidth + HomeLayout.carouselGap;
        final viewportFraction = (pageExtent / viewportWidth).clamp(0.5, 1.0);
        return _InfiniteLeadCarousel(
          key: ValueKey('${section.id}-${viewportFraction.toStringAsFixed(3)}'),
          section: section,
          viewportFraction: viewportFraction,
          onArticleSelected: onArticleSelected,
        );
      },
    );
  }
}

class _InfiniteLeadCarousel extends ConsumerStatefulWidget {
  const _InfiniteLeadCarousel({
    required this.section,
    required this.viewportFraction,
    required this.onArticleSelected,
    super.key,
  });

  final HomeSection section;
  final double viewportFraction;
  final ValueChanged<String> onArticleSelected;

  @override
  ConsumerState<_InfiniteLeadCarousel> createState() {
    return _InfiniteLeadCarouselState();
  }
}

class _InfiniteLeadCarouselState extends ConsumerState<_InfiniteLeadCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    final articleCount = widget.section.articles.length;
    const seed = 10000;
    final initialPage = seed - (seed % articleCount);
    _controller = PageController(
      initialPage: initialPage,
      viewportFraction: widget.viewportFraction,
    );
  }

  void _advance() {
    final media = MediaQuery.maybeOf(context);
    if (!mounted ||
        !_controller.hasClients ||
        media?.disableAnimations == true) {
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(homeBannerAutoAdvanceProvider(widget.section.id));
    ref.listen(homeBannerAutoAdvanceProvider(widget.section.id), (
      previous,
      next,
    ) {
      if (next.hasValue) {
        _advance();
      }
    });
    return SizedBox(
      height: HomeLayout.leadCardHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: HomeLayout.horizontalPadding),
        child: PageView.builder(
          key: ValueKey('banner-carousel-${widget.section.id}'),
          controller: _controller,
          padEnds: false,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, pageIndex) {
            final articleIndex = pageIndex % widget.section.articles.length;
            final article = widget.section.articles[articleIndex];
            return Padding(
              padding: const EdgeInsets.only(right: HomeLayout.carouselGap),
              child: _LeadStoryCard(
                key: ValueKey('banner-story-${article.id}-$pageIndex'),
                article: article,
                onPressed: () => widget.onArticleSelected(article.slug),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LeadStoryCard extends StatelessWidget {
  const _LeadStoryCard({
    required this.article,
    required this.onPressed,
    super.key,
  });

  final HomeArticle article;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: article.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              HomeArticleImage(
                article: article,
                borderRadius: BorderRadius.zero,
              ),
              HomeStoryGradient(article: article, large: true),
            ],
          ),
        ),
      ),
    );
  }
}
