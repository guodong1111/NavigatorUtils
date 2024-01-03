extension StandardExt<T> on T {
  R let<R>(R Function(T) block) {
    return block(this);
  }

  T also<R>(Function(T) block) {
    block(this);
    return this;
  }
}

extension FunctionStandardExt on Function {
  void run() {
    this();
  }
}

extension Function0StandardExt<R> on R Function() {
  R run() {
    return this();
  }
}

extension Function1StandardExt<T1, R> on R Function(T1) {
  R run(T1 t1) {
    return this(t1);
  }
}

extension Function2StandardExt<T1, T2, R> on R Function(T1, T2) {
  R run(T1 t1, T2 t2) {
    return this(t1, t2);
  }
}

extension Function3StandardExt<T1, T2, T3, R> on R Function(T1, T2, T3) {
  R run(T1 t1, T2 t2, T3 t3) {
    return this(t1, t2, t3);
  }
}

extension Function4StandardExt<T1, T2, T3, T4, R> on R Function(
    T1, T2, T3, T4) {
  R run(T1 t1, T2 t2, T3 t3, T4 t4) {
    return this(t1, t2, t3, t4);
  }
}
