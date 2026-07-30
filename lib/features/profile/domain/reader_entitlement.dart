class ReaderEntitlement {
  const ReaderEntitlement({
    required this.planName,
    required this.dailyArticleLimit,
    required this.articlesReadToday,
    required this.articlesRemainingToday,
    required this.resetsAt,
    required this.endsAt,
  });

  final String planName;
  final int? dailyArticleLimit;
  final int articlesReadToday;
  final int? articlesRemainingToday;
  final DateTime resetsAt;
  final DateTime? endsAt;

  bool get isUnlimited => articlesRemainingToday == null;
}
