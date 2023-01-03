import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'product_type.dart';

class Expenditure extends Equatable {
  final int? id;
  final String product;
  final String? description;
  final PaymentType paymentType;
  final ProductType type;
  final Priority priority;
  final int price;
  final String date;

  const Expenditure.withDate(
      this.product,
      this.description,
      this.paymentType,
      this.type,
      this.date,
      this.price,
      this.priority,
      ): id = null;

  static String _generateDate() {
    var d = DateTime.now();
    d = DateTime.utc(d.year, d.month, d.day);
    return d.toIso8601String();
  }

  Expenditure.latest(this.product, this.description, this.paymentType,
      this.type, this.price, this.priority): id = null, date = _generateDate();

  const Expenditure(this.id, this.product, this.description, this.paymentType,
      this.type, this.price, this.date, this.priority);

  static Expenditure fromMap(Map<String, dynamic> json) {
    int id = json["eid"];
    String product = json["eproduct"];
    String? description = json["edesc"];
    PaymentType paymentType = PaymentType.values[json["epay"]];
    int price = json["eprice"];
    String date = json["edate"];
    Priority p = Priority.values[json["epri"]];

    return Expenditure(id, product, description, paymentType,
        ProductType.fromMap(json), price, date, p);
  }

  String get formattedDate {
    return DateFormat('EEE,dd MMM yyyy').format(DateTime.parse(date));
  }

  Map<String, dynamic> toJson() {
    return {
      "product": product,
      "description": description,
      "payment_type": paymentType.index,
      "product_type_id": type.id,
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