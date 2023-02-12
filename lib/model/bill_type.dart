import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bill_type.g.dart';

@JsonSerializable()
class BillType extends Equatable {
  @JsonKey(name: "bill_type")
  final int id;

  @JsonKey(name: "bill_name")
  final String name;

  @JsonKey(name: "bill_image")
  final String image;

  const BillType(this.id, this.name, this.image);

  factory BillType.fromMap(Map<String, dynamic> json) =>
      _$BillTypeFromJson(json);

  Map<String, dynamic> toJson() => _$BillTypeToJson(this);

  @override
  List<Object?> get props => [id, name];
}