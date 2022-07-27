// Dart imports:
import 'dart:async';

// Project imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter_utilities/src/utility_functions.dart';

class PeriodicExecutor {
  final VoidCallback? functionToExecute;
  final Duration delayBetweenExecution;

  PeriodicExecutor({
    this.functionToExecute,
    this.delayBetweenExecution = const Duration(seconds: 5),
  });

  Timer? _periodicExecuteTimer;
  void startPeriodicExecution() {
    if (functionToExecute == null) {
      return;
    }
    _printExceptRelease('Starting periodicExecution');
    if (_periodicExecuteTimer == null || !_periodicExecuteTimer!.isActive) {
      functionToExecute!(); // Execute here once because otherwise it will be executed after the delay only
      _periodicExecuteTimer = Timer.periodic(delayBetweenExecution, (t) {
        functionToExecute!();
      });
    }
  }

  void stopPeriodicExecution() {
    _printExceptRelease('Cancelling periodicExecution');
    _periodicExecuteTimer?.cancel();
  }
}

void _printExceptRelease(String message) {
  printExceptRelease('InteractionObserver: $message');
}
