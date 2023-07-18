import 'package:flutter/material.dart';

class MyDateTime {
  static String formatDateTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageDate(
      {required BuildContext context, required String time}) {
    final send = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final now = DateTime.now();

    if (now.day == send.day &&
        now.month == send.month &&
        now.year == send.year) {
      return TimeOfDay.fromDateTime(send).format(context);
    }

    return "${send.day} ${_getMonth(send)}";
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActiveTime}) {
    final int i = int.tryParse(lastActiveTime) ?? -1;
    if (i == -1) return "Last seen not available";

    final time = DateTime.fromMillisecondsSinceEpoch(i);
    final now = DateTime.now();

    String formattedtime = TimeOfDay.fromDateTime(time).format(context);

    if (time.day == now.day &&
        time.month == now.month &&
        now.year == time.year) {
      return "Last seen today at $formattedtime";
    }
    if ((now.difference(time).inHours / 24).round() == 1)
      return "Last seen yesterday at $formattedtime";

    return "Last seen on ${time.day} ${_getMonth(time)} on $formattedtime";
  }

  static String _getMonth(DateTime time) {
    switch (time.month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
    }
    return "NA";
  }
}
