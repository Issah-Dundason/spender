import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'bill_type.dart';

class Expenditure extends Equatable {
  final int? id;
  final String bill;
  final String? description;
  final PaymentType paymentType;
  final BillType type;
  final Priority priority;
  final int price;
  final String date;

  const Expenditure.withDate(
      this.bill,
      this.description,
      this.paymentType,
      this.type,
      this.date,
      this.price,
      this.priority,
      ): id = null;

  static String _generateDate() {
    var d = DateTime.now();
    d = DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second);
    return d.toIso8601String();
  }

  Expenditure.latest(this.bill, this.description, this.paymentType,
      this.type, this.price, this.priority): id = null, date = _generateDate();

  const Expenditure(this.id, this.bill, this.description, this.paymentType,
      this.type, this.price, this.date, this.priority);

  static Expenditure fromMap(Map<String, dynamic> json) {
    int id = json["eid"];
    String bill = json["ebill"];
    String? description = json["edesc"];
    PaymentType paymentType = PaymentType.values[json["epay"]];
    int price = json["eprice"];
    String date = json["edate"];
    Priority p = Priority.values[json["epri"]];

    return Expenditure(id, bill, description, paymentType,
        BillType.fromMap(json), price, date, p);
  }

  String get formattedDate {
    return DateFormat('EEE,dd MMM yyyy').format(DateTime.parse(date));
  }

  String get cash {
    Decimal d = Decimal.fromInt(price);
    var r = d / Decimal.fromInt(100);
    return '${r.toDouble()}';
  }

  Map<String, dynamic> toJson() {
    return {
      "bill": bill,
      "description": description,
      "payment_type": paymentType.index,
      "bill_type_id": type.id,
      "price": price,
      "date": date,
      "priority": priority.index
    };
  }

  @override
  List<Object?> get props => [id, date, price, priority];
}

enum PaymentType { cash, cheque, momo, vodafoneCash }

enum Priority { need, want }