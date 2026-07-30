import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../shared/adaptive_ui/adaptive_reader_shell.dart';
import 'home_page.dart';
import 'reader_tab_pages.dart';

class ReaderShellPage extends StatefulWidget {
  const ReaderShellPage({super.key});

  @override
  State<ReaderShellPage> createState() => _ReaderShellPageState();
}

class _ReaderShellPageState extends State<ReaderShellPage> {
  static const _items = <ReaderNavigationItem>[
    ReaderNavigationItem(
      label: 'Home',
      icon: HugeIconsStrokeRounded.home01,
      symbol: 'house',
      selectedSymbol: 'house.fill',
    ),
    ReaderNavigationItem(
      label: 'Latest',
      icon: HugeIconsStrokeRounded.news01,
      symbol: 'newspaper',
      selectedSymbol: 'newspaper.fill',
    ),
    ReaderNavigationItem(
      label: 'Saved',
      icon: HugeIconsStrokeRounded.bookmark01,
      symbol: 'bookmark',
      selectedSymbol: 'bookmark.fill',
    ),
    ReaderNavigationItem(
      label: 'Profile',
      icon: HugeIconsStrokeRounded.user,
      symbol: 'person.crop.circle',
      selectedSymbol: 'person.crop.circle.fill',
    ),
  ];

  static const _pages = <Widget>[
    HomePage(),
    ReaderPlaceholderTab(title: 'Latest', subtitle: 'The newest stories.'),
    ReaderPlaceholderTab(title: 'Saved', subtitle: 'Stories kept for later.'),
    ReaderProfileTab(),
  ];

  int _selectedIndex = 0;

  void _select(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveReaderShell(
      selectedIndex: _selectedIndex,
      onSelected: _select,
      items: _items,
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
