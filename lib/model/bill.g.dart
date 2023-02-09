// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) => Bill(
      id: json['id'] as int?,
      title: json['title'] as String,
      type: mapToBillType(json['type'] as Map<String, dynamic>),
      priority: $enumDecode(_$PriorityEnumMap, json['priority']),
      paymentType: $enumDecode(_$PaymentTypeEnumMap, json['payment_type']),
      description: json['description'] as String?,
      isRecurring: json['is_recurring'] == null
          ? false
          : isRecurringFromJson(json['is_recurring'] as int),
      pattern: patternFromIndex(json['pattern'] as int),
      parentId: json['parent_id'] as int?,
      paymentDateTime: json['payment_datetime'] as String,
      amount: json['amount'] as int,
      exceptionId: json['exception_id'] as int?,
      endDate: json['end_date'] as String?,
    );

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': billTypeToId(instance.type),
      'priority': _$PriorityEnumMap[instance.priority]!,
      'payment_type': _$PaymentTypeEnumMap[instance.paymentType]!,
      'description': instance.description,
      'is_recurring': isRecurringToJson(instance.isRecurring),
      'pattern': patternToInt(instance.pattern),
      'parent_id': instance.parentId,
      'payment_datetime': instance.paymentDateTime,
      'amount': instance.amount,
      'exception_id': instance.exceptionId,
      'end_date': instance.endDate,
    };

const _$PriorityEnumMap = {
  Priority.need: 'need',
  Priority.want: 'want',
};

const _$PaymentTypeEnumMap = {
  PaymentType.cash: 'cash',
  PaymentType.cheque: 'cheque',
  PaymentType.momo: 'momo',
  PaymentType.vodafoneCash: 'vodafoneCash',
};
