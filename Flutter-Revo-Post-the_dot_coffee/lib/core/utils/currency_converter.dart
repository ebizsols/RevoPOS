import 'package:revo_pos/core/constant/constants.dart';

class CurrencyConverter {
  static String currency(num number) {
    return currencyFormat.format(number);
  }
}