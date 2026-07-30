import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../shared/adaptive_ui/adaptive_reader_shell.dart';
import '../../articles/presentation/saved_articles_page.dart';
import '../../profile/presentation/profile_page.dart';
import 'home_page.dart';
import 'reader_tab_pages.dart';

class ReaderShellPage extends StatefulWidget {
  const ReaderShellPage({required this.destination, super.key});

  final ReaderDestination destination;

  @override
  State<ReaderShellPage> createState() => _ReaderShellPageState();
}

enum ReaderDestination {
  home('/home'),
  latest('/latest'),
  saved('/saved'),
  profile('/profile');

  const ReaderDestination(this.location);

  final String location;
}

class _ReaderShellPageState extends State<ReaderShellPage> {
  static const _items = <ReaderNavigationItem>[
    ReaderNavigationItem(
      label: 'Home',
      icon: HugeIconsStrokeRounded.home01,
      symbol: 'house',
      selectedSymbol: 'house.fill',
      iosAssetIcon: 'tab_home',
    ),
    ReaderNavigationItem(
      label: 'Latest',
      icon: HugeIconsStrokeRounded.news01,
      symbol: 'newspaper',
      selectedSymbol: 'newspaper.fill',
      iosAssetIcon: 'tab_latest',
    ),
    ReaderNavigationItem(
      label: 'Saved',
      icon: HugeIconsStrokeRounded.bookmark01,
      symbol: 'bookmark',
      selectedSymbol: 'bookmark.fill',
      iosAssetIcon: 'tab_saved',
    ),
    ReaderNavigationItem(
      label: 'Profile',
      icon: HugeIconsStrokeRounded.user,
      symbol: 'person.crop.circle',
      selectedSymbol: 'person.crop.circle.fill',
      iosAssetIcon: 'tab_profile',
    ),
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.destination.index;
  }

  @override
  void didUpdateWidget(covariant ReaderShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination != widget.destination) {
      _selectedIndex = widget.destination.index;
    }
  }

  void _select(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Widget _buildBody(List<Widget> pages) {
    return Stack(
      children: [
        Offstage(
          offstage: _selectedIndex != ReaderDestination.home.index,
          child: pages[ReaderDestination.home.index],
        ),
        if (_selectedIndex != ReaderDestination.home.index)
          pages[_selectedIndex],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const ReaderPlaceholderTab(
        title: 'Latest',
        subtitle: 'The newest stories.',
      ),
      const SavedArticlesPage(),
      ProfilePage(onOpenSaved: () => _select(ReaderDestination.saved.index)),
    ];
    return AdaptiveReaderShell(
      selectedIndex: _selectedIndex,
      onSelected: _select,
      items: _items,
      body: _buildBody(pages),
    );
  }
}
