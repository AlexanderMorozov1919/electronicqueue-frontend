import 'package:intl/intl.dart';

// Функция для парсинга даты
String parseDate(String input) {
  DateTime dateTime = DateTime.parse(input);
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  return dateFormat.format(dateTime);
}

// Функция для парсинга времени
String parseTime(String input) {
  DateTime dateTime = DateTime.parse(input);
  DateFormat timeFormat = DateFormat('HH:mm:ss');
  return timeFormat.format(dateTime);
}

// Функция для парсинга даты и времени
String parseDateTime(String input) {
  DateTime dateTime = DateTime.parse(input);
  DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  return dateTimeFormat.format(dateTime);
}

// 1. Функция для получения только даты
String formatDate(DateTime dateTime) {
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  return dateFormat.format(dateTime);
}

// 2. Функция для получения только времени
String formatTime(DateTime dateTime) {
  DateFormat timeFormat = DateFormat('HH:mm:ss');
  return timeFormat.format(dateTime);
}

// 3. Функция для получения даты и времени
String formatDateTime(DateTime dateTime) {
  DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  return dateTimeFormat.format(dateTime);
}
