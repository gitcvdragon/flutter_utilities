part of data_management_utilities;

/*class SerialGenerateObservable<T> extends GetxController {
  
  /// The function that takes the offset and the limit and returns the Uri for fetching data
  ///
  /// Parameters
  ///
  ///   * int `offset`: The starting offset of data to fetch from
  ///
  ///   * int `limit`: The limit of data to be fetched from starting offset
  ///
  /// Returns: Uri `url` for the `<T> data` fetch operation
  final Uri Function(int offset, int limit) urlGenerator;

  /// This name will be printed in debug console along with each print.
  ///
  /// If no name is given, names are not printed.
  final String name;

  /// The function that converts http response body to `<T> data`
  ///
  ///   Parameters
  ///
  ///   * String `responseBody`: The response body
  ///
  /// Returns: `<T> data`
  final T Function(String responseBody) responseBodyToData;

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
  final T Function(T? existingData, T newData) add;

  /// This function is used to check whether `<T> data` is empty
  ///
  ///   This function is called by `fetchAndAdd()` to check if the response is empty
  ///
  ///   Parameters
  ///
  ///   * `<T> data`: the data to be checked whether it is empty
  ///
  ///   Returns: bool (true if empty, false if not empty)
  final bool Function(T data) isEmpty;

  /// This Function will be immediately called after the fetch during initialization
  final void Function()? postInit;

  /// Used for listening to data of which can be fetched by parts.
  /// The parts are determined by `limit` and `offset`.
  ///
  /// REQUIRED PARAMETERS: Function `urlGenerator`, Function `responseBodyToData`, Function `add`
  ///
  /// * Uri Function(int `offset`, int `limit`) urlGenerator: The function that takes the offset and the limit and returns the Uri for fetching data
  ///
  ///   Parameters
  ///
  ///   * int `offset`: The starting offset of data to fetch from
  ///
  ///   * int `limit`: The limit of data to be fetched from starting offset
  ///
  ///   Returns: Uri `url` for the `<T> data` fetch operation
  ///
  ///
  /// * T Function(String `responseBody`) responseBodyToData: The function that converts http response body to `<T> data`
  ///
  ///   Parameters
  ///
  ///   * String `responseBody`: The response body
  ///
  ///   Returns: `<T> data`
  ///
  ///
  /// * T Function(T `existingData`, T `newData`) add: This function is used to append the new data to the existing data
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
  ///
  ///
  /// * bool Function(T data) isEmpty: This function is used to check whether `<T> data` is empty
  ///
  ///   This function is called by `fetchAndAdd()` to check if the response is empty
  ///
  ///   Parameters
  ///
  ///   * `<T> data`: the data to be checked whether it is empty
  ///
  ///   Returns: bool (true if empty, false if not empty)
  ///
  ///
  /// BE SURE TO PASS THE TYPE FOR BETTER DEVELOPMENT EXPERIENCE
  ///
  ///
  /// Other parameters: String `name`, Function `postInit`
  ///
  ///   * String `name`: This name will be printed in debug console along with each print.
  ///   If no name is given, names are not printed.
  ///
  ///   * Function `postInit`: This Function will be immediately called after the fetch during initialization
  ///
  /// Please note that the data will be converted to Rx type
  SerialGenerateObservable({
    required this.urlGenerator,
    required this.responseBodyToData,
    required this.add,
    required this.isEmpty,
    this.name = '',
    this.postInit,
  });

  
  @override
  void onInit() async {
    // called immediately after the widget is allocated memory
    _printExceptRelease('Called onInit');
    await reset();
    super.onInit();
    if (postInit != null) {
      postInit!();
    }
    _initializing.value = false;
  }

  /// Fetched data
  ///
  /// The value before initial fetch is `null`
  Rxn<T> _data = Rxn<T>(null);

  /// Fetched data
  ///
  /// The value before initial fetch is `null`
  T? get data => _data.value;

  /// If and only if fetch is in progress, value of this will be `true`
  RxBool _isLoading = false.obs;

  /// If and only if fetch is in progress, value of this will be `true`
  bool get isLoading => _isLoading.value;

  /// If and only if initializing, value of this will be `true`
  RxBool _initializing = true.obs;

  /// If and only if initializing, value of this will be `true`
  bool get initializing => _initializing.value;

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

  /// The current error. This will be empty if there is no error currently.
  final RxString _error = RxString('');

  /// The current error. This will be empty if there is no error currently.
  String get error => _error.value;

  /// If and only if there is some error, value of this will be true
  bool get isError => _error.isNotEmpty;

  /// A `fetch operation`
  ///
  /// Function to reset the fetch progress and restart fetching
  ///
  /// Please note that `limit` is unaffected by this operation
  Future<bool> reset() async {
    if (_isLoading.value) {
      _printExceptRelease(
          'Cancelling reset because another fetch operation is already in progress.');
      return false;
    }

    _endReached = false;

    _data.value = null;
    _offset = 0;

    return await fetchAndAdd();
  }

  /// A `fetch operation`
  ///
  /// Function to fetch new `<T> data` part from last `offset` till `offset + limit` and append to the existing `<T> data`
  Future<bool> fetchAndAdd() async {
    if (_isLoading.value) {
      _printExceptRelease(
          'Cancelling fetchAndAdd because another fetch operation is already in progress.');
      return false;
    }

    if (_endReached) {
      _printExceptRelease('Cancelling fetchAndAdd because endReached');
      return false;
    }

    _isLoading.value = true;

    Uri url = urlGenerator(_offset, _limit);
    _printExceptRelease('Calling fetch(), url: ${url.toString()}');

    Response response = await HTTP.get(url);

    /*if (response == null) {
      _printExceptRelease('Got null response');
      _isLoading.value = false;
      return false;
    }*/

    _printExceptRelease('Got response');

    T newData = responseBodyToData(response.body);

    _data.value = add(_data.value, responseBodyToData(response.body));

    if (isEmpty(newData)) {
      _endReached = true;
    } else {
      _offset += _limit;
    }

    _isLoading.value = false;

    return true;
  }

  String _getPrefix() => name.isEmpty ? '' : '$name: ';

  void _printExceptRelease(String message) {
    printExceptRelease('SerialFetchManager: ${_getPrefix()}$message');
  }
}*/

/*class SerialGenerateObservable<T> extends SingleGenerateObservable<T> {
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
  final T Function(T? existingData, T? newData) add;

  /// This function is used to check whether `<T> data` is empty
  ///
  ///   This function is called by `fetchAndAdd()` to check if the response is empty
  ///
  ///   Parameters
  ///
  ///   * `<T> data`: the data to be checked whether it is empty
  ///
  ///   Returns: bool (true if empty, false if not empty)
  final bool Function(T data) isEmpty;

  

  SerialGenerateObservable({
    required final Future<T?> Function(int offset, int limit) dataGenerator,
    required this.add,
    required this.isEmpty,
    VoidCallback? postInit,
    final String name = '',
    final Duration? timeout,
  }) : super(
          dataGenerator: (x) async => add(x, await dataGenerator(_offset, _limit,)),
          postInit: postInit,
          name: name,
          timeout: timeout,
        );

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
}*/

/*class SerialGenerateObservable<T> extends DataGenerateObservable<T> {
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
  final T Function(T? existingData, T? newData) add;

  /// This function is used to check whether `<T> data` is empty
  ///
  ///   This function is called by `fetchAndAdd()` to check if the response is empty
  ///
  ///   Parameters
  ///
  ///   * `<T> data`: the data to be checked whether it is empty
  ///
  ///   Returns: bool (true if empty, false if not empty)
  final bool Function(T data) isEmpty;

  /// The function that generates <T> data
  @protected
  final Future<T?> Function(T? data, int offset, int limit) dataGenerator;

  SerialGenerateObservable({
    required this.dataGenerator,
    required this.add,
    required this.isEmpty,
    final String name = '',
    final VoidCallback? postInit,
    final Duration? timeout,
  }) : super(
          name: name,
          postInit: postInit,
          timeout: timeout,
        );

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

  @protected
  Future<T?> generateData() async => add(
        _data.value,
        await dataGenerator(
          _data.value,
          _offset,
          _limit,
        ),
      );
}*/

class SerialGenerateObservable<T> extends PartDataGenerateObservable<T> {
  @protected
  final Future<T?> Function(T? data, int offset, int limit) dataGenerator;

  SerialGenerateObservable({
    required this.dataGenerator,
    required super.add,
    required super.isEmpty,
    super.name = '',
    super.postInit,
    super.timeout,
    super.filter,
    super.generateOnInit = true,
  });

  @override
  Future<T?> generateData() async =>
      dataGenerator(_data.value, _offset, _limit);
}

class SerialGenerateObservableX<T, X>
    extends PartDataGenerateObservableX<T, X> {
  @protected
  final Future<T?> Function(T? data, X? otherData, int offset, int limit)
      dataGenerator;

  SerialGenerateObservableX({
    required this.dataGenerator,
    required super.add,
    required super.isEmpty,
    super.onOtheDataChanged,
    super.name = '',
    super.postInit,
    super.timeout,
    super.filter,
    super.generateOnInit = true,
    super.otherData,
  });

  @override
  Future<T?> generateData() async =>
      dataGenerator(_data.value, _otherData.value, _offset, _limit);
}
