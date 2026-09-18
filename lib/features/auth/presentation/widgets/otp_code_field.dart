import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    required this.controller,
    required this.onCompleted,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onCompleted;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Six-digit verification code',
      textField: true,
      child: GestureDetector(
        onTap: widget.enabled ? _focusNode.requestFocus : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, child) {
                return _CodeCells(
                  code: value.text,
                  focused: _focusNode.hasFocus,
                );
              },
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.01,
                child: AdaptiveTextField(
                  key: const ValueKey('otp-field'),
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.length == 6) {
                      widget.onCompleted(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeCells extends StatelessWidget {
  const _CodeCells({required this.code, required this.focused});

  final String code;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.xs;
        final available = constraints.maxWidth - gap * 5;
        final width = (available / 6).clamp(38.0, 52.0).toDouble();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final selected = focused && index == code.length;
            final character = index < code.length ? code[index] : '';
            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              width: width,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppTheme.brandRed
                      : AppTheme.borderOf(context),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                character,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }),
        );
      },
    );
  }
}
