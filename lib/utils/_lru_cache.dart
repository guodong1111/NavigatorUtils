import 'dart:collection';

class LRUMap<K, V> {
  LRUMap(this._maxSize, [this._handler]);

  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();
  final int _maxSize;
  final EvictionHandler<K, V>? _handler;

  V? operator [](K key) {
    final V? value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  void operator []=(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    if (_map.length > _maxSize) {
      final K evictedKey = _map.keys.first;
      final V evictedValue = _map.remove(evictedKey)!;
      if (_handler != null) {
        _handler!(evictedKey, evictedValue);
      }
    }
  }

  V putIfAbsent(K key, V Function() create) {
    final V? value = this[key];
    if (null == value) {
      final V newValue = create();
      this[key] = newValue;
      return newValue;
    } else {
      return value;
    }
  }

  Iterable<K> get keys => _map.keys;

  Iterable<V> get values => _map.values;

  int get length => _map.length;

  bool get isEmpty => _map.isEmpty;

  bool get isNotEmpty => _map.isNotEmpty;

  void remove(K key) {
    _map.remove(key);
  }

  void clear() {
    _map.clear();
  }

  @override
  String toString() {
    return _map.toString();
  }
}

// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

typedef EvictionHandler<K, V>(K key, V value);
