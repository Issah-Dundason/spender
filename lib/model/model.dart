import 'package:equatable/equatable.dart';

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

class ProductType extends Equatable{
  final int id;
  final String name;

  const ProductType(this.id, this.name);

  toMap() => {"id": id, "name": name};

  static fromMap(Map<String, dynamic> map) {
    int id = map["pid"];
    String name = map["pname"];
    return ProductType(id, name);
  }

  @override
  List<Object?> get props => [id, name];
}

enum PaymentType { cash, cheque, momo, vodafoneCash }

enum Priority { need, want }

class Budget extends Equatable{
  final int? id;
  final int amount;

  ///date is yyyy-MM-dd formatted
  ///dd must should be set to the first day of the month
  final String date;

  const Budget(this.date, this.amount): id = null;

  const Budget.date(this.date) : amount = 0, id = null;

  Map<String, dynamic> toMap() => {"amount": amount, "date": date};

  Budget.fromMap(Map<String, dynamic> map)
      : date = map["date"],
        amount = map["amount"], id = map["id"];

  @override
  List<Object?> get props => [id, amount, date];
}
