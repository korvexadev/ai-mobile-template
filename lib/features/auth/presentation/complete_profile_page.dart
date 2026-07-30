import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/features/auth/application/auth_flow_state.dart';
import 'package:mikozi_mobile/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:mikozi_mobile/features/auth/presentation/widgets/auth_page_frame.dart';
import 'package:mikozi_mobile/shared/design_system/app_spacing.dart';
import 'package:mikozi_mobile/shared/design_system/primary_action.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() {
    return _CompleteProfilePageState();
  }
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref
        .read(authControllerProvider.notifier)
        .completeProfile(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(authControllerProvider).value;
    final busy = value?.isBusy ?? true;
    final savingProfile = value?.stage == AuthStage.savingProfile;
    return AuthPageFrame(
      title: 'What should\nwe call you?',
      subtitle: 'Complete your reader profile.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your name',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          AdaptiveTextField(
            key: const ValueKey('name-field'),
            controller: _nameController,
            enabled: !busy,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.name],
            inputFormatters: [LengthLimitingTextInputFormatter(80)],
            placeholder: 'Your name',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: const InputDecoration(hintText: 'Your name'),
            onSubmitted: (_) {
              if (!busy) {
                _submit();
              }
            },
          ),
          AuthErrorText(message: value?.failure?.message),
          const SizedBox(height: AppSpacing.sm),
          PrimaryAction(
            label: 'Continue',
            enabled: !busy,
            loading: savingProfile,
            loadingLabel: 'Saving',
            onPressed: busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
