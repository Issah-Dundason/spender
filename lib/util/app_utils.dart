import 'package:decimal/decimal.dart';


extension IntBool on bool {
  int get toInt => this ? 1 : 0;
}

class AppUtils {
  static int getActualAmount(String amount) {
    var d = Decimal.parse(amount);
    var r = d * Decimal.fromInt(100);
    return r.toBigInt().toInt();
  }

  static double amountPresented(int price) {
    Decimal d = Decimal.fromInt(price);
    var r = d / Decimal.fromInt(100);
    return r.toDouble();
  }
}