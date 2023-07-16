library utility_functions;

// Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

// Flutter imports:
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utilities/src/extensions.dart';

// Project imports:
import 'package:flutter_utilities/src/utility_widgets.dart';

/// Print only it is debug mode
void printExceptRelease(Object? message, {int? wrapWidth}) {
  if (kDebugMode) {
    debugPrint('$message', wrapWidth: wrapWidth);
  }
}

void logExceptRelease(
  Object? message, {
  DateTime? time,
  int? sequenceNumber,
  int level = 0,
  String name = '',
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    log(
      '$message',
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<bool> showConfirmationDialog(
  BuildContext context, {
  String text = 'Are you sure?',
  Widget? child,
  List<Widget>? actions,
  MainAxisAlignment actionsAlignment = MainAxisAlignment.end,
  EdgeInsetsGeometry padding = const EdgeInsets.all(30),
}) async =>
    (await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        text: text,
        child: child,
        actions: actions,
        actionsAlignment: actionsAlignment,
        padding: padding,
      ),
    )) ??
    false;

Future<bool> showAndroidConfirmationDialog({
  required  BuildContext context,
   String title = 'Are you sure?',
  String? subtitle,
  bool dismissable = true,
}) async =>
    (await showDialog<bool>(
      barrierDismissible: dismissable,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: subtitle == null ? null : Text(subtitle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ??
    false;

/*bool envCondition({required final bool release, bool? debug, bool? profile}) {
  if (kReleaseMode) {
    return release;
  } else if (kDebugMode) {
    return debug ?? release;
  } else if (kProfileMode) {
    return profile ?? debug ?? release;
  }
  return false;
}*/

T buildModeConditional<T>({required T release, T? debug, T? profile}) {
  if (kReleaseMode) {
    return release;
  } else if (kDebugMode) {
    return debug ?? release;
  } else if (kProfileMode) {
    return profile ?? debug ?? release;
  }
  return release;
}

/// Used for Hero animation of text widgets
Widget heroFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  return DefaultTextStyle(
    style: DefaultTextStyle.of(toHeroContext).style,
    child: toHeroContext.widget,
  );
}

Widget _defaultTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    FadeScaleTransition(
      animation: animation,
      child: child,
    );

Future<T?> showDialogWithHero<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )
      transitionBuilder = _defaultTransitionBuilder,
}) async {
  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) =>
          transitionBuilder(
        context,
        animation,
        secondaryAnimation,
        builder(
          context,
        ),
      ),
    ),
  );
}

Color randomColor() =>
    Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

abstract class TextFieldValidators {
  const TextFieldValidators._();

  static String? mustNotBeEmptyValidator(
    String value, {
    String emptyMessage = "This field must not be empty",
  }) =>
      value.isEmpty ? emptyMessage : null;

  static String? multipleValidators(
    String str, {
    required List<String? Function(String)> validators,
  }) {
    for (final x in validators) {
      final String? res = x(str);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  static String? emailValidator(
    String str, {
    bool canBeEmpty = false,
    String errorMessage = "Please enter a valid email address",
  }) {
    if (canBeEmpty && str.isEmpty) {
      return null;
    }
    return str.isEmail ? null : errorMessage;
  }

  static String? phoneNumberValidator(
    String str, {
    bool canBeEmpty = false,
    int? length,
    String errorMessage = "Please enter a valid phone number",
  }) {
    if (canBeEmpty && str.isEmpty) {
      return null;
    }
    if ((length != null) && (str.length != length)) {
      return errorMessage;
    }
    return str.isPhoneNumber ? null : errorMessage;
  }

  static String? numericOnlyValidator(
    String str, {
    bool canBeEmpty = false,
    String errorMessage = "Please enter a numeric value",
  }) {
    if (canBeEmpty && str.isEmpty) {
      return null;
    }
    return str.isNumeric ? null : errorMessage;
  }
}
