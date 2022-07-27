import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_utilities/flutter_utilities.dart';

class CurveClipper extends CustomClipper<Path> {
  final double height;
  final double curveHeight;

  CurveClipper({
    required this.height,
    required this.curveHeight,
  });

  @override
  Path getClip(Size sizeR) {
    final Size size = Size(sizeR.width, height);
    final Offset controlPoint =
        Offset(size.width / 2, size.height + curveHeight);
    final Offset endPoint = Offset(size.width, size.height - curveHeight);

    final Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

typedef AsyncVoidCallback = FutureOr<void> Function();

class FireOnCalm {
  Duration? _timeToCalmDown;
  AsyncVoidCallback? _callback;

  void initializeFireOnCalm({
    required Duration calmDownTime,
    required VoidCallback callbackOnCalm,
  }) {
    _timeToCalmDown = calmDownTime;
    _callback = callbackOnCalm;
  }

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  void notCalm() {
    if ((_timeToCalmDown == null) || (_callback == null)) {
      logExceptRelease(
        "FireOnCalm must be initialized before use by calling initializeFireOnCalm()",
        error:
            "FireOnCalm must be initialized before use by calling initializeFireOnCalm()",
      );
      return;
    }
    _stopwatch.start();
    _stopwatch.reset();
    _timer?.cancel();
    _timer = Timer(
      _timeToCalmDown!,
      () async {
        if (_stopwatch.elapsed >= _timeToCalmDown!) {
          await _callback!.call();
          _stopwatch.stop();
          _stopwatch.reset();
        }
      },
    );
  }
}
