import 'package:intl/intl.dart';
import '../constant/constants.dart';

class Val {
  // Validations
  static String? validateTitle(String? val) {
    if (val == null || val.isEmpty) {
      return  "Title cannot be empty";
    }
    return null;
  }

  static String getExpiryStr(String expires) {
    var e = DateUtils.convertToDate(expires);
    var td = DateTime.now();
    if (e == null) {
      throw const FormatException('expires cannot be null');
    }
    Duration dif = e.difference(td);
    int dd = dif.inDays + 1;
    return (dd > 0) ? dd.toString() : "0";
  }

  static bool strToBool(String str) {
    return (int.parse(str) > 0) ? true : false;
  }

  static bool intToBool(int val) {
    return (val > 0) ? true : false;
  }

  static String boolToStr(bool val) {
    return (val == true) ? "1" : "0";
  }

  static int boolToInt(bool val) {
    return (val == true) ? 1 : 0;
  }
}

class DateUtils {
  static DateTime? convertToDate(String input) {
    try {
      var d = new DateFormat("yyyy-MM-dd").parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  static String convertToDateFull(String input) {
    try {
      var d = new DateFormat("yyyy-MM-dd").parseStrict(input);
      var formatter = new DateFormat('dd MMM yyyy');
      return formatter.format(d);
    } catch (e) {
      return Constants.empty;
    }
  }

  static String convertToDateFullDt(DateTime input) {
    try {
      var formatter = DateFormat('dd MMM yyyy');
      return formatter.format(input);
    } catch (e) {
      return Constants.empty;
    }
  }

  static bool isDate(String dt) {
    try {
      var d = new DateFormat("yyyy-MM-dd").parseStrict(dt);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidDate(String dt) {
    if (dt.isEmpty || !dt.contains("-") || dt.length < 10) return false;
    List<String> dtItems = dt.split("-");
    var d = DateTime(
        int.parse(dtItems[0]), int.parse(dtItems[1]), int.parse(dtItems[2]));
    return isDate(dt) && d.isAfter(new DateTime.now());
  }

  // String functions
  static String daysAheadAsStr(int daysAhead) {
    var now = new DateTime.now();
    DateTime ft = now.add(new Duration(days: daysAhead));
    return ftDateAsStr(ft);
  }

  static String ftDateAsStr(DateTime ft) {
    return "${ft.year}-${ft.month.toString().padLeft(2, "0")}-${ft.day.toString().padLeft(2, "0")}";
  }

  static String trimDate(String dt) {
    if (dt.contains(" ")) {
      List<String> p = dt.split(" ");
      return p[0];
    } else {
      return dt;
    }
  }
}
