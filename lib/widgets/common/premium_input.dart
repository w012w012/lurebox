import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lurebox/core/constants/strings.dart';
import 'package:lurebox/core/design/theme/app_colors.dart';
import 'package:lurebox/core/design/theme/tesla_theme.dart';

/// 高级极简输入框组件
/// 提供统一的输入框样式，符合Premium Minimalist设计系统
class PremiumTextField extends StatelessWidget {

  const PremiumTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.contentPadding,
  });
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      style: TextStyle(
        color: isDark ? TeslaColors.white : TeslaColors.carbonDark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefix: prefix,
        suffix: suffix,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: TeslaTheme.spacingMd,
              vertical: TeslaTheme.spacingMicro,
            ),
        filled: true,
        fillColor: isDark
            ? TeslaColors.carbonDark.withValues(alpha: 0.5)
            : TeslaColors.graphite.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(
            color: TeslaColors.electricBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 16,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? TeslaColors.electricBlue : TeslaColors.electricBlue,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A).withValues(alpha: 0.7)
              : TeslaColors.graphite.withValues(alpha: 0.7),
          fontSize: 16,
        ),
        errorStyle: const TextStyle(color: TeslaColors.electricBlue, fontSize: 12),
        counterStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// 高级极简搜索框
class PremiumSearchField extends StatelessWidget {

  const PremiumSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
    this.prefixIcon,
    this.strings,
  });
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final AppStrings? strings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      focusNode: focusNode,
      style: TextStyle(
        color: isDark ? TeslaColors.white : TeslaColors.carbonDark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hint ?? strings?.search ?? 'Search...',
        prefixIcon: prefixIcon ??
            Icon(
              Icons.search_rounded,
              color: isDark
                  ? const Color(0xFF9A9A9A)
                  : TeslaColors.graphite,
            ),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: isDark
                      ? const Color(0xFF9A9A9A)
                      : TeslaColors.graphite,
                ),
                onPressed: () {
                  controller!.clear();
                  onClear?.call();
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingMicro,
        ),
        filled: true,
        fillColor: isDark
            ? TeslaColors.carbonDark.withValues(alpha: 0.5)
            : TeslaColors.graphite.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(
            color: TeslaColors.electricBlue,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// 高级极简数字输入框
class PremiumNumberField extends StatelessWidget {

  const PremiumNumberField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.suffixText,
    this.prefixText,
    this.min,
    this.max,
    this.decimals,
    this.enabled = true,
    this.focusNode,
  });
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? suffixText;
  final String? prefixText;
  final double? min;
  final double? max;
  final int? decimals;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      enabled: enabled,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^-?\d*\.?\d{0,${decimals ?? 2}}'),
        ),
        if (min != null || max != null)
          _RangeTextInputFormatter(min: min, max: max),
      ],
      style: TextStyle(
        color: isDark ? TeslaColors.white : TeslaColors.carbonDark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixText: prefixText,
        suffixText: suffixText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingMicro,
        ),
        filled: true,
        fillColor: isDark
            ? TeslaColors.carbonDark.withValues(alpha: 0.5)
            : TeslaColors.graphite.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(
            color: TeslaColors.electricBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 16,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? TeslaColors.electricBlue : TeslaColors.electricBlue,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A).withValues(alpha: 0.7)
              : TeslaColors.graphite.withValues(alpha: 0.7),
          fontSize: 16,
        ),
        suffixStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 16,
        ),
        prefixStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// 范围输入格式化器
class _RangeTextInputFormatter extends TextInputFormatter {

  _RangeTextInputFormatter({this.min, this.max});
  final double? min;
  final double? max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = double.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    if (min != null && value < min!) {
      return TextEditingValue(
        text: min!.toString(),
        selection: TextSelection.collapsed(offset: min!.toString().length),
      );
    }

    if (max != null && value > max!) {
      return TextEditingValue(
        text: max!.toString(),
        selection: TextSelection.collapsed(offset: max!.toString().length),
      );
    }

    return newValue;
  }
}

/// 高级极简多行文本输入框
class PremiumTextArea extends StatelessWidget {

  const PremiumTextArea({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
  });
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      focusNode: focusNode,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        color: isDark ? TeslaColors.white : TeslaColors.carbonDark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingMicro,
        ),
        filled: true,
        fillColor: isDark
            ? TeslaColors.carbonDark.withValues(alpha: 0.5)
            : TeslaColors.graphite.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(
            color: TeslaColors.electricBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 16,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? TeslaColors.electricBlue : TeslaColors.electricBlue,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A).withValues(alpha: 0.7)
              : TeslaColors.graphite.withValues(alpha: 0.7),
          fontSize: 16,
        ),
      ),
    );
  }
}

/// 高级极简下拉选择框
class PremiumDropdown<T> extends StatelessWidget {

  const PremiumDropdown({
    required this.items, super.key,
    this.label,
    this.value,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
  });
  final String? label;
  final T? value;
  final List<PremiumDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          child: Text(
            item.label,
            style: TextStyle(
              color: isDark
                  ? TeslaColors.white
                  : TeslaColors.carbonDark,
            ),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color:
            isDark ? const Color(0xFF9A9A9A) : TeslaColors.graphite,
      ),
      style: TextStyle(
        color: isDark ? TeslaColors.white : TeslaColors.carbonDark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TeslaTheme.spacingMd,
          vertical: TeslaTheme.spacingMicro,
        ),
        filled: true,
        fillColor: isDark
            ? TeslaColors.carbonDark.withValues(alpha: 0.5)
            : TeslaColors.graphite.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : TeslaColors.graphite.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(
            color: TeslaColors.electricBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
          borderSide: const BorderSide(color: TeslaColors.electricBlue, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDark
              ? const Color(0xFF9A9A9A)
              : TeslaColors.graphite,
          fontSize: 16,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? TeslaColors.electricBlue : TeslaColors.electricBlue,
          fontSize: 16,
        ),
      ),
      dropdownColor: isDark ? TeslaColors.carbonDark : TeslaColors.white,
      borderRadius: BorderRadius.circular(TeslaTheme.radiusCard),
      elevation: 4,
    );
  }
}

/// 下拉选择项
class PremiumDropdownItem<T> {

  const PremiumDropdownItem({required this.value, required this.label});
  final T value;
  final String label;
}
