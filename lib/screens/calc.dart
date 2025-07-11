import "package:charcode/charcode.dart";
import 'package:checknotion/widgets/calc_button.dart';
import 'package:flutter/material.dart';

class Calc extends StatefulWidget {
  const Calc({super.key});

  @override
  _CalcState createState() => _CalcState();
}

class _CalcState extends State<Calc> {
  var _firstOperand = '0';
  var _result = '0';
  var _clearResult = false;
  var _operator = '';
  var _hasFirstOperandList = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    var operatorColor = Theme.of(context).colorScheme.secondary;
    var width = MediaQuery.of(context).size.width;
    var space = 15;
    var margin = (width - (width / 4 - width / space) * 4) / 5;
    return Scaffold(
      appBar: AppBar(
        title: IndexedStack(children: [Center(child: Text('Taschenrechner'))]),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Input / Output
          Container(
            height: MediaQuery.of(context).size.height * 0.14,
            width: MediaQuery.of(context).size.width * 0.88,
            padding: EdgeInsets.only(top: 30.0),
            child: FittedBox(
              alignment: Alignment.centerRight,
              child: Text(
                (_existsFirstOperand() ? _firstOperand : _result).replaceAll(
                  '.',
                  ',',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          // AC +/- % /
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CalcButton(
                text: 'AC',
                callback: () {
                  setState(() {
                    _result = "0";
                    _resetFirstOperand();
                  });
                },
                textColor: Colors.black,
                backgroundColor: Colors.black12,
              ),
              CalcButton(
                text: '+/-',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    if (_checkErrors()) return;
                    if (_result != '0' &&
                        (_result.length < 10 ||
                            (_result.length == 10 &&
                                _result.startsWith('-')))) {
                      if (_result.contains('-')) {
                        _result = _result.replaceAll('-', '');
                      } else {
                        _result = '-$_result';
                      }
                    }
                  });
                },
                textColor: Colors.black,
                backgroundColor: Colors.black12,
              ),
              CalcButton(
                text: String.fromCharCode($percent),
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    if (_checkErrors() || _result == '0') return;
                    var result = double.parse(_result) / 100;
                    if (_outOfBounds(result)) {
                      _result = 'Fehler!';
                      return;
                    }
                    _result = _truncToNum(result);
                    _clearResult = true;
                  });
                },
                textColor: Colors.black,
                backgroundColor: Colors.black12,
              ),
              CalcButton(
                text: String.fromCharCode($divide),
                callback: () {
                  setState(() {
                    _operator = '/';
                    _setFirstOperand(0);
                  });
                },
                backgroundColor: operatorColor,
                isPressed: _hasFirstOperandList,
                index: 0,
              ),
            ],
          ),
          // 7 8 9 *
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CalcButton(
                text: '7',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('7');
                  });
                },
              ),
              CalcButton(
                text: '8',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('8');
                  });
                },
              ),
              CalcButton(
                text: '9',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('9');
                  });
                },
              ),
              CalcButton(
                text: String.fromCharCode($times),
                callback: () {
                  setState(() {
                    _operator = '*';
                    _setFirstOperand(1);
                  });
                },
                backgroundColor: operatorColor,
                isPressed: _hasFirstOperandList,
                index: 1,
              ),
            ],
          ),
          // 4 5 6 -
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CalcButton(
                text: '4',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('4');
                  });
                },
              ),
              CalcButton(
                text: '5',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('5');
                  });
                },
              ),
              CalcButton(
                text: '6',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('6');
                  });
                },
              ),
              CalcButton(
                text: String.fromCharCode($minus),
                callback: () {
                  setState(() {
                    _operator = '-';
                    _setFirstOperand(2);
                  });
                },
                backgroundColor: operatorColor,
                isPressed: _hasFirstOperandList,
                index: 2,
              ),
            ],
          ),
          // 1 2 3 +
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CalcButton(
                text: '1',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('1');
                  });
                },
              ),
              CalcButton(
                text: '2',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('2');
                  });
                },
              ),
              CalcButton(
                text: '3',
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    _concat('3');
                  });
                },
              ),
              CalcButton(
                text: String.fromCharCode($plus),
                callback: () {
                  setState(() {
                    _operator = '+';
                    _setFirstOperand(3);
                  });
                },
                backgroundColor: operatorColor,
                isPressed: _hasFirstOperandList,
                index: 3,
              ),
            ],
          ),
          // 0 , =
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: (width / 4 - width / space) * 2 + margin,
                child: CalcButton(
                  text: '0',
                  callback: () {
                    setState(() {
                      _resetFirstOperand();
                      _resetResult();
                      _concat('0');
                    });
                  },
                  isZero: true,
                ),
              ),
              CalcButton(
                text: String.fromCharCode($comma),
                callback: () {
                  setState(() {
                    _resetFirstOperand();
                    _resetResult();
                    if (!_result.contains('.') && _result.length < 10)
                      _result += '.';
                  });
                },
              ),
              CalcButton(
                text: String.fromCharCode($equal),
                callback: () {
                  setState(() {
                    if (_checkErrors()) return;
                    var op1 = double.parse(_firstOperand);
                    var op2 = double.parse(_result);
                    Object result;
                    switch (_operator) {
                      case '/':
                        if (op2 != 0)
                          result = op1 / op2;
                        else
                          result = 'Fehler!';
                        break;
                      case '*':
                        result = op1 * op2;
                        break;
                      case '-':
                        result = op1 - op2;
                        break;
                      case '+':
                        result = op1 + op2;
                        break;
                      default:
                        result = op2;
                    }
                    if (_checkErrors(result: result) ||
                        _outOfBounds(result is double ? result : double.nan)) {
                      _result = 'Fehler!';
                    } else {
                      if (result is double) {
                        _result = _truncToNum(result);
                      } else {
                        _result = result.toString();
                      }
                    }

                    _operator = '';
                    _firstOperand = '0';
                    _clearResult = true;
                    _resetFirstOperand();
                  });
                },
                backgroundColor: operatorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetResult() {
    if (_clearResult) {
      _result = '0';
      _clearResult = false;
    }
  }

  void _setFirstOperand(int index) {
    _firstOperand = _result;
    _resetFirstOperand();
    _hasFirstOperandList[index] = true;
    _result = '0';
  }

  void _concat(String number) {
    if (_result == '0') _result = '';
    if (_result.length < 10) _result += number;
  }

  String _truncToNum(double number) {
    return number
        .toStringAsPrecision(9)
        .replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")
        .characters
        .take(10)
        .string;
  }

  bool _checkErrors({var result = ''}) {
    var error = 'Fehler!';
    return _result == error || _firstOperand == error || result == error;
  }

  bool _outOfBounds(double result) {
    var min = 1e-6;
    var max = 1e9 - 1;
    return (result > 0 && result < min) ||
        (result < 0 && result > -min) ||
        result > max ||
        result < -max;
  }

  bool _existsFirstOperand() {
    return _hasFirstOperandList.any((element) => element);
  }

  void _resetFirstOperand() {
    _hasFirstOperandList = [false, false, false, false];
  }
}
