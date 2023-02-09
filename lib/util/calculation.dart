import 'package:decimal/decimal.dart';

class Calculator {
  final _data = <String>[];

  void add(String char) {
    if (_data.isEmpty) {
      if (_isOperator(char)) return;
      if (_isDot(char)) {
        _data.add('0.');
        return;
      }
      _data.add(char);
    } else if (_isOperator(_data.last)) {
      if (_isOperator(char)) _data.removeLast();
      _data.add(char);
    } else {
      if (_isOperator(char)) {
        if(_data.length == 3) calculate();
        _data.add(char);
        return;
      }
      if (_hasDot(_data.last) && _isDot(char)) return;
      _data.last += char;
    }
  }

  void clear() {
    _data.clear();
  }

  bool _hasDot(String char) => RegExp(r'\.').hasMatch(char);

  bool _isOperator(String char) => RegExp(r'^[+/\-x÷]$').hasMatch(char);

  bool _isDot(String char) => RegExp(r'^\.$').hasMatch(char);

  void remove() {
    if (_data.isEmpty) return;
    if (_data.last.length > 1) {
      _data.last = _data.last.substring(0, _data.last.length - 1);
    } else {
      _data.removeLast();
    }
  }

  void calculate() {
    if (_data.isNotEmpty && _data.last == '.') {
      _data.removeLast();
    }
    if (_data.isNotEmpty && _isOperator(_data.last)) {
      _data.removeLast();
    }

    if (_data.isNotEmpty && _data.last.lastIndexOf('.') == _data.last.length - 1) {
      _data.last = _data.last.substring(0, _data.last.length - 1);
    }

    if (_data.length == 3) {
      String command = _data[1];
      if (command == "+") {
        var decimal = Decimal.parse(_data.first);
        var r = decimal + Decimal.parse(_data.last);
        _setAnswer(r);
        _removeLastTwoInputs();
      }

      if (command == "-") {
        var decimal = Decimal.parse(_data.first);
        var r = decimal - Decimal.parse(_data.last);
        _setAnswer(r);
        _removeLastTwoInputs();
      }

      if (command == "x") {
        var decimal = Decimal.parse(_data.first);
        var r = decimal * Decimal.parse(_data.last);
        _setAnswer(r);
        _removeLastTwoInputs();
      }

      if (command == "/") {
        var decimal = Decimal.parse(_data.first);
        if (!(_data.last == '0')) {
          var r = decimal / Decimal.parse(_data.last);
          _setAnswer(r);
        }
        _removeLastTwoInputs();
      }
    }
  }

  void _setAnswer(dynamic r) {
    if(r.isInteger) {
      _data.first = r.toBigInt().toInt().toString();
    } else {
      _data.first =
          r.toDouble().toStringAsFixed(2);
    }
  }

  void _removeLastTwoInputs() {
     _data.removeLast();
    _data.removeLast();
  }

  String getString() {
    return _data.join(" ");
  }
}
