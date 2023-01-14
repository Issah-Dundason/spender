
import 'dart:math';

import 'package:spender/util/calculation.dart';
import 'package:test/test.dart';

void main() {
  test('adding . to the calculator and calling the toString returns 0.', () {
    var calc = Calculator();
    calc.add('.');
    expect(calc.getString(), equals('0.'));
  });

  test('adding a series of numbers after adding . returns a decimal value', () {
    var calc = Calculator();
    calc.add('.');
    calc.add('8');
    calc.add('9');
    expect(calc.getString(), '0.89');
  });

  test('adding a series of numbers returns the numbers concatenated', () {
    var calc = Calculator();
    calc.add('5');
    calc.add('6');
    calc.add('7');
    expect(calc.getString(), '567');
  });

  test(
      'adding a series of numbers followed by an operator (\\+-x) returns string with operator',
      () {
        var calc = Calculator();
        calc.add('5');
        calc.add('-');
        expect(calc.getString(), '5 -');
      });

  test('adding a . after an operator excludes the operator when calculate is called', () {
    var calc = Calculator();
    calc.add('4');
    calc.add('8');
    calc.add('/');
    calc.add('.');
    calc.calculate();
    expect(calc.getString(), '48');
  });

  test('only the first . is taken', () {
    var calc = Calculator();
    calc.add('.');
    calc.add('.');
    calc.add('8');
    expect(calc.getString(), equals('0.8'));
  });

  group('testing removal', () {
    test('removes last element completely if its length 1', () {
      var calc = Calculator();
      calc.add('5');
      calc.add('6');
      calc.add('/');
      calc.remove();
      expect(calc.getString(), equals('56'));
    });

    test('removes only the last element if length of last is > 1', () {
      var calc = Calculator();
      calc.add('5');
      calc.add('6');
      calc.add('/');
      calc.add('8');
      calc.add('7');
      calc.remove();
      expect(calc.getString(), equals('56 / 8'));
    });
  });


  group('testing calculation', () {
    test('first test', () {
      var calc = Calculator();
      calc.add('6');
      calc.add('7');
      calc.add('x');
      calc.add('-');
      calc.add('7');
      calc.add('.');
      calc.calculate();
      expect(true, equals(calc.getString().contains(RegExp(r'^60'))));
    });

    test('second test', () {
      var calc = Calculator();
      calc.add('7');
      calc.add('.');
      calc.add('2');
      calc.add('3');
      calc.add('x');
      calc.calculate();
      expect(calc.getString(), '7.23');
    });

    test('third test', () {
      var calc = Calculator();
      calc.add('8');
      calc.add('7');
      calc.add('.');
      calc.add('x');
      calc.add('0');
      calc.calculate();
      expect(true, calc.getString().contains(RegExp(r'^0\.?')));
    });

    test('fourth', () {
      var calc = Calculator();
      calc.add('8');
      calc.add('/');
      calc.add('4');
      calc.calculate();
      expect(true, equals(calc.getString().contains(RegExp(r'^2\.?'))));
    });

    test('only dot is removed', () {
      var calc = Calculator();
      calc.add('6');
      calc.add('.');
      calc.calculate();
      expect(calc.getString(), equals('6'));
    });

  });

  group('adding successive operators will make sure only the first one is returned', () {
    test('first test', () {
      var calc = Calculator();
      calc.add('5');
      calc.add('-');
      calc.add('x');
      expect(calc.getString(), '5 x');
    });

    test('second test', () {
      var calc = Calculator();
      calc.add('5');
      calc.add('/');
      calc.add('-');
      expect(calc.getString(), '5 -');
    });

    test('third test', () {
      var calc = Calculator();
      calc.add('5');
      calc.add('6');
      calc.add('7');
      calc.add('/');
      calc.add('-');
      calc.add('9');
      calc.add('8');
      expect(calc.getString(), '567 - 98');
    });
  });



  test('negative values are not deleted', () {
    var calc = Calculator();
    calc.add('5');
    calc.add('-');
    calc.add('6');
    calc.calculate();
    calc.add('-');
    expect(calc.getString(), equals('-1 -'));
  });
}
