class Expenditure {
  int? id;
  String product;
  String? description;
  PaymentType paymentType;
  ProductType type;
  Priority priority;
  int price;
  late String date;

  Expenditure.withDate(
    this.product,
    this.description,
    this.paymentType,
    this.type,
    this.date,
    this.price,
    this.priority,
  );

  Expenditure.latest(this.product, this.description, this.paymentType,
      this.type, this.price, this.priority) {
    var d = DateTime.now();
    d = DateTime.utc(d.year, d.month, d.day);
    date = d.toIso8601String();
  }

  Expenditure(this.id, this.product, this.description, this.paymentType,
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
}

class ProductType {
  final int id;
  final String name;

  ProductType(this.id, this.name);

  toMap() => {"id": id, "name": name};

  static fromMap(Map<String, dynamic> map) {
    int id = map["pid"];
    String name = map["pname"];
    return ProductType(id, name);
  }
}

enum PaymentType { cash, cheque, momo, vodafoneCash }

enum Priority { need, want }

class Budget {
  int amount;

  ///date is yyyy-MM formatted
  String date;

  Budget(this.date, this.amount);

  Budget.date(this.date) : amount = 0;

  Budget.fromMap(Map<String, dynamic> map)
      : date = map["date"],
        amount = map["amount"];
}
