extension IterableExt<T> on Iterable<T> {
  T? firstOrNull() {
    try {
      return first;
    } catch (e) {
      return null;
    }
  }

  T? lastOrNull() {
    try {
      return last;
    } catch (e) {
      return null;
    }
  }

  T? firstWhereOrNull(bool Function(T element) judgeFunc) {
    T? result;
    for (T element in this) {
      if (judgeFunc(element)) {
        result = element;
        break;
      }
    }
    return result;
  }

  T? singleWhereOrNull(bool Function(T element) judgeFunc) {
    try {
      return singleWhere(judgeFunc);
    } catch (e) {
      return null;
    }
  }

  T? lastWhereOrNull(bool Function(T element) judgeFunc) {
    late T result;
    bool foundMatching = false;
    for (T element in this) {
      if (judgeFunc(element)) {
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;

    return null;
  }

  int sumBy(int Function(T element) judgeFunc) {
    int sum = 0;
    forEach((element) {
      sum += judgeFunc(element);
    });
    return sum;
  }

  Map<K, T> toMap<K>(K Function(T) findKey) {
    final Map<K, T> map = <K, T>{
      for (T element in this) findKey(element): element
    };
    return map;
  }
}

extension ListExt<T> on List<T> {
  T? getOrNull(int index) {
    try {
      return this[index];
    } catch (e) {
      return null;
    }
  }

  T? firstOrNull() {
    try {
      return first;
    } catch (e) {
      return null;
    }
  }

  T? lastOrNull() {
    try {
      return last;
    } catch (e) {
      return null;
    }
  }

  List<List<T>> splitList({int splitNum = 50}) {
    final int searchLoop =
        length ~/ splitNum + (length % splitNum == 0 ? 0 : 1).toInt();

    final List<List<T>> splitList =
        List<List<T>>.generate(searchLoop, (int index) {
      if (index == searchLoop - 1) {
        return sublist(index * splitNum);
      } else {
        return sublist(index * splitNum, (index + 1) * splitNum - 1);
      }
    }).toList();
    return splitList;
  }

  T? firstWhereOrNull(bool Function(T element) judgeFunc) {
    T? result;
    for (T element in this) {
      if (judgeFunc(element)) {
        result = element;
        break;
      }
    }
    return result;
  }

  T? singleWhereOrNull(bool Function(T element) judgeFunc) {
    try {
      return singleWhere(judgeFunc);
    } catch (e) {
      return null;
    }
  }

  T? lastWhereOrNull(bool Function(T element) judgeFunc) {
    late T result;
    bool foundMatching = false;
    for (T element in this) {
      if (judgeFunc(element)) {
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;

    return null;
  }

  T? lastWhereIndexedOrNull(bool Function(int index, T element) judgeFunc) {
    T? result;
    int length = this.length;
    for (int i = length - 1; i >= 0; i--) {
      T element = elementAt(i);
      if (judgeFunc(i, element)) return element;
    }
    return result;
  }

  int? indexWhereOrNull(bool Function(T element) judgeFunc) {
    int index = indexWhere(judgeFunc);
    if (index < 0) {
      return null;
    } else {
      return index;
    }
  }

}

extension DuplicateListExt<T> on List<List<T>> {
  List<T> mergeList() {
    final List<T> results = [];
    forEach((List<T> element) => results.addAll(element));
    return results;
  }
}

extension IntListExt on Iterable<int> {
  int sum() {
    return reduce((int a, int b) => a + b);
  }
}
