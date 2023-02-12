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

@JsonSerializable()
class Bill extends Equatable {
  static const String columnID = 'id';
  static const String columnBillType = 'bill_type';
  static const String columnBillTypeGenerated = 'type';
  static const String columnPaymentType = 'payment_type';
  static const String columnPaymentDate = 'payment_datetime';
  static const String columnParentId = 'parent_id';
  static const String columnExceptionParentId = 'expenditure_id';
  static const String columnExceptionId = 'exception_id';
  static const String columnEndDate = 'end_date';
  static const String columnAmount = 'amount';
  static const String columnDeleted = 'deleted';
  static const String columnPriority = 'priority';
  static const String columnPattern = 'pattern';
  static const String columnExceptionInstanceDate = 'instance_date';

  final int? id;

  final String title;

  @JsonKey(name: "type", toJson: billTypeToId, fromJson: mapToBillType)
  final BillType type;

  final Priority priority;

  @JsonKey(name: columnPaymentType)
  final PaymentType paymentType;

  final String? description;

  @JsonKey(toJson: patternToInt, fromJson: patternFromIndex)
  final Pattern pattern;

  @JsonKey(name: columnParentId)
  final int? parentId;

  @JsonKey(name: columnPaymentDate)
  final String paymentDateTime;

  final int amount;

  @JsonKey(name: columnExceptionId)
  final int? exceptionId;

  @JsonKey(name: columnEndDate)
  final String? endDate;

  const Bill(
      {this.id,
      required this.title,
      required this.type,
      required this.priority,
      required this.paymentType,
      this.description,
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
        pattern: pattern ?? this.pattern,
        parentId: parentId ?? this.parentId,
        paymentDateTime: paymentDateTime ?? this.paymentDateTime,
        amount: amount ?? this.amount,
        exceptionId: exceptionId ?? this.exceptionId,
        endDate: endDate ?? this.endDate);
  }

  Map<String, dynamic> toNewBillJson() {
    var json = toJson();
    json.remove(columnID);
    json.remove(columnExceptionId);
    json[columnBillType] = json[columnBillTypeGenerated];
    json.remove(columnBillTypeGenerated);
    return json;
  }

  Map<String, dynamic> toExceptionJson(String instanceDate) {
    DateTime date = DateTime.parse(instanceDate);
    var exceptionDate = DateFormat('yyyy-MM-dd').format(date);
    var json = toJson();
    var exclusion = [
      columnID,
      columnExceptionId,
      columnPattern,
      columnEndDate
    ];
    for (var key in exclusion) {
      json.remove(key);
    }
    json[columnExceptionParentId] = json[columnParentId];
    json[columnExceptionInstanceDate] = exceptionDate;
    json[columnBillType] = json[columnBillTypeGenerated];
    json.remove(columnBillTypeGenerated);
    json.remove(columnParentId);
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

  bool get isGenerated =>  id == -1;

  bool get isRecurring => pattern != Pattern.once;

  static List<String> differentFields(Bill a, Bill b) {
    var aMap = a.toJson();
    var bMap = b.toJson();

    var keys = aMap.keys;

    return keys.fold(<String>[], (prev, curr) {
      if (curr == columnEndDate || curr == columnPaymentDate) {
        if (aMap[curr] == null && bMap[curr] == null) return prev;

        if (aMap[curr] == null && bMap[curr] != null ||
            bMap[curr] == null && aMap[curr] != null) {
          prev.add(curr);
          return prev;
        }

        if (DateTime.parse(aMap[curr]).toIso8601String() !=
            DateTime.parse(bMap[curr]).toIso8601String()) {
          prev.add(curr);
        }

        return prev;
      }
      if (aMap[curr] != bMap[curr]) prev.add(curr);
      return prev;
    });
  }

  @override
  List<Object?> get props {
    return [
      id,
      pattern,
      parentId,
      paymentDateTime,
      amount,
      priority,
      description,
      paymentType,
      endDate,
      title,
      description,
      type];
  }
}
