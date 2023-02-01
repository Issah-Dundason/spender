import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spender/util/app_utils.dart';

import 'bill_type.dart';

part 'bill.g.dart';

enum Pattern { once, daily, weekly, monthly }

enum PaymentType { cash, cheque, momo, vodafoneCash }

enum Priority { need, want }

int billTypeToId(BillType type) {
  return type.id;
}

BillType mapToBillType(Map<String, dynamic> map) {
  return BillType.fromMap(map);
}

int patternToInt(Pattern pattern) {
  return pattern.index;
}

Pattern patternFromIndex(int index) {
  return Pattern.values[index];
}

int isRecurringToJson(bool value) {
  return value == true ? 1 : 0;
}

bool isRecurringFromJson(int value) {
  return value == 1;
}

@JsonSerializable()
class Bill extends Equatable {
  final int? id;

  final String title;

  @JsonKey(name: "type", toJson: billTypeToId, fromJson: mapToBillType)
  final BillType type;

  final Priority priority;

  @JsonKey(name: "payment_type")
  final PaymentType paymentType;

  final String? description;

  @JsonKey(
      name: "is_recurring",
      toJson: isRecurringToJson,
      fromJson: isRecurringFromJson)
  final bool isRecurring;

  @JsonKey(toJson: patternToInt, fromJson: patternFromIndex)
  final Pattern pattern;

  @JsonKey(name: "parent_id")
  final int? parentId;

  @JsonKey(name: "payment_datetime")
  final String paymentDateTime;

  final int amount;

  @JsonKey(name: "exception_id")
  final int? exceptionId;

  @JsonKey(name: "end_date")
  final String? endDate;

  const Bill(
      {this.id,
      required this.title,
      required this.type,
      required this.priority,
      required this.paymentType,
      this.description,
      this.isRecurring = false,
      required this.pattern,
      this.parentId,
      required this.paymentDateTime,
      required this.amount,
      this.exceptionId,
      this.endDate});

  Bill copyWith(
      {int? id,
      String? title,
      BillType? type,
      Priority? priority,
      PaymentType? paymentType,
      String? description,
      bool? isRecurring,
      Pattern? pattern,
      int? parentId,
      String? paymentDateTime,
      int? amount,
      int? exceptionId,
      String? endDate}) {
    return Bill(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        priority: priority ?? this.priority,
        paymentType: paymentType ?? this.paymentType,
        description: description ?? this.description,
        isRecurring: isRecurring ?? this.isRecurring,
        pattern: pattern ?? this.pattern,
        parentId: parentId ?? this.parentId,
        paymentDateTime: paymentDateTime ?? this.paymentDateTime,
        amount: amount ?? this.amount,
        exceptionId: exceptionId ?? this.exceptionId,
        endDate: endDate ?? this.endDate);
  }

  Map<String, dynamic> toNewBillJson() {
    var json = toJson();
    json.remove("id");
    json.remove('exception_id');
    json["bill_type"] = json["type"];
    json.remove("type");
    return json;
  }

  Map<String, dynamic> toJson() => _$BillToJson(this);

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  String get formattedDate {
    return DateFormat('EEE,dd MMM yyyy')
        .format(DateTime.parse(paymentDateTime));
  }

  double get cash {
    var cash = AppUtils.amountPresented(amount);
    return cash;
  }

  bool isGenerated() {
    return id == -1;
  }

  static List<String> differentFields(Bill a, Bill b) {

    var aMap = a.toJson();
    var bMap = b.toJson();

    var keys = aMap.keys;

    // keys.forEach((element) {
    //   print('''
    //     prop: $element
    //      a: ${aMap[element]}
    //      b: ${bMap[element]}
    //   ''');
    // });

    return keys.fold(<String>[], (prev, curr) {
      if(aMap[curr] != bMap[curr]) prev.add(curr);
      return prev;
    });
  }

  @override
  List<Object?> get props =>
      [id, paymentDateTime, amount, priority, description, paymentType];
}
