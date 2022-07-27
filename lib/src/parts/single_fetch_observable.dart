part of data_management_utilities;

/*class SingleFetchObservable<T> extends SingleGenerateObservable<T> {
  /// The url to fetch the data
  final Uri Function(T? data) urlGenerator;

  /// The function that converts http response body to `<T> data`
  final T Function(String resposeBody) responseBodyToData;

  /// Used for listening to a data that requires one time fetch
  ///
  /// REQUIRED PARAMETERS: `url`, `responseBodyToData`
  ///
  /// * `url`: Uri to fetch `<T> data` from
  ///
  /// * `responseBodyToData`: The function that is used to convert `response body` to `<T> data`
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
  SingleFetchObservable({
    required this.urlGenerator,
    required this.responseBodyToData,
    final void Function()? postInit,
    final String name = '',
    final Duration? timeout,
  }) : super(
          dataGenerator: (x) async => null,
          name: name,
          postInit: postInit,
          timeout: timeout,
        );

  /// Function to fetch `<T> data` and override the existing data by new data
  ///
  /// Calling fetch will override the existing data with the newly fetched data
  ///
  /// `fetch` and `generate` are exactly the same
  @mustCallSuper
  @override
  Future<bool> generate() async {
    if (_isLoading.value) {
      _printExceptRelease(
          'Cancelling fetch because another fetch is already in progress.');
      return false;
    }

    _isLoading.value = true;
    Uri url = urlGenerator(_data.value);
    _printExceptRelease('Calling fetch(), url: ${url.toString()}');

    late final Response response;

    if (timeout != null) {
      response = await HTTP.get(url).timeout(timeout!, onTimeout: () {
        _error.value = 'Timeout!';
        return Response('', 408);
      });
    } else {
      response = await HTTP.get(url);
    }

    if (response.body.isEmpty) {
      _printExceptRelease('Got empty response');
      _isLoading.value = false;
      return false;
    }

    _printExceptRelease('Got response');

    try {
      _data.value = responseBodyToData(response.body);
      _printExceptRelease('Response to data conversion complete');
    } catch (e) {
      _printExceptRelease('Error while conversion response body to data: $e');
      _error.value = e.toString();
    }

    _isLoading.value = false;

    _printExceptRelease('Loading values are set to false');

    return true;
  }

  /// Function to fetch `<T> data` and override the existing data by new data
  ///
  /// Calling fetch will override the existing data with the newly fetched data
  ///
  /// `fetch` and `generate` are exactly the same
  @Deprecated('Use generate() instead')
  Future<bool> fetch() async => await generate();

  void _printExceptRelease(String message) {
    printExceptRelease('${this.runtimeType}: $_prefix - $message');
  }
}*/

/*
class SingleFetchObservable<T> extends DataGenerateObservable<T> {
  /// The url to fetch the data
  final Uri Function(T? data) urlGenerator;

  /// The function that converts http response body to `<T> data`
  final T Function(String resposeBody) responseBodyToData;

  SingleFetchObservable({
    required this.urlGenerator,
    required this.responseBodyToData,
    final String name = '',
    final VoidCallback? postInit,
    final Duration? timeout,
  }) : super(
          name: name,
          postInit: postInit,
          timeout: timeout,
        );

  @protected
  Future<T?> generateData() async {
    Uri url = urlGenerator(_data.value);
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
      }
      response = await HTTP.get(url).timeout(timeout!, onTimeout: () {
        _error.value = 'Timeout!';
        return Response('', 408);
      });
    } else {
      response = await HTTP.get(url);
    }

    if (response.body.isEmpty) {
      printInConsole('Got empty response');
      return null;
    }

    printInConsole('Got response');

    late final T result;

    try {
      result = responseBodyToData(response.body);
    } catch (e) {
      printInConsole('Error while conversion response body to data: $e');
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
  @Deprecated('Use generate() instead')
  Future<bool> fetch() async => await generate();
}*/

class SingleFetchObservable<T> extends DataFetchObservable<T> {
  /// The url to fetch the data
  final Uri Function(T? data) urlGenerator;

  SingleFetchObservable({
    required this.urlGenerator,
    required super.responseBodyToData,
    super.name = '',
    super.postInit,
    super.filter,
    super.generateOnInit = true,
    super.timeout,
  });

  @protected
  @override
  Uri generateUrl() => urlGenerator(_data.value);
}

class SingleFetchObservableX<T, X> extends DataFetchObservableX<T, X> {
  /// The url to fetch the data
  final Uri Function(T? data, X? otherData) urlGenerator;

  SingleFetchObservableX({
    required this.urlGenerator,
    required super.responseBodyToData,
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
  Uri generateUrl() => urlGenerator(_data.value, _otherData.value);
}

/*class SingleFetchObservable<T> extends SingleGenerateObservable<T> {
  /// The url to fetch the data
  final Uri Function(T? data) urlGenerator;

  /// The function that converts http response body to `<T> data`
  final T Function(String resposeBody) responseBodyToData;

  SingleFetchObservable({
    required this.urlGenerator,
    required this.responseBodyToData,
    final String name = '',
    final VoidCallback? postInit,
    final Duration? timeout,
  }) : super(
          dataGenerator: (x) async => null,
          name: name,
          postInit: postInit,
          timeout: timeout,
        );

  @override
  @protected
  Future<T?> generateData() async {
    final Uri url = urlGenerator(_data.value);
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
    } catch (e) {
      printInConsole('Error while conversion response body to data: $e');
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
  Future<bool> fetch() async => await generate();
}*/

/*class SingleFetchObservableX<T, X> extends SingleGenerateObservableX<T, X> {
  /// The url to fetch the data
  final Uri Function(T? data, X? otherData) urlGenerator;

  /// The function that converts http response body to `<T> data`
  final T Function(String resposeBody) responseBodyToData;

  SingleFetchObservableX({
    required this.urlGenerator,
    required this.responseBodyToData,
    final String name = '',
    final VoidCallback? postInit,
    final Duration? timeout,
    X? otherData,
  }) : super(
          dataGenerator: (x, y) async => null,
          name: name,
          postInit: postInit,
          timeout: timeout,
          otherData: otherData,
        );

  @override
  @protected
  Future<T?> generateData() async {
    final Uri url = urlGenerator(_data.value, _otherData.value);
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
    } catch (e) {
      printInConsole('Error while conversion response body to data: $e');
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
  Future<bool> fetch() async => await generate();
}*/

/*
class SingleFetchObservableX<T, X> extends SingleGenerateObservableX<T, X> {
  SingleFetchObservableX({
    required this.urlGenerator,
    required this.responseBodyToData,
    final void Function()? postInit,
    final void Function(SingleGenerateObservableX<T, X>)? onOtheDataChanged,
    final String name = '',
    final Duration? timeout,
  }) : super(
          dataGenerator: (x, y) async => null,
          onOtheDataChanged: onOtheDataChanged,
          postInit: postInit,
          timeout: timeout,
          name: name,
        );

  /// The url to fetch the data
  final Uri Function(T? data, X? otherData) urlGenerator;

  /// The function that converts http response body to `<T> data`
  final T Function(String resposeBody) responseBodyToData;

  /// Function to fetch `<T> data` and override the existing data by new data
  ///
  /// Calling fetch will override the existing data with the newly fetched data
  ///
  /// `fetch` and `generate` are exactly the same
  @mustCallSuper
  @override
  Future<bool> generate() async {
    if (_isLoading.value) {
      _printExceptRelease(
          'Cancelling fetch because another fetch is already in progress.');
      return false;
    }

    _isLoading.value = true;
    Uri url = urlGenerator(_data.value, _otherData.value);
    _printExceptRelease('Calling fetch(), url: ${url.toString()}');

    late final Response response;

    if (timeout != null) {
      response = await HTTP.get(url).timeout(timeout!, onTimeout: () {
        _error.value = 'Timeout!';
        return Response('', 408);
      });
    } else {
      response = await HTTP.get(url);
    }

    if (response.body.isEmpty) {
      _printExceptRelease('Got empty response');
      _isLoading.value = false;
      return false;
    }

    _printExceptRelease('Got response');

    try {
      _data.value = responseBodyToData(response.body);
      _printExceptRelease('Response to data conversion complete');
    } catch (e) {
      _printExceptRelease('Error while conversion response body to data: $e');
      _error.value = e.toString();
    }

    _isLoading.value = false;

    _printExceptRelease('Loading values are set to false');

    return true;
  }

  /// Function to fetch `<T> data` and override the existing data by new data
  ///
  /// Calling fetch will override the existing data with the newly fetched data
  ///
  /// `fetch` and `generate` are exactly the same
  @Deprecated('Use generate() instead')
  Future<bool> fetch() async => await generate();

  @override
  void _printExceptRelease(String message) {
    printExceptRelease('${this.runtimeType}: $_prefix - $message');
  }
}*/
