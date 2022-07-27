library network_utilities;

// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:flutter_utilities/flutter_utilities.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

//exports
export 'package:http/http.dart';

/// This function can be used to upload files
Future<String> uploadFile(
  File file,
  Uri uri, {
  String methodName = 'POST',
  String field = 'FILE',
  Map<String, String> headers = const {},
  Map<String, String> fields = const {},
  void Function(int completed, int total)? onProgress,
  void Function()? onComplete,
}) async {
  //final MultipartRequest request = MultipartRequest(methodName, uri);
  final CustomMultipartRequest request = CustomMultipartRequest(
    methodName,
    uri,
    onProgress: (done, total) {
      //printExceptRelease('Upload progress: $done/$total : ${done / total}');
      if (onProgress != null) {
        onProgress(done, total);
      }
      if ((done / total == 1.0) && onComplete != null) {
        onComplete();
      }
    },
  );

  request.files.add(
    http.MultipartFile.fromBytes(
      field,
      file.readAsBytesSync(),
      filename: basename(file.path),
    ),
  );
  request.headers.addAll(headers);
  request.fields.addAll(fields);

  return request.send().then((response) => response.stream.bytesToString());
}

class CustomMultipartRequest extends http.MultipartRequest {
  /// Creates a new [MultipartRequest].
  CustomMultipartRequest(
    super.method,
    super.url, {
    this.onProgress,
  });

  final void Function(int bytes, int totalBytes)? onProgress;

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress!(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}

/// Downloads the file from the url and returns bytes
Future<List<int>>? downloadFile(
  String url, {
  Function(int, int)? onProgressChanged,
  void Function()? onCompleted,
  void Function()? onError,
  String? downloadPath,
}) async {
  final request = http.Request('GET', Uri.parse(url));
  final http.StreamedResponse response = await http.Client().send(request);
  final int? length = response.contentLength;
  final List<int> downloadData = [];

  response.stream.listen(
    (value) {
      downloadData.addAll(value);
      if (onProgressChanged != null && length != null) {
        onProgressChanged(downloadData.length, length);
      }
    },
    onError: (error) {
      printExceptRelease('Error while downloading file: ${error.toString()}');
      if (onError != null) {
        onError();
      }
      return null;
    },
    onDone: () async {
      if (onCompleted != null) {
        onCompleted();
      }
      if (downloadPath != null) {
        try {
          await File(downloadPath).writeAsBytes(downloadData);
        } catch (e) {
          printExceptRelease(
            'Error while writing the file to local storage: $e',
          );
        }
      }
    },
  );
  return downloadData;
}

/// Returns true if the passed url is a youtube url
bool isYouTubeLink(String url) =>
    url.toLowerCase().contains('youtube.com') ||
    url.toLowerCase().contains('youtu.be');

/// Returns List of urls extracted from the string passed
List<String> extractLinks(String text) {
  /*RegExp urlRegex = RegExp(
      r'/(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])/igm');*/
  final RegExp urlRegex = RegExp(
    r'^((http|ftp|https)://)?([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?',
  );

  return urlRegex.allMatches(text).map<String>((e) {
    return text.substring(e.start, e.end);
  }).toList();
}

enum GetFromCache { always, whenUnableToGetResponse }

class HTTP {
  static final http.Client _client = _initialize();

  static Duration timeoutDuration = const Duration(seconds: 45);

  static Client _initialize() => http.Client();
  /*RetryClient(
        http.Client(),
        retries: 20,
        onRetry: (request, response, count) {
          _printExceptRelease('Retrying $count: ${request.url}');
        },
      );*/

  static const List<int> _key = [
    210,
    116,
    211,
    239,
    186,
    158,
    49,
    255,
    94,
    0,
    55,
    48,
    124,
    254,
    20,
    97,
    186,
    32,
    61,
    166,
    46,
    224,
    24,
    199,
    2,
    60,
    159,
    206,
    164,
    207,
    157,
    140
  ];

  static bool _cacheInitialized = false;
  static const String _subDir = '\\HTTPCache';
  static const String _boxName = "http_cache";

  static Future<Box<String>> _initializeCache() async {
    if (_cacheInitialized) {
      return Hive.box<String>(_boxName);
    }
    await Hive.initFlutter(_subDir);
    // TODO: secure storage will be implemented once it gets stable
    /*if (isSmartPhone || Platform.isLinux) {
      
    } else {

    }*/
    final Box<String> result = await Hive.openBox<String>(
      _boxName,
      encryptionCipher: HiveAesCipher(_key),
    );
    _cacheInitialized = true;
    return result;
  }

  static http.Response _responseFromJsonString(String jsonString) {
    final Map x = jsonDecode(jsonString) as Map;
    final Map<String, String> headers = {};
    (x["headers"] as Map).forEach((key, value) {
      headers.addAll({
        key as String: value as String,
      });
    });
    final http.Response result = http.Response(
      x["body"] as String,
      x["statuscode"] as int,
      headers: headers,
    );
    return result;
  }

  static String _responseToJsonString(http.Response response) {
    final Map<String, dynamic> map = {
      "body": response.body,
      "statuscode": response.statusCode,
      "headers": response.headers,
    };
    final String result = jsonEncode(map);
    return result;
  }

  static Future<http.Response> get(
     Uri uri, {
     Map<String, String>? headers,
     bool cache = false,
     String? cacheKey,
     GetFromCache getFromCacheMode = GetFromCache.whenUnableToGetResponse,
  }) async {
    late final http.Response res;
    if (cache) {
      final Box<String> cache = await _initializeCache();
      final String key = cacheKey ?? uri.toString();
      switch (getFromCacheMode) {
        case GetFromCache.always:
          if (cache.containsKey(key)) {
            res = _responseFromJsonString(cache.get(key)!);
          } else {
            res = await _client.get(uri, headers: headers);
            cache.put(key, _responseToJsonString(res));
          }
          break;
        case GetFromCache.whenUnableToGetResponse:
          try {
            res = await _client
                .get(uri, headers: headers)
                .timeout(timeoutDuration);
            cache.put(key, _responseToJsonString(res));
          } catch (e) {
            _printExceptRelease('Error: ${e.toString()}');
            if (cache.containsKey(key)) {
              res = _responseFromJsonString(cache.get(key)!);
            } else {
              _printExceptRelease("Couldn't find response in cache!");
              rethrow;
            }
          }
      }
      if (res.body.length < 20) {
        _printExceptRelease('Response: ${res.body}');
      }
      return res;
    }
    try {
      res = await _client.get(uri, headers: headers);
      if (res.body.length < 20) {
        _printExceptRelease('Response: ${res.body}');
      }
    } catch (e) {
      _printExceptRelease('Error: ${e.toString()}');
    }
    return res;
  }

  static bool _defaultTrueIf(String x) => x == '1';

  static Future<bool> boolGet(
     Uri uri, {
     Map<String, String>? headers,
     bool Function(String) trueIf = _defaultTrueIf,
  }) async {
    final http.Response res = await _client.get(uri, headers: headers);
    if (res.body.length < 20) {
      _printExceptRelease('Response: ${res.body}');
    }
    return trueIf(res.body);
  }

  static Future<void> clearCache() async {
    //await Hive.deleteBoxFromDisk(_boxName);
    await _initializeCache().then((value) async => value.clear());
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _client.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  static void dispose() {
    _client.close();
    if (_cacheInitialized) {
      _initializeCache().then(
        (value) => value.close().then(
          (_) {
            _cacheInitialized = false;
          },
        ),
      );
    }

    _printExceptRelease('Disposed');
  }

  static void _printExceptRelease(String message) {
    printExceptRelease('HTTP: $message');
  }
}
