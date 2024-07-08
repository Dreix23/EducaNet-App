import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CalendarLocalization {
  static Future<void> initialize() async {
    await initializeDateFormatting('es_ES', null);
  }

  static String getMonthName(int month) {
    return DateFormat('MMMM', 'es_ES').format(DateTime(2024, month));
  }

  static String getWeekdayName(int weekday) {
    return DateFormat('EEEE', 'es_ES').format(DateTime(2024, 1, weekday));
  }

  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'es_ES').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'es_ES').format(time);
  }
}
