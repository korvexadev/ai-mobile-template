import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_banner_auto_advance.g.dart';

@Riverpod(keepAlive: true)
Duration homeBannerInterval(Ref ref) {
  return const Duration(seconds: 5);
}

@riverpod
Stream<int> homeBannerAutoAdvance(Ref ref, String sectionId) {
  final interval = ref.watch(homeBannerIntervalProvider);
  return Stream<int>.periodic(interval, (tick) => tick);
}
