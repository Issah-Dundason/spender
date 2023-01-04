import 'package:equatable/equatable.dart';

class BillType extends Equatable{
  final int id;
  final String name;

  const BillType(this.id, this.name);

  toMap() => {"id": id, "name": name};

  static fromMap(Map<String, dynamic> map) {
    int id = map["pid"];
    String name = map["pname"];
    return BillType(id, name);
  }

  @override
  List<Object?> get props => [id, name];
}