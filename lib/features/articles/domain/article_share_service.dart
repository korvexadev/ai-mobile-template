class ArticleShareAnchor {
  const ArticleShareAnchor({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class ArticleShareRequest {
  const ArticleShareRequest({
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.anchor,
  });

  final String title;
  final String summary;
  final String? imageUrl;
  final ArticleShareAnchor anchor;
}

abstract interface class ArticleShareService {
  Future<void> share(ArticleShareRequest request);
}
