import 'app_theme.dart';
import 'package:flutter/material.dart';

class ThemeConfig {
  static AppTheme get lightTheme => AppTheme(
        backgroundColor: const Color(0xFFF1F3F4),
        primaryColor: const Color(0xFF222222),
        textColor: const Color(0xFFA1A8B8),
        primaryCardColor: const Color(0xFFFFFFFF),
        secondaryCardColor: const Color(0xFFF0F7FE),
        errorColor: const Color(0xFFF44336),
        warningColor: const Color(0xFFFFA100),
        successColor: const Color(0xFF4EB8A6),
        calendarExpectedColor: const Color(0xFFFFE5B9),
        calendarInProgressColor: const Color(0xFFE8F3FF),
        calendarMissedColor: const Color(0xFFFECFCA),
        calendarReservedColor: const Color(0xFFA1A8B8),
        calendarSuccesColor: const Color(0xFFDCF1ED),
        cardShadowColor: const Color(0x401A1A1A),
        scheduleTableColor: const Color(0xFFD2D3D5),
        primaryButtonConfig: ButtonConfig(
          textColor: const Color(0xFFFFFFFF),
          defaultBackgroundColor: const Color(0xFF415BE7),
          hoverBackgroundColor: const Color(0xFF6C86FF),
          focustBackgroundColor: const Color(0xFF203AC6),
          disabledBackgroundColor: const Color(0xFFE7E8EA),
          disabledTextColor: const Color(0xFFA1A8B8),
        ),
        secondaryButtonConfig: ButtonConfig(
          textColor: const Color(0xFF222222),
          defaultBackgroundColor: const Color(0xFFF0F7FE),
          hoverBackgroundColor: const Color(0xFFD8DFEB),
          focustBackgroundColor: const Color(0xFFC6CDD9),
          disabledBackgroundColor: const Color(0xFFF1F3F4),
          disabledTextColor: const Color(0xFFA1A8B8),
        ),
        tertiaryButtonConfig: ButtonConfig(
          textColor: const Color(0xFF222222),
          defaultBackgroundColor: const Color(0xFFA1A8B8),
          hoverBackgroundColor: const Color(0xFFA1A8B8),
          focustBackgroundColor: const Color(0xFF222222),
          disabledBackgroundColor: const Color(0xFFA1A8B8),
          disabledTextColor: const Color(0xFFA1A8B8),
        ),
        inputFieldConfig: InputFieldConfig(
          backgroundColor: const Color(0xFFFFFFFF),
          alternativeBackgroundColor: const Color(0xFFF1F3F4),
          borderColor: const Color(0xFFE7E8EA),
          hoverBorderColor: const Color(0xFF415BE7),
          focusBorderColor: const Color(0xFF415BE7),
          erorBorderColor: const Color(0xFFF44336),
          textColor: const Color(0xFF222222),
          labelColor: const Color(0xFFA1A8B8),
          erorLabelColor: const Color(0xFFF44336),
        ),
        menuColorConfig: MenuColorConfig(
          menuColor: const Color(0xFFFFFFFF),
          menuIconColor: const Color(0xFFA1A8B8),
          menuItemActiveColor: const Color(0xFF415BE7),
          menuSectionColor: const Color(0xFFF0F7FE),
          menuBorderColor: const Color(0xFFE7E8EA),
        ),
        // Статусные цвета
        statusCreatedColor:
            const Color.fromARGB(255, 145, 189, 233), // Серый (created)
        statusInProgressColor: const Color(0xFFFFE5B9), // Синий (inProgress)
        statusInProgressNoDeviationsColor:
            const Color(0xFFFFE5B9), // Бирюзовый (inProgressNoDeviations)
        statusInProgressWithDeviationsColor: const Color.fromARGB(
            255, 244, 94, 84), // Оранжевый (inProgressWithDeviations)
        statusEmergencyColor:
            const Color.fromARGB(255, 244, 94, 84), // Красный (emergency)
        statusErrorColor:
            const Color.fromARGB(255, 244, 94, 84), // Красный (error)
        statusStoppedColor: const Color(0xFFA1A8B8), // Серый (stopped)
        statusCompletedColor: const Color.fromARGB(255, 128, 233, 137), // Бирюзовый (completed)
        statusCancelledColor: const Color(0xFFFECFCA), // Серый (cancelled)
        statusUnknownColor: const Color(0xFFFECFCA), // Светло-серый (unknown)
      );

  static AppTheme get darkTheme => AppTheme(
        backgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFBB86FC), // Акцентный фиолетовый
        textColor: const Color(0xFFE0E0E0), // Светло-серый текст
        primaryCardColor: const Color(0xFF1E1E1E),
        secondaryCardColor: const Color(0xFF2D2D2D),
        errorColor: const Color(0xFFCF6679), // Приглушенный красный
        warningColor: const Color(0xFFFFB74D), // Оранжевый
        successColor: const Color(0xFF4DB6AC), // Бирюзовый
        calendarExpectedColor: const Color(0xFFFFB74D),
        calendarInProgressColor: const Color(0xFF2D2D2D),
        calendarMissedColor: const Color(0xFFCF6679),
        calendarReservedColor: const Color(0xFF616161),
        calendarSuccesColor: const Color(0xFF2D4D48),
        cardShadowColor: const Color(0x401A1A1A),
        scheduleTableColor: const Color(0xFFD2D3D5),
        primaryButtonConfig: ButtonConfig(
          textColor: const Color(0xFF000000),
          defaultBackgroundColor: const Color(0xFFBB86FC), // Фиолетовый
          hoverBackgroundColor: const Color(0xFF9A67EA),
          focustBackgroundColor: const Color(0xFF7F4BCC),
          disabledBackgroundColor: const Color(0xFF424242),
          disabledTextColor: const Color(0xFF757575),
        ),
        secondaryButtonConfig: ButtonConfig(
          textColor: const Color(0xFFE0E0E0),
          defaultBackgroundColor: const Color(0xFF424242),
          hoverBackgroundColor: const Color(0xFF616161),
          focustBackgroundColor: const Color(0xFF757575),
          disabledBackgroundColor: const Color(0xFF2D2D2D),
          disabledTextColor: const Color(0xFF616161),
        ),
        tertiaryButtonConfig: ButtonConfig(
          textColor: const Color(0xFFBB86FC),
          defaultBackgroundColor: Colors.transparent,
          hoverBackgroundColor: const Color(0x14BB86FC), // 8% opacity
          focustBackgroundColor: const Color(0x29BB86FC), // 16% opacity
          disabledBackgroundColor: Colors.transparent,
          disabledTextColor: const Color(0xFF757575),
        ),
        inputFieldConfig: InputFieldConfig(
          backgroundColor: const Color(0xFF1E1E1E),
          alternativeBackgroundColor: const Color(0xFF2D2D2D),
          borderColor: const Color(0xFF424242),
          hoverBorderColor: const Color(0xFFBB86FC),
          focusBorderColor: const Color(0xFFBB86FC),
          erorBorderColor: const Color(0xFFCF6679),
          textColor: const Color(0xFFE0E0E0),
          labelColor: const Color(0xFF757575),
          erorLabelColor: const Color(0xFFCF6679),
        ),
        menuColorConfig: MenuColorConfig(
            menuColor: const Color(0xFFFFFFFF),
            menuIconColor: const Color(0xFFA1A8B8),
            menuItemActiveColor: const Color(0xFF415BE7),
            menuSectionColor: const Color(0xFFF0F7FE),
            menuBorderColor: const Color(0xFFE7E8EA)),
        // Статусные цвета
        statusCreatedColor: const Color(0xFF616161), // Тёмно-серый (created)
        statusInProgressColor:
            const Color(0xFFBB86FC), // Фиолетовый (inProgress)
        statusInProgressNoDeviationsColor:
            const Color(0xFF4DB6AC), // Бирюзовый (inProgressNoDeviations)
        statusInProgressWithDeviationsColor:
            const Color(0xFFFFB74D), // Оранжевый (inProgressWithDeviations)
        statusEmergencyColor: const Color(0xFFCF6679), // Красный (emergency)
        statusErrorColor: const Color(0xFFCF6679), // Красный (error)
        statusStoppedColor: const Color(0xFF616161), // Тёмно-серый (stopped)
        statusCompletedColor: const Color(0xFF4DB6AC), // Бирюзовый (completed)
        statusCancelledColor:
            const Color(0xFF616161), // Тёмно-серый (cancelled)
        statusUnknownColor: const Color(0xFFD2D3D5), // Светло-серый (unknown)
      );
}
