import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ButtonSize { small, medium, large }

class ButtonConfig {
  final Color textColor;
  final Color defaultBackgroundColor;
  final Color hoverBackgroundColor;
  final Color focustBackgroundColor;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;

  ButtonConfig({
    required this.textColor,
    required this.defaultBackgroundColor,
    required this.hoverBackgroundColor,
    required this.focustBackgroundColor,
    required this.disabledBackgroundColor,
    required this.disabledTextColor,
  });
}

class MenuColorConfig {
  final Color menuColor;
  final Color menuSectionColor;
  final Color menuItemActiveColor;
  final Color menuIconColor;
  final Color menuBorderColor;

  MenuColorConfig(
      {required this.menuColor,
      required this.menuIconColor,
      required this.menuItemActiveColor,
      required this.menuSectionColor,
      required this.menuBorderColor});
}

class InputFieldConfig {
  final Color backgroundColor;
  final Color alternativeBackgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final Color focusBorderColor;
  final Color erorBorderColor;
  final Color textColor;
  final Color labelColor;
  final Color erorLabelColor;

  InputFieldConfig({
    required this.backgroundColor,
    required this.alternativeBackgroundColor,
    required this.borderColor,
    required this.hoverBorderColor,
    required this.focusBorderColor,
    required this.erorBorderColor,
    required this.textColor,
    required this.labelColor,
    required this.erorLabelColor,
  });
}

class AppTheme {
  static const String interFontFamily = 'Inter';
  static const String manropeFontFamily = 'Manrope';

  // Цвета

  final Color backgroundColor;
  final Color primaryColor;
  final Color textColor;
  final Color primaryCardColor;
  final Color secondaryCardColor;
  final Color errorColor;
  final Color warningColor;
  final Color successColor;
  final Color calendarReservedColor;
  final Color calendarInProgressColor;
  final Color calendarExpectedColor;
  final Color calendarMissedColor;
  final Color calendarSuccesColor;
  final Color cardShadowColor;
  final Color scheduleTableColor;

  // Статусные цвета
  final Color statusCreatedColor;
  final Color statusInProgressColor;
  final Color statusInProgressNoDeviationsColor;
  final Color statusInProgressWithDeviationsColor;
  final Color statusEmergencyColor;
  final Color statusErrorColor;
  final Color statusStoppedColor;
  final Color statusCompletedColor;
  final Color statusCancelledColor;
  final Color statusUnknownColor;

  final ButtonConfig primaryButtonConfig;
  final ButtonConfig tertiaryButtonConfig;
  final ButtonConfig secondaryButtonConfig;
  final InputFieldConfig inputFieldConfig;
  final MenuColorConfig menuColorConfig;

  AppTheme({
    required this.backgroundColor,
    required this.primaryColor,
    required this.textColor,
    required this.primaryCardColor,
    required this.secondaryCardColor,
    required this.errorColor,
    required this.warningColor,
    required this.successColor,
    required this.calendarReservedColor,
    required this.calendarInProgressColor,
    required this.calendarExpectedColor,
    required this.calendarMissedColor,
    required this.calendarSuccesColor,
    required this.primaryButtonConfig,
    required this.secondaryButtonConfig,
    required this.tertiaryButtonConfig,
    required this.inputFieldConfig,
    required this.menuColorConfig,
    required this.cardShadowColor,
    required this.scheduleTableColor,
    // Новые цвета для статусов
    required this.statusCreatedColor,
    required this.statusInProgressColor,
    required this.statusInProgressNoDeviationsColor,
    required this.statusInProgressWithDeviationsColor,
    required this.statusEmergencyColor,
    required this.statusErrorColor,
    required this.statusStoppedColor,
    required this.statusCompletedColor,
    required this.statusCancelledColor,
    required this.statusUnknownColor,
  });

  ThemeData getTextThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      fontFamily: interFontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: interFontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 36,
          height: 1.2,
          color: primaryColor,
        ),
        displayMedium: TextStyle(
          fontFamily: interFontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          height: 1.2,
          color: primaryColor,
        ),
        displaySmall: TextStyle(
          fontFamily: interFontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          height: 1.2,
          color: primaryColor,
        ),
        headlineLarge: TextStyle(
          fontFamily: interFontFamily,
          fontWeight: FontWeight.w600, // SemiBold
          fontSize: 20,
          height: 1.2,
          color: primaryColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: interFontFamily,
          fontWeight: FontWeight.w600, // SemiBold
          fontSize: 18,
          height: 1.2,
          color: primaryColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: interFontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 16,
          height: 1.4,
          color: primaryColor,
        ),
        titleLarge: TextStyle(
          fontFamily: interFontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 14,
          height: 1.4,
          color: primaryColor,
        ),
        titleMedium: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 16,
          height: 1.6,
          color: primaryColor,
        ),
        titleSmall: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 14,
          height: 1.6,
          color: primaryColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 18,
          height: 1.6,
          color: primaryColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 16,
          height: 1.6,
          color: primaryColor,
        ),
        bodySmall: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.6,
          color: primaryColor,
        ),
        labelLarge: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.w600, // SemiBold
          fontSize: 16,
          height: 1.1,
          color: primaryColor,
        ),
        labelMedium: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.w600, // SemiBold
          fontSize: 14,
          height: 1.1,
          color: primaryColor,
        ),
        labelSmall: TextStyle(
          fontFamily: manropeFontFamily,
          fontWeight: FontWeight.w500, // Medium
          fontSize: 12,
          height: 1.2,
          color: primaryColor,
        ),
      ),
    );
  }

  // Стили для Primary кнопок
  ButtonStyle primaryButtonStyle(BuildContext context, ButtonSize size) {
    return ElevatedButton.styleFrom(
      textStyle: _getButtonTextStyle(size),
      padding: _getButtonPadding(size),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return primaryButtonConfig
                .disabledBackgroundColor; // Цвет для disabled
          }
          if (states.contains(WidgetState.hovered)) {
            return primaryButtonConfig.hoverBackgroundColor; // Цвет для hover
          }
          if (states.contains(WidgetState.focused)) {
            return primaryButtonConfig.focustBackgroundColor; // Цвет для focus
          }
          return primaryButtonConfig.defaultBackgroundColor; // Основной цвет
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return primaryButtonConfig.disabledTextColor; // Цвет для disabled
          }
          return primaryButtonConfig.textColor; // Основной цвет
        },
      ),
    );
  }

  // Стили для Secondary кнопок
  ButtonStyle secondaryButtonStyle(BuildContext context, ButtonSize size) {
    return ElevatedButton.styleFrom(
      textStyle: _getButtonTextStyle(size),
      padding: _getButtonPadding(size),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return secondaryButtonConfig
                .disabledBackgroundColor; // Цвет для disabled
          }
          if (states.contains(WidgetState.hovered)) {
            return secondaryButtonConfig.hoverBackgroundColor; // Цвет для hover
          }
          if (states.contains(WidgetState.focused)) {
            return secondaryButtonConfig
                .focustBackgroundColor; // Цвет для focus
          }
          return secondaryButtonConfig.defaultBackgroundColor; // Основной цвет
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return secondaryButtonConfig.disabledTextColor; // Цвет для disabled
          }
          return secondaryButtonConfig.textColor; // Основной цвет
        },
      ),
    );
  }

  // Стили для Tertiary кнопок
  ButtonStyle tertiaryButtonStyle(BuildContext context, ButtonSize size) {
    return ElevatedButton.styleFrom(
            textStyle: _getButtonTextStyle(size),
            padding: _getButtonPadding(size),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: backgroundColor)
        .copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: tertiaryButtonConfig.disabledBackgroundColor,
              width: 1.0,
            );
          }
          if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: tertiaryButtonConfig.hoverBackgroundColor,
              width: 2.0,
            );
          }
          if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: tertiaryButtonConfig.focustBackgroundColor,
              width: 2.0,
            );
          }
          return BorderSide(
            color: tertiaryButtonConfig.defaultBackgroundColor,
            width: 1.0,
          ); // Основной цвет
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return tertiaryButtonConfig.disabledTextColor; // Цвет для disabled
          }
          return tertiaryButtonConfig.textColor; // Основной цвет
        },
      ),
    );
  }

  // Получение текстового стиля для кнопок в зависимости от размера
  TextStyle _getButtonTextStyle(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(
            fontSize: 12,
            height: 1.1,
            fontFamily: manropeFontFamily,
            fontWeight: FontWeight.w700);
      case ButtonSize.medium:
        return const TextStyle(
            fontSize: 14,
            height: 1.1,
            fontFamily: manropeFontFamily,
            fontWeight: FontWeight.w700);
      case ButtonSize.large:
        return const TextStyle(
            fontSize: 16,
            height: 1.1,
            fontFamily: manropeFontFamily,
            fontWeight: FontWeight.w700);
    }
  }

  // Получение отступов для кнопок в зависимости от размера
  EdgeInsetsGeometry _getButtonPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  InputDecoration inputDecoration({
    bool hasError = false,
    bool isDisabled = false,
    String? labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(
          color: inputFieldConfig.labelColor,
          fontFamily: manropeFontFamily,
          fontSize: 14,
          height: 1.6,
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: hasError
              ? inputFieldConfig.erorLabelColor
              : isDisabled
                  ? inputFieldConfig.erorLabelColor
                  : inputFieldConfig.labelColor,
          fontFamily: manropeFontFamily,
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w500),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: inputFieldConfig.borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: inputFieldConfig.focusBorderColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: inputFieldConfig.erorBorderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: inputFieldConfig.erorBorderColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          width: 0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: isDisabled,
      fillColor: isDisabled
          ? inputFieldConfig.alternativeBackgroundColor
          : inputFieldConfig.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  BoxDecoration primaryCardStyle(BuildContext context) {
    return BoxDecoration(
      color: primaryCardColor, // Цвет фона
      borderRadius: BorderRadius.circular(16), // Закругление углов
      boxShadow: [
        BoxShadow(
          color: cardShadowColor, // 25% прозрачности (40 в 16-ричном формате)
          blurRadius: 5,
          spreadRadius: 0,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  // Стиль для карточки второго вида
  BoxDecoration secondaryCardStyle(BuildContext context) {
    return BoxDecoration(
      color: secondaryCardColor, // Цвет фона
      borderRadius: BorderRadius.circular(16), // Закругление углов
      boxShadow: [
        BoxShadow(
          color: cardShadowColor, // 25% прозрачности (40 в 16-ричном формате)
          blurRadius: 5,
          spreadRadius: 0,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  Map<String, Color> getAppColors() {
    final Map<String, Color> colors = {
      'background': backgroundColor,
      'primaryCard': primaryCardColor,
      'secondaryCard': secondaryCardColor,
      'primaryText': primaryColor,
      'secondaryText': textColor,
      'selectedItem': primaryButtonConfig.defaultBackgroundColor,
      'error': errorColor,
      'warning': warningColor,
      'success': successColor,
      'calendarReserved': calendarReservedColor,
      'calendarInProgress': calendarInProgressColor,
      'calendarExpected': calendarExpectedColor,
      'calendarMissed': calendarMissedColor,
      'calendarSucces': calendarSuccesColor,
    };
    return colors;
  }

  Map<String, Color> getMenuColors() {
    final Map<String, Color> colors = {
      'menuColor': menuColorConfig.menuColor,
      'menuSectionColor': menuColorConfig.menuSectionColor,
      'menuIconColor': menuColorConfig.menuIconColor,
      'menuItemActiveColor': menuColorConfig.menuItemActiveColor,
      'menuBorderColor': menuColorConfig.menuBorderColor,
    };
    return colors;
  }

  Map<String, Color> getStatusColors() {
    return {
      'created': statusCreatedColor,
      'inProgress': statusInProgressColor,
      'inProgressNoDeviations': statusInProgressNoDeviationsColor,
      'inProgressWithDeviations': statusInProgressWithDeviationsColor,
      'emergency': statusEmergencyColor,
      'error': statusErrorColor,
      'stopped': statusStoppedColor,
      'completed': statusCompletedColor,
      'cancelled': statusCancelledColor,
      'unknown': statusUnknownColor,
    };
  }
}
