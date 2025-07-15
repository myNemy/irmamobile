import 'dart:collection';

class ConDisCon<T> extends UnmodifiableListView<DisCon<T>> {
  ConDisCon(super.list);

  // This can't be a contructor due to dart-lang/sdk#26391
  static ConDisCon<T> fromRaw<R, T>(List<List<List<R>>> rawConDisCon, T Function(R) fromRaw) {
    return ConDisCon<T>(
      rawConDisCon.map((rawDisCon) {
        return DisCon<T>(
          rawDisCon.map((rawCon) {
            return Con<T>(
              rawCon.map((elem) {
                return fromRaw(elem);
              }),
            );
          }),
        );
      }),
    );
  }

  // This can't be a contructor due to dart-lang/sdk#26391
  static ConDisCon<T> fromConCon<T>(ConCon<T> conCon) {
    return ConDisCon<T>(
      conCon.map((con) {
        return DisCon<T>(<Con<T>>[con]);
      }),
    );
  }
}

class DisCon<T> extends UnmodifiableListView<Con<T>> {
  DisCon(super.list);
}

class ConCon<T> extends UnmodifiableListView<Con<T>> {
  ConCon(super.list);

  // This can't be a contructor due to dart-lang/sdk#26391
  static ConCon<T> fromRaw<R, T>(List<List<R>> rawConCon, T Function(R) fromRaw) {
    return ConCon<T>(
      rawConCon.map((rawCon) {
        return Con<T>(
          rawCon.map((elem) {
            return fromRaw(elem);
          }),
        );
      }),
    );
  }
}

class Con<T> extends UnmodifiableListView<T> {
  // Convert iterable to list first to prevent issues with late type checking.
  Con(Iterable<T> iterable) : super(iterable.toList());
}
