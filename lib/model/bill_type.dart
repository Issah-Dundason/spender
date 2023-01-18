import 'package:equatable/equatable.dart';

class BillType extends Equatable{
  final int id;
  final String name;
  final String image;

  const BillType(this.id, this.name, this.image);

  toMap() => {"id": id, "name": name};

  static fromMap(Map<String, dynamic> map) {
    int id = map["pid"];
    String name = map["pname"];
    String image = map["pimage"];
    return BillType(id, name, image);
  }

  @override
  List<Object?> get props => [id, name];
}