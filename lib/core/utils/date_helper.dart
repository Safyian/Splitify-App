class SplitifyDateUtils {
  static String formatExpenseDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDay = DateTime(date.year, date.month, date.day);

    if (expenseDay == today) return 'Today';
    if (expenseDay == yesterday) return 'Yesterday';

    // Same year — show "21 Feb"
    if (date.year == now.year) {
      return '${date.day} ${_month(date.month)}';
    }

    // Different year — show "21 Feb 2024"
    return '${date.day} ${_month(date.month)} ${date.year}';
  }

  static String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Add to SplitifyDateUtils

  static String monthYearKey(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${_month(date.month)} ${date.year}';
  }

  static List<MapEntry<String, List<T>>> groupByMonth<T>(
    List<T> items,
    DateTime? Function(T) dateSelector,
  ) {
    final Map<String, List<T>> grouped = {};

    for (final item in items) {
      final key = monthYearKey(dateSelector(item));
      grouped.putIfAbsent(key, () => []).add(item);
    }

    // Sort by most recent month first
    final sorted = grouped.entries.toList()
      ..sort((a, b) {
        final aDate = _parseMonthYear(a.key);
        final bDate = _parseMonthYear(b.key);
        return bDate.compareTo(aDate);
      });

    return sorted;
  }

  static DateTime _parseMonthYear(String key) {
    if (key == 'Unknown') return DateTime(2000);
    final parts = key.split(' ');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months.indexOf(parts[0]) + 1;
    final year = int.parse(parts[1]);
    return DateTime(year, month);
  }
}
