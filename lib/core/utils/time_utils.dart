import 'package:intl/intl.dart';

class TimeUtils {
  static String formatAge(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 30) {
      return 'Just now';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  static String formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM dd, hh:mm:ss a').format(timestamp);
  }

  static bool isOlderThanMinutes(DateTime timestamp, int minutes) {
    return DateTime.now().difference(timestamp).inMinutes > minutes;
  }
}
