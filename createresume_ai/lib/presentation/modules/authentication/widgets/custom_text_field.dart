import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixIconPressed,
    this.validator,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
