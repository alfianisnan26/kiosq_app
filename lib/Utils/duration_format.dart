import 'package:intl/intl.dart';
import 'package:kiosq_app/Variables/global.dart';

String lastSeen(DateTime date, {String online = "Online"}) {
  if (const Duration(minutes: 2).compareTo(DateTime.now().difference(date)) >=
      0) return online;
  final Duration dif = DateTime.now().difference(date);
  if (dif.compareTo(const Duration(hours: 1)) < 0) {
    return "${dif.inMinutes} ${Global.str.minutes} ${Global.str.ago}";
  } else if (dif.compareTo(const Duration(days: 1)) < 0) {
    return "${dif.inHours} ${Global.str.hours} ${Global.str.ago}";
  } else if (dif.compareTo(const Duration(days: 30)) < 0) {
    return "${dif.inDays} ${Global.str.days} ${Global.str.ago}";
  } else {
    return DateFormat(
      DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY,
    ).format(date);
  }
}

String clockFormat(DateTime date) {
  return DateFormat(DateFormat.HOUR_MINUTE).format(date);
}
