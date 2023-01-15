import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:spender/util/app_utils.dart';

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
    return DateFormat('EEE,dd MMM yyyy').format(DateTime.parse(date).toLocal());
  }

  double get cash {
    var cash = AppUtils.amountPresented(price);
    return cash;
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
  List<Object?> get props => [id, date, price, priority, description, paymentType];
}

enum PaymentType { cash, cheque, momo, vodafoneCash }

enum Priority { need, want }