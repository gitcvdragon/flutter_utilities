library interaction_observer;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:flutter_utilities/flutter_utilities.dart';

class InteractionObserver extends StatefulWidget {
  /// If this is true, the widget will be marked as has interaction after initialization
  final bool setAsActiveOnInitialize;

  /// This function will be called when user starts interacting with the child widget
  final VoidCallback? onInteractionStart;

  /// This function will be called after the [durationBeforeInactivity] after the user stops interacting with the child widget
  final VoidCallback? onInteractionEnd;

  /// When user interaction stops, the [onInteractionEnd] will be called after this duration
  final Duration durationBeforeInactivity;

  /// This function will be called periodically with [periodicExecutionDuringActivityDelay] intervals while the user is interacting with the app
  final VoidCallback? periodicExecutionDuringActivity;

  /// The delay between two executions of [periodicExecutionDuringActivity]
  final Duration periodicExecutionDuringActivityDelay;

  /// This function will be called periodically with [periodicExecutionDuringInactivityDelay] intervals while the user is not interacting with the app
  final VoidCallback? periodicExecutionDuringInactivity;

  /// The delay between two executions of [periodicExecutionDuringInactivity]
  final Duration periodicExecutionDuringInactivityDelay;

  /// The widget to observe user interaction on
  final Widget? child;

  /// This widget can be used to observe user interaction on a widget
  ///
  /// To observe user interaction on an widget, wrap your widget with this widget on top
  ///
  /// Parameters
  /// * [setAsActiveOnInitialize]: If this is true, the widget will be marked as has interaction from the beginning
  /// * [onInteractionStart]: This function will be called when user starts interacting with the child widget
  /// * [onInteractionEnd]: This function will be called after the [durationBeforeInactivity] after the user stops interacting with the child widget
  /// * [durationBeforeInactivity]: When user interaction stops, the [onInteractionEnd] will be called after this duration
  /// * [periodicExecutionDuringActivity]: This function will be called periodically with [periodicExecutionDuringActivityDelay] intervals while the user is interacting with the app
  /// * [periodicExecutionDuringActivityDelay]: The delay between two executions of [periodicExecutionDuringActivity]
  /// * [periodicExecutionDuringInactivity]: This function will be called periodically with [periodicExecutionDuringInactivityDelay] intervals while the user is not interacting with the app
  /// * [periodicExecutionDuringInactivityDelay]: The delay between two executions of [periodicExecutionDuringInactivity]
  /// * [child]: The widget to observe user interaction on
  const InteractionObserver({
    Key? key,
    this.child,
    this.setAsActiveOnInitialize = true,
    this.onInteractionStart,
    this.onInteractionEnd,
    this.durationBeforeInactivity = const Duration(minutes: 1),
    this.periodicExecutionDuringActivity,
    this.periodicExecutionDuringActivityDelay = const Duration(seconds: 5),
    this.periodicExecutionDuringInactivity,
    this.periodicExecutionDuringInactivityDelay = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  _InteractionObserverState createState() => _InteractionObserverState();
}

class _InteractionObserverState extends State<InteractionObserver> {
  late final _InteractionWatcher interactionWatcher;

  @override
  void initState() {
    super.initState();
    interactionWatcher = _InteractionWatcher(
      setAsActiveOnInitialize: widget.setAsActiveOnInitialize,
      onInteractionStart: widget.onInteractionStart,
      onInteractionEnd: widget.onInteractionEnd,
      durationBeforeInactivity: widget.durationBeforeInactivity,
      periodicExecutionDuringActivity: widget.periodicExecutionDuringActivity,
      periodicExecutionDuringActivityDelay:
          widget.periodicExecutionDuringActivityDelay,
      periodicExecutionDuringInactivity:
          widget.periodicExecutionDuringInactivity,
      periodicExecutionDuringInactivityDelay:
          widget.periodicExecutionDuringInactivityDelay,
    );
  }

  @override
  void dispose() {
    interactionWatcher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (pde) {
        _printExceptRelease('onPointerDown situation.');
        interactionWatcher.couldNoticeActivity();
      },
      /*onPointerDown: (pde) {
        _printExceptRelease('onPointerDown situation.');
        //interactionWatcher.couldNoticeActivity();
      },
      onPointerHover: (phe) {
        _printExceptRelease('onPointerHover situation.');
        //interactionWatcher.couldNoticeActivity();
      },
      onPointerSignal: (ops) {
        _printExceptRelease('onPointerSignal situation.');
        //interactionWatcher.couldNoticeActivity();
      },
      onPointerMove: (opm) {
        _printExceptRelease('onPointerMove situation.');
        //interactionWatcher.couldNoticeActivity();
      },
      onPointerCancel: (opc) {
        _printExceptRelease('onPointerCancel situation.');
        //interactionWatcher.couldNoticeActivity();
      },
      onPointerUp: (opu) {
        _printExceptRelease('onPointerUp situation.');
        //interactionWatcher.couldNoticeActivity();
      },*/
      child: widget.child,
    );
  }
}

class _InteractionWatcher {
  bool _hasActivity = false;
  bool get hasActivity => _hasActivity;

  final bool setAsActiveOnInitialize;
  final Duration durationBeforeInactivity;
  final VoidCallback? onInteractionStart;
  final VoidCallback? onInteractionEnd;
  final VoidCallback? periodicExecutionDuringActivity;
  final Duration periodicExecutionDuringActivityDelay;
  final VoidCallback? periodicExecutionDuringInactivity;
  final Duration periodicExecutionDuringInactivityDelay;

  _InteractionWatcher({
    this.setAsActiveOnInitialize = true,
    this.onInteractionStart,
    this.onInteractionEnd,
    this.durationBeforeInactivity = const Duration(seconds: 30),
    this.periodicExecutionDuringActivity,
    this.periodicExecutionDuringActivityDelay = const Duration(seconds: 5),
    this.periodicExecutionDuringInactivity,
    this.periodicExecutionDuringInactivityDelay = const Duration(seconds: 5),
  }) {
    if (setAsActiveOnInitialize) {
      couldNoticeActivity();
      // _onActivity() is called by couldNoticeActivity()
    } else {
      _onInactivity();
    }
  }

  void dispose() {
    _printExceptRelease('Disposing');
    _interactionTimeout!.cancel();
    _periodicExecutorDuringActivity.stopPeriodicExecution();
    _periodicExecutorDuringInactivity.stopPeriodicExecution();
  }

  void couldNoticeActivity() {
    //! Activity situation
    _onActivity();
    _watchForActivity();
  }

  Timer? _interactionTimeout;
  void _watchForActivity() {
    _printExceptRelease(
      'Watching for user activity for next $durationBeforeInactivity',
    );

    _interactionTimeout?.cancel();
    _interactionTimeout = Timer(
      durationBeforeInactivity,
      () {
        //! Inactivity situation
        _onInactivity();
      },
    );
  }

  void _onActivity() {
    _printExceptRelease('User activity could be detected');
    _printExceptRelease('Setting hasActivity to true');
    _hasActivity = true;
    onInteractionStart?.call();
    _periodicExecutorDuringInactivity.stopPeriodicExecution();
    _periodicExecutorDuringActivity.startPeriodicExecution();
  }

  void _onInactivity() {
    _printExceptRelease('User is inactive');
    _printExceptRelease('Setting hasActivity to false');
    _hasActivity = false;
    onInteractionEnd?.call();
    _periodicExecutorDuringActivity.stopPeriodicExecution();
    _periodicExecutorDuringInactivity.startPeriodicExecution();
  }

  late final PeriodicExecutor _periodicExecutorDuringActivity =
      PeriodicExecutor(
    functionToExecute: periodicExecutionDuringActivity,
    delayBetweenExecution: periodicExecutionDuringActivityDelay,
  );
  late final PeriodicExecutor _periodicExecutorDuringInactivity =
      PeriodicExecutor(
    functionToExecute: periodicExecutionDuringInactivity,
    delayBetweenExecution: periodicExecutionDuringInactivityDelay,
  );
}

void _printExceptRelease(String message) {
  printExceptRelease('InteractionObserver: $message');
}
