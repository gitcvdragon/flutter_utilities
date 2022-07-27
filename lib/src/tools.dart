library tools;

import 'package:flutter_utilities/flutter_utilities.dart';

class VolatileCacheManager {
  factory VolatileCacheManager() => _cacheManager ??= VolatileCacheManager._();

  static VolatileCacheManager? _cacheManager;

  VolatileCacheManager._() {
    logExceptRelease("VolatileCacheManager initialized.");
  }

  int _limit = 20;

  // ignore: avoid_setters_without_getters
  set limit(int value) {
    _limit = value;
  }

  final List<String> _indices = [];

  final Map<String, dynamic> _cache = {};

  /// Get the data from cache
  ///
  /// Parameters
  /// * String key: the key of which the data is requested
  ///
  /// Returns: T data: the data at [key]. Returns null when no data is stored for the passed key
  T? getData<T>(String key) => _cache[key] as T;

  /// Store data to the cache
  ///
  /// Requires a key, which will be used to get the data back
  ///
  /// Parameters
  /// * String [key]: key for which store the data
  /// * T [data]: the data to store
  ///
  /// Returns: nothing
  void setData<T>(String key, T data) {
    if ((_indices.length + 1) > _limit) {
      _deleteData(0);
    }
    _cache[key] = data;
    _indices.add(key);
  }

  void _deleteData(int index) {
    _cache.remove(_indices[index]);
    _indices.removeAt(index);
  }

  /// Clears all the data stored
  ///
  /// Parameters: nothing
  ///
  /// Returns: nothing
  void clearCaches() {
    _cache.clear();
    _indices.clear();
  }
}

/*class PersistantFileCache {
  static const String _subDir = '\\PersistantFileCache';
  static const String _boxName = "persistant_file_cache";
  /*static PersistantFileCache? _cache;

  factory PersistantFileCache() => _cache ??= PersistantFileCache._();

  PersistantFileCache._() {
    logExceptRelease("PersistantFileCache is initialized.");
  }*/

  static Box<String>? _entriesDB;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await Hive.initFlutter(_subDir);
    _entriesDB ??= await Hive.openBox<String>(_boxName);
    _initialized = true;
  }

  static Future<List<int>> getBytes({key}) async {
    
  }
}*/

class SingletonManager {
  const SingletonManager._();
  static final Map<String, dynamic> _objects = {};
  static E put<E>({
    required E object,
    required String key,
  }) {
    if (_objects.containsKey(key)) {
      _printExceptRelease(
        'The key: $key already exists. Overwriting with new object.',
      );
    }
    _objects[key] = object;
    return object;
  }

  static E find<E>(String key) {
    if (!_objects.containsKey(key)) {
      _printExceptRelease(
        "Object for key: $key doesn't exists. You need to call 'put(Object)' first.",
      );
    }
    return _objects[key] as E;
  }

  static void dispose<E>({
    required String key,
    void Function(E object)? onDispose,
  }) {
    if (_objects.containsKey(key)) {
      onDispose?.call(_objects[key] as E);
      _objects.remove(key);
    }
  }

  static void _printExceptRelease(String message) {
    printExceptRelease('SingletonManager: $message');
  }
}

class ChangeTracker {
  final Map<String, dynamic> _changesMap = {};

  void processChanges<T>({
    required T originalValue,
    required T modifiedValue,
    required String fieldName,
    bool Function(T originalValue, T modifiedValue)? removeIf,
  }) {
    if ((removeIf?.call(originalValue, modifiedValue)) ??
        (originalValue == modifiedValue)) {
      _changesMap.remove(fieldName);
    } else {
      _changesMap[fieldName] = modifiedValue;
    }
  }

  T getChangeFor<T>(String fieldName) => _changesMap[fieldName] as T;

  Map<String, dynamic> getChanges() => Map<String, dynamic>.from(_changesMap);

  bool get hasChanges => _changesMap.isNotEmpty;

  bool get hasNoChanges => _changesMap.isEmpty;
}
