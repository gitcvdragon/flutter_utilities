part of data_management_utilities;

/*class SingleGenerateObservable<T> extends GetxController {
  /// This name will be printed in debug console along with each print.
  ///
  /// If no name is given, names are not printed.
  final String name;

  /// The function that generates <T> data
  final Future<T?> Function(T? data) dataGenerator;

  /// This function
  final VoidCallback? postInit;

  /// Timeout Duration
  final Duration? timeout;

  /// REQUIRED PARAMETERS: [dataGenerator]
  ///
  /// BE SURE TO PASS THE TYPE FOR BETTER DEVELOPMENT EXPERIENCE
  ///
  /// Other parameters: String `name`, Function `postInit`
  ///
  ///   * String `name`: This name will be printed in debug console along with each print.
  ///   If no name is given, names are not printed.
  ///
  ///   * Function? `postInit`: This Function will be immediately called after the fetch during initialization
  ///
  ///   * Duration? `timeout`: This is the timeout duration of `fetch` or `generate`
  ///
  /// Please note that the data will be converted to Rx type
  SingleGenerateObservable({
    required this.dataGenerator,
    this.name = '',
    this.postInit,
    this.timeout,
  });

  @mustCallSuper
  @override
  void onInit() async {
    // called immediately after the widget is allocated memory
    await generate();
    super.onInit();
    if (postInit != null) {
      postInit!();
    }
    _initializing.value = false;
  }

  /// Generated data
  final Rxn<T> _data = Rxn<T>(null);

  /// Generated data
  T? get data => _data.value;

  /// If and only if generate is in progress, value of this will be true
  final RxBool _isLoading = false.obs;

  ///If and only if generate is in progress, value of this will be true
  bool get isLoading => _isLoading.value;

  ///If and only if initializing, value of this will be true
  final RxBool _initializing = true.obs;

  ///If and only if initializing, value of this will be true
  bool get initializing => _initializing.value;

  /// The current error. This will be empty if there is no error currently.
  final RxString _error = RxString('');

  /// The current error. This will be empty if there is no error currently.
  String get error => _error.value;

  /// If and only if there is some error, value of this will be true
  bool get isError => _error.isNotEmpty;

  /// Function to perform data fetch
  ///
  /// Calling fetch will override the existing data with the newly fetched data
  Future<bool> generate() async {
    if (_isLoading.value) {
      _printExceptRelease(
          'Cancelling generation because a generation is already in progress.');
      return false;
    }

    _isLoading.value = true;
    _printExceptRelease('Calling generate()');

    if (timeout != null) {
      _data.value =
          await dataGenerator(_data.value).timeout(timeout!, onTimeout: () {
        _error.value = 'Timeout!';
      });
    } else {
      _data.value = await dataGenerator(_data.value);
    }

    _printExceptRelease('Data generation complete');

    _isLoading.value = false;

    _printExceptRelease('Loading values are set to false');

    return true;
  }

  String get _prefix => name.isEmpty ? '' : '$name: ';
  void _printExceptRelease(String message) {
    printExceptRelease('${this.runtimeType}: $_prefix - $message');
  }
}*/

class SingleGenerateObservable<T> extends DataGenerateObservable<T> {
  /// The function that generates <T> data
  @protected
  final Future<T?> Function(T? data) dataGenerator;

  /// REQUIRED PARAMETERS: [dataGenerator]
  ///
  /// BE SURE TO PASS THE TYPE FOR BETTER DEVELOPMENT EXPERIENCE
  ///
  /// Other parameters: String `name`, Function `postInit`
  ///
  ///   * String `name`: This name will be printed in debug console along with each print.
  ///   If no name is given, names are not printed.
  ///
  ///   * Function? `postInit`: This Function will be immediately called after the fetch during initialization
  ///
  ///   * Duration? `timeout`: This is the timeout duration of `fetch` or `generate`
  ///
  /// Please note that the data will be converted to Rx type
  SingleGenerateObservable({
    required this.dataGenerator,
    super.name = '',
    super.postInit,
    super.timeout,
    super.filter,
    super.generateOnInit = true,
  });

  @protected
  @override
  Future<T?> generateData() async => dataGenerator(_data.value);
}

class SingleGenerateObservableX<T, X> extends DataGenerateObservableX<T, X> {
  /// The function that generates <T> data
  @protected
  final Future<T?> Function(T? data, X? otherData) dataGenerator;

  SingleGenerateObservableX({
    required this.dataGenerator,
    super.name = '',
    super.postInit,
    super.timeout,
    super.onOtheDataChanged,
    super.otherData,
    super.filter,
    super.generateOnInit = true,
  });

  @protected
  @override
  Future<T?> generateData() async =>
      dataGenerator(_data.value, _otherData.value);
}

/*
class SingleGenerateObservableX<T, X> extends GetxController {
  /// This name will be printed in debug console along with each print.
  ///
  /// If no name is given, names are not printed.
  final String name;

  /// The function that generates <T> data
  final Future<T?> Function(T? data, X? otherData) dataGenerator;

  /// This function
  final VoidCallback? postInit;

  /// Timeout Duration
  final Duration? timeout;

  SingleGenerateObservableX({
    required this.dataGenerator,
    this.postInit,
    this.onOtheDataChanged,
    this.name = '',
    this.timeout,
    X? otherData,
  }) {
    _otherData.value = otherData;
  }

  @mustCallSuper
  @override
  void onInit() async {
    // called immediately after the widget is allocated memory
    await generate();
    super.onInit();
    if (postInit != null) {
      postInit!();
    }
    _initializing.value = false;
    if (onOtheDataChanged != null) {
      _otherDataStreamSubscription = _otherData.listen((x) {
        onOtheDataChanged!(_data.value, _otherData.value);
      });
    }
  }

  /// Generated data
  final Rxn<T> _data = Rxn<T>(null);

  /// Generated data
  T? get data => _data.value;

  /// If and only if generate is in progress, value of this will be true
  final RxBool _isLoading = false.obs;

  ///If and only if generate is in progress, value of this will be true
  bool get isLoading => _isLoading.value;

  ///If and only if initializing, value of this will be true
  final RxBool _initializing = true.obs;

  ///If and only if initializing, value of this will be true
  bool get initializing => _initializing.value;

  /// The current error. This will be empty if there is no error currently.
  final RxString _error = RxString('');

  /// The current error. This will be empty if there is no error currently.
  String get error => _error.value;

  /// If and only if there is some error, value of this will be true
  bool get isError => _error.isNotEmpty;

  /// Function to perform data fetch
  ///
  /// Calling fetch will override the existing data with the newly fetched data
  Future<bool> generate() async {
    if (_isLoading.value) {
      _printExceptRelease(
          'Cancelling generation because a generation is already in progress.');
      return false;
    }

    _isLoading.value = true;
    _printExceptRelease('Calling generate()');

    if (timeout != null) {
      _data.value = await dataGenerator(_data.value, _otherData.value)
          .timeout(timeout!, onTimeout: () {
        _error.value = 'Timeout!';
      });
    } else {
      _data.value = await dataGenerator(_data.value, _otherData.value);
    }

    _printExceptRelease('Data generation complete');

    _isLoading.value = false;

    _printExceptRelease('Loading values are set to false');

    return true;
  }

  String get _prefix => name.isEmpty ? '' : '$name: ';
  void _printExceptRelease(String message) {
    printExceptRelease('${this.runtimeType}: $_prefix - $message');
  }

  final Rxn<X> _otherData = Rxn<X>(null);

  X? get otherData => _otherData.value;

  set otherData(X? otherData) {
    _otherData.value = otherData;
  }

  final void Function(T? data, X? otherData)? onOtheDataChanged;

  late final StreamSubscription<X?>? _otherDataStreamSubscription;

  @override
  void onClose() {
    _otherDataStreamSubscription?.cancel();
    super.onClose();
  }
}*/
