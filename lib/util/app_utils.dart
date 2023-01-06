import 'package:decimal/decimal.dart';

class AppUtils {
  static int getAmount(String amount) {
    var d = Decimal.parse(amount);
    var r = d * Decimal.fromInt(100);
    return r.toBigInt().toInt();
  }
}