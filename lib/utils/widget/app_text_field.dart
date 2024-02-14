import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/sizes.dart';

import '../text_styles.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextStyle labelStyle;
  final String initialValue;
  final Function(String) onTextChanged;
  final bool passwordVisible;
  final Widget suffixIcon;
  final Widget prefixIcon;
  final TextInputType keyboardType;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;
  final int maxLines;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle hintStyle;
  final bool enabled;
  final bool isBoarder;
  final TextStyle mTextStyle;
  final InputDecoration decoration;
  final int maxLength;
  final TextAlign textAlign;
  final String errorText;
  final List<TextInputFormatter> inputFormatters;

  const AppTextField({
    Key key,
    this.keyboardType,
    this.hintText,
    this.labelText,
    this.labelStyle,
    this.onTextChanged,
    this.maxLength = 255,
    this.isBoarder = true,
    this.controller,
    this.textAlign = TextAlign.start,
    this.passwordVisible = false,
    this.suffixIcon,
    this.initialValue,
    this.validator,
    this.errorText,
    this.prefixIcon,
    this.decoration,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20),
    this.maxLines = 1,
    this.hintStyle,
    this.mTextStyle,
    this.enabled,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      controller: controller,
      style: mTextStyle ??
          TextStyle(
              fontSize: FontSizes.s15,
              fontFamily: FontFamily.regular,
              color: Colors.black),
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: passwordVisible ?? false,
      onChanged: (value) {
        if (onTextChanged != null) onTextChanged(value);
      },
      initialValue: initialValue,
      inputFormatters: inputFormatters ?? [],
      decoration: decoration == null
          ? InputDecoration(
              counterText: '',
              errorText: errorText != null ? errorText : null,
              contentPadding: contentPadding,
              labelStyle: labelStyle,
              labelText: labelText,
              hintText: hintText,
              hintStyle: hintStyle,
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              border: InputBorder.none,
              focusedBorder: isBoarder ? _inputBorder(AppColors.blue) : null,
              enabledBorder:
                  isBoarder ? _inputBorder(AppColors.primaryLightColor) : null,
              errorBorder: isBoarder ? _inputBorder(AppColors.red) : null,
              focusedErrorBorder:
                  isBoarder ? _inputBorder(AppColors.red) : null,
            )
          : decoration,
    );
  }

  InputBorder _inputBorder(Color color) {
    return UnderlineInputBorder(borderSide: BorderSide(color: color));
  }
}
