part of data_management_utilities;

abstract class DataObservable<T> extends GetxController {
  /// This name will be printed in debug console along with each print.
  ///
  /// If no name is given, names are not printed.
  final String name;

  /// This function is called just after data generation is completed
  final PostInit? postInit;

  DataObservable({
    this.name = '',
    this.postInit,
    required T? Function(T?)? filter,
  }) : _singleDataFilter = filter;

  /// Generated data
  final Rxn<T> _data = Rxn<T>();

  /// Generated data
  T? get data => _processOutputData();

  bool get hasNoData => _data.value == null;

  String get _prefix => name.isEmpty ? '' : '$name: ';

  T? _processOutputData() {
    return _singleDataFilter != null
        ? _singleDataFilter!(_data.value)
        : _data.value;
  }

  final T? Function(T?)? _singleDataFilter;

  @protected
  void printInConsole(
    String message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logExceptRelease(
      '$runtimeType: $_prefix - $message',
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }

  String? tag;

  DataObservable<T> put({
    String? tag,
    bool permanent = false,
  }) {
    this.tag = tag;
    return Get.put<DataObservable<T>>(
      this,
      tag: tag,
      permanent: permanent,
    );
  }

  void delete({bool force = false}) {
    Get.delete<DataObservable<T>>(tag: tag, force: force);
  }
}

abstract class DataGenerateObservable<T> extends DataObservable<T> {
  /// The function that generates <T> data
  @protected
  Future<T?> generateData();

  final bool generateOnInit;

  DataGenerateObservable({
    super.name = '',
    super.postInit,
    required super.filter,
    this.timeout,
    required this.generateOnInit,
  });

  /// If and only if generate is in progress, value of this will be true
  final RxBool _isLoading = false.obs;

  ///If and only if generate is in progress, value of this will be true
  bool get isLoading => _isLoading.value;

  ///True until initial data generation is not completed
  final RxBool _initializing = true.obs;

  ///If and only if initializing, value of this will be true
  bool get initializing => _initializing.value;

  /// The current error. This will be empty if there is no error currently.
  final RxString _error = RxString('');

  /// The current error. This will be empty if there is no error currently.
  String get error => _error.value;

  /// If and only if there is some error, value of this will be true
  bool get isError => _error.isNotEmpty;

  /// Timeout Duration
  final Duration? timeout;

  Future<bool> generate() async {
    if (_isLoading.value) {
      printInConsole(
        'Cancelling generation because a generation is already in progress.',
      );
      return false;
    }

    _isLoading.value = true;
    printInConsole('Calling generate()');

    if (timeout != null) {
      try {
        _data.value = await generateData().timeout(timeout!);
      } on TimeoutException {
        _error.value = 'Timeout Error!';
        _isLoading.value = false;
        printInConsole('Timeout error during Data Generation');
        return false;
      } catch (e, s) {
        _error.value = e.runtimeType.toString();
        _isLoading.value = false;
        printInConsole(
          'Error during Data Generation - $e',
          error: e,
          stackTrace: s,
        );
        return false;
      }
    } else {
      try {
        _data.value = await generateData();
      } catch (e, s) {
        _error.value = e.runtimeType.toString();
        _isLoading.value = false;
        printInConsole(
          'Error during Data Generation - $e',
          error: e,
          stackTrace: s,
        );
        return false;
      }
    }

    printInConsole('Data generation complete');

    _isLoading.value = false;

    printInConsole('Loading values are set to false');

    return true;
  }

  @mustCallSuper
  @override
  Future<void> onInit() async {
    // called immediately after the widget is allocated memory
    super.onInit();
    if (generateOnInit) {
      await generate();
    }
  }

  @override
  Future<void> onReady() async {
    _initializing.value = false;
    await postInit?.call(this);
    super.onReady();
  }
}

abstract class DataGenerateObservableX<T, X> extends DataGenerateObservable<T> {
  final Rxn<X> _otherData = Rxn<X>();

  X? get otherData => _otherData.value;

  set otherData(X? otherData) {
    _otherData.value = otherData;
  }

  final void Function(DataGenerateObservableX<T, X>)? onOtheDataChanged;

  late final StreamSubscription<X?>? _otherDataStreamSubscription;

  @override
  T? _processOutputData() {
    return _doubleDataFilter != null
        ? _doubleDataFilter!(_data.value, _otherData.value)
        : _data.value;
  }

  final T? Function(T?, X?)? _doubleDataFilter;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription = _otherData.listen((x) {
        if (initialized) {
          onOtheDataChanged!(this);
        }
      });
    }
  }

  @override
  void onClose() {
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription?.cancel();
    }
    super.onClose();
  }

  DataGenerateObservableX({
    this.onOtheDataChanged,
    super.name = '',
    super.postInit,
    super.timeout,
    required T? Function(T?, X?)? filter,
    X? otherData,
    required super.generateOnInit,
  })  : _doubleDataFilter = filter,
        super(
          filter: (x) => x,
        ) {
    _otherData.value = otherData;
  }
}

abstract class DataFetchObservable<T> extends DataGenerateObservable<T> {
  Uri generateUrl();

  /// The function that converts http response body to `<T> data`
  final T Function(String resposeBody) responseBodyToData;

  DataFetchObservable({
    required this.responseBodyToData,
    super.name = '',
    super.postInit,
    super.timeout,
    required super.filter,
    required super.generateOnInit,
  });

  @override
  @protected
  Future<T?> generateData() async {
    final Uri url = generateUrl();
    printInConsole('Calling fetch(), url: ${url.toString()}');

    late final Response response;

    if (timeout != null) {
      try {
        response = await HTTP.get(url).timeout(timeout!);
      } on TimeoutException {
        _error.value = 'Timeout Error!';
        return null;
      } catch (e) {
        _error.value = e.runtimeType.toString();
        return null;
      }
    } else {
      try {
        response = await HTTP.get(url);
      } catch (e) {
        _error.value = e.runtimeType.toString();
        return null;
      }
    }

    if (response.body.isEmpty) {
      printInConsole('Got empty response');
      return null;
    }

    printInConsole('Got response');

    late final T result;

    try {
      result = responseBodyToData(response.body);
    } catch (e, s) {
      printInConsole(
        'Error while conversion response body to data - $e',
        error: e,
        stackTrace: s,
      );
      _error.value = e.runtimeType.toString();
      return null;
    }

    printInConsole('Response to data conversion complete');
    return result;
  }

  /// Function to fetch `<T> data` and override the existing data by new data
  ///
  /// Calling fetch will override the existing data with the newly fetched data
  ///
  /// `fetch` and `generate` are exactly the same
  // @Deprecated('Use generate() instead')
  Future<bool> fetch() async => generate();
}

abstract class DataFetchObservableX<T, X> extends DataFetchObservable<T> {
  final Rxn<X> _otherData = Rxn<X>();

  X? get otherData => _otherData.value;

  set otherData(X? otherData) {
    _otherData.value = otherData;
  }

  final void Function(DataFetchObservableX<T, X>)? onOtheDataChanged;

  late final StreamSubscription<X?>? _otherDataStreamSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription = _otherData.listen((x) {
        if (initialized) {
          onOtheDataChanged!(this);
        }
      });
    }
  }

  @override
  void onClose() {
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription?.cancel();
    }
    super.onClose();
  }

  @override
  T? _processOutputData() {
    return _doubleDataFilter != null
        ? _doubleDataFilter!(_data.value, _otherData.value)
        : _data.value;
  }

  final T? Function(T?, X?)? _doubleDataFilter;

  DataFetchObservableX({
    required super.responseBodyToData,
    this.onOtheDataChanged,
    super.name = '',
    super.postInit,
    super.timeout,
    required T? Function(T?, X?)? filter,
    X? otherData,
    required super.generateOnInit,
  })  : _doubleDataFilter = filter,
        super(
          filter: (x) => x,
        ) {
    _otherData.value = otherData;
  }
}

abstract class PartDataGenerateObservable<T> extends DataGenerateObservable<T> {
  /// This function is used to append the new data to the existing data
  ///
  ///   This function is called by `fetchAndAdd()` to append the new fetched data to the existing data
  ///
  ///   Parameters
  ///
  ///   * `<T> existingData`: The existing data
  ///
  ///   * `<T> newData`: The new data to be appended
  ///
  ///   Returns: `<T> data` that is `<T> existingData` + `<T> newData`
  final T? Function(T? existingData, T? newData) add;

  /// This function is used to check whether `<T> data` is empty
  ///
  ///   This function is called by `fetchAndAdd()` to check if the response is empty
  ///
  ///   Parameters
  ///
  ///   * `<T> data`: the data to be checked whether it is empty
  ///
  ///   Returns: bool (true if empty, false if not empty)
  final bool Function(T? data) isEmpty;

  PartDataGenerateObservable({
    required this.add,
    required this.isEmpty,
    super.name = '',
    super.postInit,
    super.timeout,
    required super.filter,
    required super.generateOnInit,
  });

  /// Current `offset` of fetching
  int _offset = 0;

  /// Current `offset` of fetching
  int get currentOffset => _offset;

  /// Defines the limit of fetching of `<T> data` from current `offset`
  int _limit = 20;

  /// Defines the limit of fetching of `<T> data` from current `offset`
  int get limit => _limit;

  /// Change the `limit` value
  ///
  /// Please note that the existing `<T> data` and the current `offset` will remain unaffected.
  ///
  /// If `reset` or `fetchAndAnd` is currently executing, this operation will not be performed
  set limit(int newLimit) {
    if (!_isLoading.value) {
      _limit = newLimit;
    }
  }

  /// This will be true if end is reached of the end of `<T> data`
  ///
  /// Please note that `endReached` is checked by receive of an empty reception in fetch operation
  bool _endReached = false;

  /// This will be true if end is reached of the end of `<T> data`
  ///
  /// Please note that `endReached` is checked by receive of an empty reception in fetch operation
  bool get endReached => _endReached;

  bool get loadingMore => !initializing && isLoading;

  @override
  @protected
  Future<bool> generate() async => reset();

  Future<bool> reset() async {
    if (_isLoading.value) {
      printInConsole(
        'Cancelling reset because another fetch operation is already in progress.',
      );
      return false;
    }

    _endReached = false;

    _data.value = null;
    _offset = 0;

    return fetchAndAdd();
  }

  /// A `fetch operation`
  ///
  /// Function to fetch new `<T> data` part from last `offset` till `offset + limit` and append to the existing `<T> data`
  Future<bool> fetchAndAdd() async {
    if (_isLoading.value) {
      printInConsole(
        'Cancelling fetchAndAdd because another fetch operation is already in progress.',
      );
      return false;
    }

    if (_endReached) {
      printInConsole('Cancelling fetchAndAdd because endReached');
      return false;
    }

    _isLoading.value = true;

    /*Uri url = urlGenerator(_offset, _limit);
    printInConsole('Calling fetch(), url: ${url.toString()}');

    Response response = await HTTP.get(url);

    /*if (response == null) {
      _printExceptRelease('Got null response');
      _isLoading.value = false;
      return false;
    }*/

    printInConsole('Got response');

    T newData = responseBodyToData(response.body);

    _data.value = add(_data.value, responseBodyToData(response.body));*/

    late final T? newData;

    if (timeout != null) {
      try {
        newData = await generateData().timeout(timeout!);
      } on TimeoutException {
        _error.value = 'Timeout Error!';
        _isLoading.value = false;
        printInConsole('Timeout error during Data Generation');
        return false;
      } catch (e, s) {
        _error.value = e.runtimeType.toString();
        _isLoading.value = false;
        printInConsole(
          'Error during Data Generation - $e',
          error: e,
          stackTrace: s,
        );
        return false;
      }
    } else {
      try {
        newData = await generateData();
      } catch (e, s) {
        _error.value = e.runtimeType.toString();
        _isLoading.value = false;
        printInConsole(
          'Error during Data Generation - $e',
          error: e,
          stackTrace: s,
        );
        return false;
      }
    }

    _data.value = add(_data.value, newData);

    if (isEmpty(newData)) {
      _endReached = true;
    } else {
      _offset += _limit;
    }

    printInConsole('Data generation complete');

    _isLoading.value = false;

    printInConsole('Loading values are set to false');

    return true;
  }
}

abstract class PartDataGenerateObservableX<T, X>
    extends PartDataGenerateObservable<T> {
  final Rxn<X> _otherData = Rxn<X>();

  X? get otherData => _otherData.value;

  set otherData(X? otherData) {
    _otherData.value = otherData;
  }

  final void Function(PartDataGenerateObservableX<T, X>)? onOtheDataChanged;

  late final StreamSubscription<X?>? _otherDataStreamSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription = _otherData.listen((x) {
        if (initialized) {
          onOtheDataChanged!(this);
        }
      });
    }
  }

  @override
  void onClose() {
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription?.cancel();
    }
    super.onClose();
  }

  @override
  T? _processOutputData() {
    return _doubleDataFilter != null
        ? _doubleDataFilter!(_data.value, _otherData.value)
        : _data.value;
  }

  final T? Function(T?, X?)? _doubleDataFilter;

  PartDataGenerateObservableX({
    required super.add,
    required super.isEmpty,
    this.onOtheDataChanged,
    super.name = '',
    super.postInit,
    super.timeout,
    required T? Function(T?, X?)? filter,
    X? otherData,
    required super.generateOnInit,
  })  : _doubleDataFilter = filter,
        super(
          filter: (x) => x,
        ) {
    _otherData.value = otherData;
  }
}

abstract class PartDataFetchObservable<T>
    extends PartDataGenerateObservable<T> {
  Uri generateUrl();

  /// The function that converts http response body to `<T> data`
  final T Function(String resposeBody) responseBodyToData;

  PartDataFetchObservable({
    required this.responseBodyToData,
    required super.add,
    required super.isEmpty,
    super.name = '',
    super.postInit,
    super.timeout,
    required super.filter,
    required super.generateOnInit,
  });

  @override
  @protected
  Future<T?> generateData() async {
    final Uri url = generateUrl();
    printInConsole('Calling fetch(), url: ${url.toString()}');

    late final Response response;

    if (timeout != null) {
      try {
        response = await HTTP.get(url).timeout(timeout!);
      } on TimeoutException {
        _error.value = 'Timeout Error!';
        return null;
      } catch (e) {
        _error.value = e.runtimeType.toString();
        return null;
      }
    } else {
      try {
        response = await HTTP.get(url);
      } catch (e) {
        _error.value = e.runtimeType.toString();
        return null;
      }
    }

    if (response.body.isEmpty) {
      printInConsole('Got empty response');
      return null;
    }

    printInConsole('Got response');

    late final T result;

    try {
      result = responseBodyToData(response.body);
    } catch (e, s) {
      printInConsole(
        'Error while conversion response body to data - $e',
        error: e,
        stackTrace: s,
      );
      _error.value = e.runtimeType.toString();
      return null;
    }

    printInConsole('Response to data conversion complete');
    return result;
  }
}

abstract class PartDataFetchObservableX<T, X>
    extends PartDataFetchObservable<T> {
  final Rxn<X> _otherData = Rxn<X>();

  X? get otherData => _otherData.value;

  set otherData(X? otherData) {
    _otherData.value = otherData;
  }

  final void Function(PartDataFetchObservableX<T, X>)? onOtheDataChanged;

  late final StreamSubscription<X?>? _otherDataStreamSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription = _otherData.listen((x) {
        if (initialized) {
          onOtheDataChanged!(this);
        }
      });
    }
  }

  @override
  void onClose() {
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription?.cancel();
    }
    super.onClose();
  }

  @override
  T? _processOutputData() {
    return _doubleDataFilter != null
        ? _doubleDataFilter!(_data.value, _otherData.value)
        : _data.value;
  }

  final T? Function(T?, X?)? _doubleDataFilter;

  PartDataFetchObservableX({
    required super.responseBodyToData,
    required super.add,
    required super.isEmpty,
    this.onOtheDataChanged,
    super.name = '',
    super.postInit,
    super.timeout,
    required T? Function(T?, X?)? filter,
    X? otherData,
    required super.generateOnInit,
  })  : _doubleDataFilter = filter,
        super(
          filter: (x) => x,
        ) {
    _otherData.value = otherData;
  }
}
