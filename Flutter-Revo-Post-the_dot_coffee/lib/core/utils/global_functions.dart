import 'dart:developer';

import 'package:intl/intl.dart';

printLog(String message, {String? name}) {
  return log(message, name: name ?? 'log');
}

String dateFormater({String? date}) {
  DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(date!);
  var inputDate = DateTime.parse(parseDate.toString());
  var outputFormat = DateFormat('dd-MM-yyyy | hh:mm');
  var outputDate = outputFormat.format(inputDate);
  return outputDate;
}
