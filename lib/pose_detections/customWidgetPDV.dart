import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void showCustomDialog(BuildContext context, Widget content) {
  void cancelfunc() {
    Navigator.pop(context);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Execution analysis'),
        content: Container(
          width: 300.0, // Set your desired width
          height: 200.0, // Set your desired height
          child: Column(
            children: [
              content,
              Transform.translate(
                offset: Offset(0.0, -20.0), // Adjust the y-value to move it up
                child: Row(
                  children: [
                    buildElevatedButton("Cancel", Colors.red, cancelfunc),
                    buildElevatedButton("Submit", Colors.red, cancelfunc),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget textInfoCtr(
    String label, double? counted, double fontsize, Color color) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 5.0,
      top: 5.0,
    ),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontsize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (counted != null)
          Text(
            counted.toString(),
            style: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.bold,
              // color: Color.fromARGB(255, 0, 0, 0),

              color: color,
              decoration: TextDecoration.none,
            ),
          ),
      ],
    ),
  );
}

Widget instructionText(FontWeight fontw, double fontsize, double leftN,
    double topN, Color color, String text) {
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: leftN, top: topN, right: 20),
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            text: text,
            style: GoogleFonts.lato(
              fontSize: fontsize,
              color: color,
              fontWeight: fontw,
            ),
          ),
        ),
      ));
}

Widget buildElevatedButton(String label, Color color, Function func) {
  return Padding(
    padding: EdgeInsets.only(left: 5.0, right: 5.0),
    child: Align(
      alignment: Alignment(1.0, 0.8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () {
          func();

          // if (func is Function) {
          //   func();
          // } else {
          //   func;
          // }

          // _showConfirmationDialog();

          // translateCollectedDatatoTxt(coordinatesData);
          print('pressing button');
        },
        child: Text(label),
      ),
    ),
  );
}

Widget nextPageButton(String label, Color color,
    void Function(BuildContext) onPressed, BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(left: 5.0, right: 5.0),
    child: Align(
      alignment: Alignment(1.0, 0.8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () {
          onPressed(context); // Pass the context if needed
          print('pressing button');
        },
        child: Text(label),
      ),
    ),
  );
}

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CountdownTimer(),
//     );
//   }
// }

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _seconds;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _seconds = 10; // Set the initial duration in seconds
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: CountdownPainter(_seconds),
              ),
            ),
            Text(
              '$_seconds',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_seconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class CountdownPainter extends CustomPainter {
  final int seconds;

  CountdownPainter(this.seconds);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    canvas.drawCircle(center, radius, paint);

    double sweepAngle = 2 * pi * (seconds / 60);
    double startAngle = -pi / 2; // Start the countdown from the top

    paint.color = Colors.red;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        -sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
