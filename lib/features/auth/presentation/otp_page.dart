import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/features/auth/application/auth_flow_state.dart';
import 'package:mikozi_mobile/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:mikozi_mobile/features/auth/presentation/widgets/auth_page_frame.dart';
import 'package:mikozi_mobile/features/auth/presentation/widgets/otp_code_field.dart';
import 'package:mikozi_mobile/shared/design_system/app_spacing.dart';
import 'package:mikozi_mobile/shared/design_system/primary_action.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() => setState(() {});

  void _verify() {
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).verifyOtp(_codeController.text);
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(authControllerProvider).value;
    final busy = value?.isBusy ?? true;
    final verifyingOtp = value?.stage == AuthStage.verifyingOtp;
    final phone = value?.phoneNumberLabel;
    return AuthPageFrame(
      title: 'Check your\nmessages.',
      subtitle: phone == null
          ? 'Enter the six-digit code.'
          : 'Code sent to $phone',
      onBack: busy
          ? null
          : ref.read(authControllerProvider.notifier).useDifferentNumber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OtpCodeField(
            controller: _codeController,
            enabled: !busy,
            onCompleted: (_) => _verify(),
          ),
          AuthErrorText(message: value?.failure?.message),
          const SizedBox(height: AppSpacing.sm),
          PrimaryAction(
            label: 'Verify',
            enabled: !busy && _codeController.text.length == 6,
            loading: verifyingOtp,
            loadingLabel: 'Verifying',
            onPressed: busy ? null : _verify,
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: AdaptiveButton(
              label: 'Use a different number',
              onPressed: busy
                  ? null
                  : ref
                        .read(authControllerProvider.notifier)
                        .useDifferentNumber,
              enabled: !busy,
              style: AdaptiveButtonStyle.plain,
              color: AppTheme.brandRed,
              textColor: AppTheme.brandRed,
            ),
          ),
        ],
      ),
    );
  }
}
