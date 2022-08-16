import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart';

import 'helpers/clock_model.dart';
import 'helpers/spinner_text.dart';
import 'package:timezone/standalone.dart' as tz;

class DigitalClock extends StatefulWidget {
  DigitalClock(
      {this.is24HourTimeFormat,
      this.showSecondsDigit,
      this.areaWidth,
      this.areaHeight,
      this.areaDecoration,
      this.areaAligment,
      this.hourMinuteDigitDecoration,
      this.secondDigitDecoration,
      this.digitAnimationStyle,
      this.hourMinuteDigitTextStyle,
      this.secondDigitTextStyle,
      this.amPmDigitTextStyle,
      required this.timeLocation});

  final bool? is24HourTimeFormat;
  final bool? showSecondsDigit;
  final double? areaWidth;
  final double? areaHeight;
  final BoxDecoration? areaDecoration;
  final AlignmentDirectional? areaAligment;
  final BoxDecoration? hourMinuteDigitDecoration;
  final BoxDecoration? secondDigitDecoration;
  final Curve? digitAnimationStyle;
  final TextStyle? hourMinuteDigitTextStyle;
  final TextStyle? secondDigitTextStyle;
  final TextStyle? amPmDigitTextStyle;
  final Location timeLocation;
  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late DateTime _dateTime;
  late ClockModel _clockModel;
  late Timer _timer;
  int offset = 0;
  @override
  void initState() {
    super.initState();
    _dateTime = tz.TZDateTime.from(DateTime.now(), widget.timeLocation);

    _clockModel = ClockModel();
    _clockModel.is24HourFormat = widget.is24HourTimeFormat ?? true;

    _dateTime = tz.TZDateTime.from(DateTime.now(), widget.timeLocation);
    _clockModel.hour = _dateTime.hour;
    _clockModel.minute = _dateTime.minute;
    _clockModel.second = _dateTime.second;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _dateTime = tz.TZDateTime.from(DateTime.now(), widget.timeLocation);
      _clockModel.hour = _dateTime.hour;
      _clockModel.minute = _dateTime.minute;
      _clockModel.second = _dateTime.second;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.areaWidth ??
          (widget.hourMinuteDigitTextStyle != null
              ? widget.hourMinuteDigitTextStyle!.fontSize! * 7
              : 180),
      height: widget.areaHeight ?? null,
      child: Container(
        alignment: widget.areaAligment ?? AlignmentDirectional.bottomCenter,
        decoration: widget.areaDecoration ??
            BoxDecoration(
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(20),
              color: Color.fromARGB(255, 3, 12, 84),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _hour(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SpinnerText(
                text: ":",
                textStyle: widget.hourMinuteDigitTextStyle ?? null,
              ),
            ),
            _minute,
            _second,
            _amPm,
          ],
        ),
      ),
    );
  }

  Widget _hour() => Container(
        decoration: widget.hourMinuteDigitDecoration ??
            BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5)),
        child: SpinnerText(
          text: _clockModel.is24HourTimeFormat
              ? hTOhh_24hTrue(_clockModel.hour)
              : hTOhh_24hFalse(_clockModel.hour)[0],
          animationStyle: widget.digitAnimationStyle ?? null,
          textStyle: widget.hourMinuteDigitTextStyle ?? null,
        ),
      );

  Widget get _minute => Container(
        decoration: widget.hourMinuteDigitDecoration ??
            BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5)),
        child: SpinnerText(
          text: mTOmm(_clockModel.minute),
          animationStyle: widget.digitAnimationStyle ?? null,
          textStyle: widget.hourMinuteDigitTextStyle ?? null,
        ),
      );

  Widget get _second => widget.showSecondsDigit != false
      ? Container(
          margin: EdgeInsets.only(bottom: 0, left: 4, right: 2),
          decoration: widget.secondDigitDecoration ??
              BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)),
          child: SpinnerText(
            text: sTOss(_clockModel.second),
            animationStyle: widget.digitAnimationStyle,
            textStyle: widget.secondDigitTextStyle ??
                TextStyle(
                    fontSize: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle!.fontSize! / 2
                        : 15,
                    color: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle!.color!
                        : Colors.white),
          ),
        )
      : Text("");

  Widget get _amPm => _clockModel.is24HourTimeFormat
      ? Text("")
      : Container(
          padding: EdgeInsets.symmetric(horizontal: 2),
          margin: EdgeInsets.only(
              bottom: widget.hourMinuteDigitTextStyle != null
                  ? widget.hourMinuteDigitTextStyle!.fontSize! / 2
                  : 15),
          child: Text(
            " " + hTOhh_24hFalse(_clockModel.hour)[1],
            style: widget.amPmDigitTextStyle ??
                TextStyle(
                    fontSize: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle!.fontSize! / 2
                        : 15,
                    color: widget.hourMinuteDigitTextStyle != null
                        ? widget.hourMinuteDigitTextStyle!.color!
                        : Colors.white),
          ),
        );
}
