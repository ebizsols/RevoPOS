import 'package:money2/money2.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/utils/html_unescape.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';

class MultiCurrency {
  static String convert(double idr, context) {
    final currency = Provider.of<LoginNotifier>(context, listen: false);
    var symbol = '';
    var code = 'IDR';
    var thousandSeparator = '.';
    var decimalSeparator = ',';
    var decimalNumber = 0;
    bool invertSeparators = false;

    symbol = currency.currencySymbol!.symbol != null
        ? Unescape.htmlToString(currency.currencySymbol!.symbol!)
        : '';
    code = currency.currencySymbol!.value;
    decimalNumber = currency.decimalNumber!.value != null
        ? int.parse(currency.decimalNumber!.value)
        : 0;
    thousandSeparator = currency.thousandSeparator!.value ?? ".";
    decimalSeparator = currency.decimalSeparator!.value ?? ",";

    if (thousandSeparator == '.' && decimalSeparator == '.') {
      decimalSeparator = ',';
    } else if (thousandSeparator == ',' && decimalSeparator == ',') {
      decimalSeparator = '.';
    }

    var pattern = '';

    if (decimalNumber == 0) {
      pattern = 'S#$thousandSeparator###';
    } else if (decimalNumber == 1) {
      pattern = 'S#$thousandSeparator###${decimalSeparator}0';
    } else if (decimalNumber == 2) {
      pattern = 'S#$thousandSeparator###${decimalSeparator}00';
    } else if (decimalNumber == 3) {
      pattern = 'S#$thousandSeparator###${decimalSeparator}000';
    }

    if (thousandSeparator == '.' && decimalSeparator == ',') {
      invertSeparators = true;
    }

    final currencyConvert = Currency.create(code, 3,
        invertSeparators: invertSeparators, symbol: symbol, pattern: pattern);
    final convertedPrice = Money.fromNumWithCurrency(idr, currencyConvert);
    return convertedPrice.toString();
  }
}
