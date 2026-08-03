class ReaderEntitlement {
  const ReaderEntitlement({
    required this.planName,
    required this.dailyArticleLimit,
    required this.articlesReadToday,
    required this.articlesRemainingToday,
    required this.resetsAt,
    required this.endsAt,
    this.globalFreeAccess = false,
    this.globalFreeAccessEndsAt,
    this.paymentsEnabled = true,
  });

  final String planName;
  final int? dailyArticleLimit;
  final int articlesReadToday;
  final int? articlesRemainingToday;
  final DateTime resetsAt;
  final DateTime? endsAt;
  final bool globalFreeAccess;
  final DateTime? globalFreeAccessEndsAt;
  final bool paymentsEnabled;

  bool get isUnlimited => articlesRemainingToday == null;
}
