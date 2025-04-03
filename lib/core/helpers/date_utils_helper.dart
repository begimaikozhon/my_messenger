import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatChatTime(DateTime time) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);
    final difference = now.difference(time);

    if (messageDay == today) {
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} минут${_pluralEnding(difference.inMinutes)} назад';
      } else {
        return DateFormat('HH:mm').format(time); // пример: 09:23
      }
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Вчера';
    } else {
      return DateFormat('dd.MM.yyyy').format(time); // пример: 12.01.2022
    }
  }

  static String _pluralEnding(int value) {
    if (value % 10 == 1 && value % 100 != 11) return 'у';
    if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) return 'ы';
    return '';
  }
}
