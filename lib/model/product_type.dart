import 'package:equatable/equatable.dart';

class ProductType extends Equatable{
  final int id;
  final String name;

  const ProductType(this.id, this.name);

  toMap() => {"id": id, "name": name};

  static fromMap(Map<String, dynamic> map) {
    int id = map["pid"];
    String name = map["pname"];
    return ProductType(id, name);
  }

  @override
  List<Object?> get props => [id, name];
}