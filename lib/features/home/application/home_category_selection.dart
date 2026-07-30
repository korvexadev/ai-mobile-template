import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_category_selection.g.dart';

@Riverpod(keepAlive: true)
class HomeCategorySelection extends _$HomeCategorySelection {
  @override
  String? build() => null;

  void select(String categoryId) {
    state = categoryId;
  }
}
