import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Formats ISO string (e.g. 2026-04-23T07:12:00Z) to HH:mm:ss
  static String formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "--:--";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('HH:mm:ss').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  /// Formats ISO string to HH:mm (no seconds — cleaner for UI display)
  static String formatTimeShort(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "--:--";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  /// Formats ISO string to dd/MM/yyyy
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "--/--/----";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      // Fallback: try splitting at 'T' for partial date strings like "2026-04-23T..."
      try {
        return isoString.split('T')[0].split('-').reversed.join('/');
      } catch (_) {
        return isoString;
      }
    }
  }

  /// Formats ISO string to "MMM d, yyyy" (e.g. Apr 23, 2026)
  static String formatDateReadable(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "---";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  /// Formats ISO string to dd/MM/yyyy HH:mm
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "--/--/---- --:--";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  /// Formats ISO string to friendly "MMM d, h:mm a" (e.g. Apr 23, 2:15 PM)
  static String formatFriendly(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "---";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  /// Custom format
  static String format(String? isoString, String pattern) {
    if (isoString == null || isoString.isEmpty) return "";
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat(pattern).format(dt);
    } catch (e) {
      return isoString;
    }
  }
}
