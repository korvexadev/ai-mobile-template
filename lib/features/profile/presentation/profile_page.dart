import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../../articles/application/saved_articles_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_profile.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({required this.onOpenSaved, super.key});

  final VoidCallback onOpenSaved;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider).value?.session?.profile;
    final savedCount = ref.watch(savedArticlesControllerProvider).value?.length;
    return ProfileContent(
      profile: profile,
      savedCount: savedCount,
      signingOut: _isSigningOut,
      onOpenSaved: widget.onOpenSaved,
      onSignOut: _signOut,
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    required this.profile,
    required this.savedCount,
    required this.signingOut,
    required this.onOpenSaved,
    required this.onSignOut,
    super.key,
  });

  final AuthProfile? profile;
  final int? savedCount;
  final bool signingOut;
  final VoidCallback onOpenSaved;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final displayName = profile?.displayName?.trim();
    final name = displayName?.isNotEmpty == true ? displayName! : 'Reader';
    return ColoredBox(
      color: AppTheme.softSurface,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                      128,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _IdentityCard(
                          name: name,
                          phoneNumber: profile?.phoneNumber ?? '',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SettingsGroup(
                          children: [
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.bookmark02,
                              label: 'Saved stories',
                              value: savedCount?.toString() ?? '—',
                              onPressed: onOpenSaved,
                            ),
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.languageCircle,
                              label: 'Language',
                              value: _languageLabel(profile?.preferredLanguage),
                            ),
                            const _ProfileRow(
                              icon: HugeIconsStrokeRounded.sun01,
                              label: 'Appearance',
                              value: 'Light',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SettingsGroup(
                          children: [
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.logout01,
                              label: 'Sign out',
                              destructive: true,
                              busy: signingOut,
                              onPressed: signingOut ? null : onSignOut,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.name, required this.phoneNumber});

  final String name;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5E7),
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials(name),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.brandRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  if (phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      phoneNumber,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<_ProfileRow> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: AppTheme.white,
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                const Divider(height: 1, indent: 60, color: AppTheme.border),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    this.value,
    this.onPressed,
    this.destructive = false,
    this.busy = false,
  });

  final List<List<dynamic>> icon;
  final String label;
  final String? value;
  final VoidCallback? onPressed;
  final bool destructive;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive ? AppTheme.brandRed : AppTheme.ink;
    final content = SizedBox(
      height: 62,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: HugeIcon(icon: icon, color: foreground, size: 21),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (busy)
              const CupertinoActivityIndicator(
                color: AppTheme.brandRed,
                radius: 9,
              )
            else if (value != null)
              Text(
                value!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
              ),
            if (onPressed != null && !busy) ...[
              const SizedBox(width: AppSpacing.xs),
              const HugeIcon(
                icon: HugeIconsStrokeRounded.arrowRight01,
                color: AppTheme.muted,
                size: 17,
              ),
            ],
          ],
        ),
      ),
    );
    if (onPressed == null) {
      return content;
    }
    return Semantics(
      button: true,
      label: label,
      child: CupertinoButton(
        key: ValueKey('profile-${label.toLowerCase().replaceAll(' ', '-')}'),
        padding: EdgeInsets.zero,
        minimumSize: const Size.fromHeight(62),
        alignment: Alignment.centerLeft,
        onPressed: onPressed,
        child: content,
      ),
    );
  }
}

String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2);
  return words.map((word) => word[0].toUpperCase()).join();
}

String _languageLabel(String? value) {
  return switch (value?.toLowerCase()) {
    'en' || 'english' => 'English',
    'ny' || 'chichewa' => 'Chichewa',
    final language? when language.trim().isNotEmpty => language,
    _ => 'English',
  };
}
