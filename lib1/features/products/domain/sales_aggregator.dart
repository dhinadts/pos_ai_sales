import 'package:intl/intl.dart';
import 'sales_record.dart';

class SalesAggregator {
  // sum by day -> Map<Date, total>
  static Map<String, double> sumByDay(List<SalesRecord> data) {
    final fmt = DateFormat('yyyy-MM-dd');
    final map = <String, double>{};
    for (final r in data) {
      final key = fmt.format(r.date);
      map[key] = (map[key] ?? 0) + r.total;
    }
    return map;
  }

  // week number of year
  static Map<String, double> sumByWeek(List<SalesRecord> data) {
    final fmt = DateFormat('yyyy');
    final map = <String, double>{};
    for (final r in data) {
      final week = _weekOfYear(r.date);
      final key = '${fmt.format(r.date)}-W$week';
      map[key] = (map[key] ?? 0) + r.total;
    }
    return map;
  }

  static int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysPassed = date.difference(firstDayOfYear).inDays;
    return (daysPassed / 7).floor() + 1;
  }

  static Map<String, double> sumByMonth(List<SalesRecord> data) {
    final map = <String, double>{};
    final fmt = DateFormat('yyyy-MM');
    for (final r in data) {
      final k = fmt.format(r.date);
      map[k] = (map[k] ?? 0) + r.total;
    }
    return map;
  }

  static Map<String, double> sumByQuarter(List<SalesRecord> data) {
    final map = <String, double>{};
    for (final r in data) {
      final q = ((r.date.month - 1) ~/ 3) + 1;
      final key = '${r.date.year}-Q$q';
      map[key] = (map[key] ?? 0) + r.total;
    }
    return map;
  }

  static Map<String, double> sumByYear(List<SalesRecord> data) {
    final map = <String, double>{};
    for (final r in data) {
      final key = r.date.year.toString();
      map[key] = (map[key] ?? 0) + r.total;
    }
    return map;
  }

  /* static Map<String, double> aggregate(List<SalesRecord> data, ReportRange range) {
    switch (range) {
      case ReportRange.daily:
        return sumByDay(data);
      case ReportRange.weekly:
        return sumByWeek(data);
      case ReportRange.monthly:
        return sumByMonth(data);
      case ReportRange.quarterly:
        return sumByQuarter(data);
      case ReportRange.yearly:
        return sumByYear(data);
    }
  } */
}
