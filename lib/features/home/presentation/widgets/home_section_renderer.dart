import 'package:flutter/material.dart';
import '../../domain/homepage.dart';
import 'home_advert_section.dart';
import 'home_categories_section.dart';
import 'home_lead_section.dart';
import 'home_story_carousel_section.dart';
import 'home_story_list_section.dart';

class HomeSectionRenderer extends StatelessWidget {
  const HomeSectionRenderer({
    required this.section,
    required this.onCategorySelected,
    super.key,
  });

  final HomeSection section;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return switch (section.type) {
      HomeSectionType.banner => HomeLeadSection(section: section),
      HomeSectionType.list => HomeStoryListSection(section: section),
      HomeSectionType.horizontalList => HomeStoryCarouselSection(
        section: section,
      ),
      HomeSectionType.advert => HomeAdvertSection(section: section),
      HomeSectionType.categories => HomeCategoriesSection(
        section: section,
        onSelected: onCategorySelected,
      ),
    };
  }
}
