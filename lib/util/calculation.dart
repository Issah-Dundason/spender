import 'package:decimal/decimal.dart';

class Calculator {
  final _data = <String>[];

  void add(String char) {
    if (_data.isEmpty) {
      if (_isOperator(char)) return;
      if (_hasDot(char)) {
        _data.add('0.');
        return;
      }
      _data.add(char);
    } else if (_isOperator(_data.last)) {
      if(_isOperator(char)) _data.removeLast();
      _data.add(char);
    } else {
      if(_isOperator(char)) {
        _data.add(char);
        return;
      }
      if(_hasDot(_data.last) && _hasDot(char)) return;
      _data.last += char;
    }
  }

  bool _isOperator(String char) => RegExp(r'[+/\-x÷]').hasMatch(char);

  bool _hasDot(String char) => RegExp(r'\.').hasMatch(char);

  void remove() {
    if (_data.isEmpty) return;
    if (_data.last.length > 1) {
      _data.last = _data.last.substring(0, _data.last.length - 1);
    } else {
      _data.removeLast();
    }
  }

  void calculate() {
    if (_data.last == '.') {
      _data.removeLast();
    }
    if (_isOperator(_data.last)) {
      _data.removeLast();
    }

    if (_data.last.lastIndexOf('.') == _data.last.length - 1) {
      _data.last = _data.last.substring(0, _data.length - 1);
    }

    if (_data.length == 3) {
      String command = _data[1];
      if (command == "+") {
        var decimal = Decimal.parse(_data.first);
        var r = decimal + Decimal.parse(_data.last);
        _data.first = r.toDouble().toString();
        _data.removeLast();
        _data.removeLast();
      }

      if (command == "-") {
        var decimal = Decimal.parse(_data.first);
        var r = decimal - Decimal.parse(_data.last);
        _data.first = r.toDouble().toString();
        _data.removeLast();
        _data.removeLast();
      }

      if (command == "x") {
        var decimal = Decimal.parse(_data.first);
        var r = decimal * Decimal.parse(_data.last);
        _data.first = r.toDouble().toString();
        _data.removeLast();
        _data.removeLast();
      }

      if (command == "/") {
        var decimal = Decimal.parse(_data.first);
        if(!(_data.last == '0')) {
          var r = decimal / Decimal.parse(_data.last);
          _data.first = r.toDouble().toString();
        }
        _data.removeLast();
        _data.removeLast();
      }
    }
  }

  String getString() {
    return _data.join(" ");
  }
}
