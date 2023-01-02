import 'package:equatable/equatable.dart';

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