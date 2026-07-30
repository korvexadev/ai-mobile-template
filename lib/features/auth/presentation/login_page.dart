import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/app_spacing.dart';
import '../../../shared/design_system/primary_action.dart';
import '../application/auth_controller.dart';
import '../application/auth_flow_state.dart';
import 'widgets/auth_error_text.dart';
import 'widgets/auth_page_frame.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).requestOtp(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final value = auth.value;
    final busy = value?.isBusy ?? true;
    final requestingOtp = value?.stage == AuthStage.requestingOtp;
    return AuthPageFrame(
      title: 'Your news,\nyour number.',
      subtitle: 'Sign in with your Malawi phone number.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone number',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          AdaptiveTextField(
            key: const ValueKey('phone-field'),
            controller: _phoneController,
            enabled: !busy,
            autofocus: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: Theme.of(context).textTheme.titleMedium,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Text('+265'),
            ),
            placeholder: '99 123 4567',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: const InputDecoration(
              prefixText: '+265  ',
              hintText: '99 123 4567',
              counterText: '',
            ),
            onSubmitted: (_) {
              if (!busy) {
                _submit();
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We’ll text you a six-digit code.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          AuthErrorText(message: value?.failure?.message),
          const SizedBox(height: AppSpacing.sm),
          PrimaryAction(
            label: 'Continue',
            enabled: !busy,
            loading: requestingOtp,
            loadingLabel: 'Sending code',
            onPressed: busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
