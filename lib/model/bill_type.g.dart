// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillType _$BillTypeFromJson(Map<String, dynamic> json) => BillType(
      json['bill_type'] as int,
      json['bill_name'] as String,
      json['bill_image'] as String,
    );

Map<String, dynamic> _$BillTypeToJson(BillType instance) => <String, dynamic>{
      'bill_type': instance.id,
      'bill_name': instance.name,
      'bill_image': instance.image,
    };
