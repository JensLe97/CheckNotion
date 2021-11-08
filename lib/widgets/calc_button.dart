import 'package:flutter/material.dart';

class CalcButton extends StatefulWidget {
  final String text;
  final VoidCallback callback;
  final Color textColor;
  final Color backgroundColor;
  final bool isZero;
  // For the operator buttons, to check if they are pressed
  // The index is used to check for a certain operation
  final List<bool> isPressed;
  final int index;

  const CalcButton({
    Key? key,
    required this.text,
    required this.callback,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black54,
    this.isZero = false,
    this.isPressed = const [false, false, false, false],
    this.index = 0,
  }) : super(key: key);

  @override
  _CalcButtonState createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _space = 15;
    return SizedBox(
      width: _width / 4 - _width / _space,
      height: _width / 4 - _width / _space,
      child: TextButton(
          style: ButtonStyle(
              padding: widget.isZero
                  ? MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.only(left: _width * 0.07))
                  : null,
              alignment:
                  widget.isZero ? Alignment.centerLeft : Alignment.center,
              backgroundColor: MaterialStateProperty.all<Color>(
                  widget.isPressed.elementAt(widget.index)
                      ? widget.textColor
                      : widget.backgroundColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                side: widget.isPressed.elementAt(widget.index)
                    ? BorderSide(width: 3.0, color: widget.backgroundColor)
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(_width * 0.1),
              ))),
          onPressed: widget.callback,
          child: Text(
            widget.text,
            style: TextStyle(
                color: widget.isPressed.elementAt(widget.index)
                    ? widget.backgroundColor
                    : widget.textColor,
                fontSize: _width * 0.09),
          )),
    );
  }
}
