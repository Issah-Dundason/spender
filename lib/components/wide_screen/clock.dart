import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class Clock extends StatelessWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: AspectRatio(aspectRatio: 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration:  BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 12, color: Colors.grey.shade300),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration:  BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 12, color: Colors.grey.shade300),
              ),
            ),
            // const CircleAvatar(radius: 12,),
            const _ClockFace(),
            const _ClockHands(),

          ],
        ),
      ),
    );
  }
}

class _ClockFace extends StatelessWidget {
  const _ClockFace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: _ClockNumberPainter(),
          ),
        )
      ],
    );
  }
}

class _ClockNumberPainter extends CustomPainter {

  final hourTickLength = 15.0;
  final minuteTickLength = 9.0;

  final hourTickWidth = 3.0;
  final minuteTickWidth = 1.5;

  late Paint tickPaint;

  _ClockNumberPainter() {
    tickPaint = Paint()..color = Colors.blueGrey..strokeWidth = 10;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const angle = 2 * math.pi / 60;
    final radius = size.width / 2;

    canvas.save();


    canvas.translate(radius, radius);
    canvas.rotate(1.5 * math.pi);

    for(var i = 0; i < 60; i++) {
      var markLength = i % 5 == 0 ? hourTickLength: minuteTickLength;
      tickPaint.strokeWidth = i % 5 == 0 ? hourTickWidth : minuteTickWidth;

      canvas.drawLine(Offset(-radius + 20, 0), Offset(-radius + 20 + markLength, 0), tickPaint);
      canvas.rotate(angle);
    }

    canvas.restore();

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ClockHands extends StatefulWidget {
  const _ClockHands({Key? key}) : super(key: key);

  @override
  State<_ClockHands> createState() => _ClockHandsState();
}

class _ClockHandsState extends State<_ClockHands> {
  late Timer _timer;
  late DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _setTime);
  }

  void _setTime(Timer timer) {
    setState(() {
      dateTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(painter: ClockHandPainter(hours: dateTime.hour, minutes: dateTime.minute),),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}


class ClockHandPainter extends CustomPainter {
  late Paint handPainter;
  late Paint minutePainter;
  int hours;
  int minutes;


  ClockHandPainter({required this.hours, required this.minutes}) {
    handPainter = Paint()..color = Colors.redAccent;
    minutePainter = Paint()..color = Colors.lightBlue;
    handPainter.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(1.5 * math.pi);

    canvas.save();

    int hr = hours % 12;

    var hourAngle = hr * (math.pi / 6);
    var totalHrAngle = hourAngle + (minutes / 60)  * (math.pi / 6);

    canvas.rotate(totalHrAngle);

    Path path =  Path();

    var bubbleBtm = radius * 0.042;

    path.moveTo(bubbleBtm, - bubbleBtm);

    path.quadraticBezierTo(0, 0, bubbleBtm, bubbleBtm);

    path.lineTo(radius * 0.7, 0);

    path.close();

    canvas.drawPath(path, handPainter);

    canvas.restore();

    canvas.save();

    var minuteAngle = (2 * math.pi / 60) * minutes;
    canvas.rotate(minuteAngle);

    path =  Path();

    bubbleBtm = radius * 0.042;

    path.moveTo(bubbleBtm, - bubbleBtm);

    path.quadraticBezierTo(0, 0, bubbleBtm, bubbleBtm);

    path.lineTo(radius * 0.4, 0);

    path.close();

    canvas.drawPath(path, minutePainter);

    canvas.restore();


    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}