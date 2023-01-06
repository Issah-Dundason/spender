import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Budget extends Equatable {
  final int? id;
  final int amount;

  ///date is yyyy-MM-dd formatted
  ///dd must should be set to the first day of the month
  final String date;

  const Budget(this.date, this.amount) : id = null;

  const Budget.all(
      {required this.id, required this.date, required this.amount});

  const Budget.date(this.date)
      : amount = 0,
        id = null;

  Map<String, dynamic> toMap() => {"amount": amount, "date": date};

  copyWith({int? amount}) {
    return Budget.all(id : id, date: date, amount: amount ?? this.amount);
  }

  String get formattedDate {
    return DateFormat("yyyy mm").format(DateTime.parse(date));
  }

  Budget.fromMap(Map<String, dynamic> map)
      : date = map["date"],
        amount = map["amount"],
        id = map["id"];

  @override
  List<Object?> get props => [id, amount, date];
}