import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosTextField extends StatelessWidget {
  final int? maxLines;
  final String? hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function()? onComplete;
  final Function()? onTap;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? obscureText;
  final bool? enabled;
  final bool? formsearch;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const RevoPosTextField(
      {Key? key,
      this.hintText,
      required this.controller,
      required this.onChanged,
      this.onTap = null,
      this.maxLines,
      this.validator,
      this.suffixIcon,
      this.obscureText,
      this.prefixIcon,
      this.keyboardType,
      this.inputFormatters,
      this.enabled = true,
      this.onComplete,
      this.formsearch = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      maxLines: maxLines,
      autofocus: false,
      enabled: enabled ?? true,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        fillColor: enabled! ? null : colorDisabled,
        filled: enabled! ? false : true,
        isDense: true,
        contentPadding: formsearch!
            ? const EdgeInsets.fromLTRB(17, 5, 0, 5)
            : const EdgeInsets.all(12.0),
        hintText: hintText ?? "",
        hintStyle:
            Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorDisabled,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText ?? false,
      onChanged: onChanged,
      validator: validator,
      onEditingComplete: onComplete,
    );
  }
}
