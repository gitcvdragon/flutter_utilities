library data_management_utilities;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart' hide Response;

// Project imports:
import 'package:flutter_utilities/src/network_utilities.dart';
import 'package:flutter_utilities/src/utility_functions.dart';

//import 'package:flutter_utilities/src/parts/data_observable.dart';

part 'package:flutter_utilities/src/parts/serial_fetch_observable.dart';
part 'package:flutter_utilities/src/parts/serial_generate_observable.dart';
part 'package:flutter_utilities/src/parts/single_generate_observable.dart';
part 'package:flutter_utilities/src/parts/single_fetch_observable.dart';
part 'package:flutter_utilities/src/parts/data_observable.dart';

typedef PostInit<T> = FutureOr<void> Function(DataObservable<T>);
