import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../../articles/application/saved_articles_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_profile.dart';
import '../application/app_version_provider.dart';
import '../application/reader_entitlement_provider.dart';
import '../domain/reader_entitlement.dart';

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

  Future<void> _explainAccountDeletion() async {
    await showAdaptiveDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Delete account'),
          content: const Text(
            'Account deletion is currently completed by Mikozi support.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider).value?.session?.profile;
    final savedCount = ref.watch(savedArticlesControllerProvider).value?.length;
    final entitlement = ref.watch(readerEntitlementProvider);
    final appVersion = ref.watch(appVersionProvider);
    return ProfileContent(
      profile: profile,
      savedCount: savedCount,
      entitlement: entitlement.value,
      entitlementLoading: entitlement.isLoading,
      appVersion: appVersion.value,
      signingOut: _isSigningOut,
      onOpenSaved: widget.onOpenSaved,
      onOpenNotifications: () => context.push('/settings/notifications'),
      onOpenSubscription: () => context.push('/settings/subscription'),
      onOpenTransactions: () => context.push('/settings/transactions'),
      onOpenPrivacy: () => context.push('/settings/privacy'),
      onOpenAbout: () => context.push('/settings/about'),
      onDeleteAccount: _explainAccountDeletion,
      onSignOut: _signOut,
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    required this.profile,
    required this.savedCount,
    required this.entitlement,
    required this.entitlementLoading,
    required this.appVersion,
    required this.signingOut,
    required this.onOpenSaved,
    required this.onOpenNotifications,
    required this.onOpenSubscription,
    required this.onOpenTransactions,
    required this.onOpenPrivacy,
    required this.onOpenAbout,
    required this.onDeleteAccount,
    required this.onSignOut,
    super.key,
  });

  final AuthProfile? profile;
  final int? savedCount;
  final ReaderEntitlement? entitlement;
  final bool entitlementLoading;
  final String? appVersion;
  final bool signingOut;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSubscription;
  final VoidCallback onOpenTransactions;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenAbout;
  final VoidCallback onDeleteAccount;
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
                      AppSpacing.xl,
                      AppSpacing.md,
                      128,
                    ),
                    child: Column(
                      children: [
                        _Identity(
                          name: name,
                          phoneNumber: profile?.phoneNumber ?? '',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _AllowanceCard(
                          entitlement: entitlement,
                          loading: entitlementLoading,
                          onPressed: entitlement?.paymentsEnabled == false
                              ? null
                              : onOpenSubscription,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _GroupLabel(label: 'PERSONAL'),
                        const SizedBox(height: AppSpacing.xs),
                        _SettingsGroup(
                          children: [
                            if (entitlement?.paymentsEnabled != false) ...[
                              _ProfileRow(
                                icon: HugeIconsStrokeRounded.walletCards,
                                label: 'Subscription',
                                value: entitlement?.planName,
                                onPressed: onOpenSubscription,
                              ),
                              _ProfileRow(
                                icon: HugeIconsStrokeRounded.invoice02,
                                label: 'Transactions',
                                onPressed: onOpenTransactions,
                              ),
                            ],
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.bookmark02,
                              label: 'Saved stories',
                              value: savedCount?.toString() ?? '—',
                              onPressed: onOpenSaved,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        const _GroupLabel(label: 'GENERAL'),
                        const SizedBox(height: AppSpacing.xs),
                        _SettingsGroup(
                          children: [
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.notification02,
                              label: 'Notifications',
                              onPressed: onOpenNotifications,
                            ),
                            const _ProfileRow(
                              icon: HugeIconsStrokeRounded.sun01,
                              label: 'Appearance',
                              value: 'Light',
                            ),
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.languageCircle,
                              label: 'Language',
                              value: _languageLabel(profile?.preferredLanguage),
                            ),
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.security,
                              label: 'Privacy policy',
                              onPressed: onOpenPrivacy,
                            ),
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.informationCircle,
                              label: 'About',
                              onPressed: onOpenAbout,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _GroupLabel(label: 'SECURITY'),
                        const SizedBox(height: AppSpacing.xs),
                        _SettingsGroup(
                          children: [
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.delete02,
                              label: 'Delete account',
                              destructive: true,
                              onPressed: onDeleteAccount,
                            ),
                            _ProfileRow(
                              icon: HugeIconsStrokeRounded.logout01,
                              label: 'Sign out',
                              destructive: true,
                              busy: signingOut,
                              onPressed: signingOut ? null : onSignOut,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Mikozi ${appVersion ?? '—'}',
                          key: const ValueKey('profile-app-version'),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppTheme.muted),
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

class _Identity extends StatelessWidget {
  const _Identity({required this.name, required this.phoneNumber});

  final String name;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE5E7),
            shape: BoxShape.circle,
          ),
          child: Text(
            _initials(name),
            key: const ValueKey('profile-avatar-initials'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.brandRed,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (phoneNumber.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            phoneNumber,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ],
    );
  }
}

class _AllowanceCard extends StatelessWidget {
  const _AllowanceCard({
    required this.entitlement,
    required this.loading,
    required this.onPressed,
  });

  final ReaderEntitlement? entitlement;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final read = entitlement?.articlesReadToday;
    final value = read?.toString() ?? '—';
    final label = read == 1 ? 'story read today' : 'stories read today';
    return Semantics(
      button: onPressed != null,
      label: '$value $label',
      child: CupertinoButton(
        key: const ValueKey('profile-daily-allowance'),
        padding: EdgeInsets.zero,
        minimumSize: const Size.fromHeight(104),
        onPressed: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppTheme.brandRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (loading)
                      const CupertinoActivityIndicator(color: AppTheme.white)
                    else
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTheme.white),
                    ),
                  ],
                ),
              ),
              Text(
                entitlement?.planName ?? '',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
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
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
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
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (busy)
                    const CupertinoActivityIndicator(
                      color: AppTheme.brandRed,
                      radius: 9,
                    )
                  else if (value != null)
                    Flexible(
                      child: Text(
                        value!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                      ),
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
        minimumSize: const Size.fromHeight(60),
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
