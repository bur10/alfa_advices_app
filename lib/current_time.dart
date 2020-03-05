import 'package:intl/intl.dart';

class CurrentTime {
  static String currentTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var format = DateFormat('d/M/y').add_Hm();
    return format.format(dateTime);
  }
}
