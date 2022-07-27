library data_structures;

//TODO: complete Constant Classes

class Pair<A, B> {
  final bool unmodifiable;
  A _a;
  B _b;

  A get a => _a;
  B get b => _b;

  set a(A data) {
    if (unmodifiable) {
      throw 'Error! Unmodifiable Pair';
    }
    _a = data;
  }

  set b(B data) {
    if (unmodifiable) {
      throw 'Error! Unmodifiable Pair';
    }
    _b = data;
  }

  Pair(A a, B b, {this.unmodifiable = false})
      : _a = a,
        _b = b;

  @override
  bool operator ==(Object o) =>
      (o is Pair<A, B> && o.a == a && o.b == b) ||
      (o is CPair<A, B> && o.a == a && o.b == b);

  @override
  int get hashCode => a.hashCode + b.hashCode;

  Map<String, dynamic> toJson() => {
        "a": a,
        "b": b,
      };

  @override
  String toString() => toJson().toString();

  factory Pair.from(Pair<A, B> other) => Pair<A, B>(other.a, other.b);

  factory Pair.fromCPair(final CPair<A, B> other) =>
      Pair<A, B>(other.a, other.b);
}

class CPair<A, B> {
  final A a;
  final B b;

  const CPair(this.a, this.b);

  @override
  bool operator ==(Object o) =>
      (o is Pair<A, B> && o.a == a && o.b == b) ||
      (o is CPair<A, B> && o.a == a && o.b == b);

  @override
  int get hashCode => a.hashCode + b.hashCode;

  Map<String, dynamic> toJson() => {
        "a": a,
        "b": b,
      };

  @override
  String toString() => toJson().toString();

  factory CPair.from(CPair<A, B> other) => CPair<A, B>(other.a, other.b);

  factory CPair.fromPair(Pair<A, B> other) => CPair<A, B>(other.a, other.b);

  List<dynamic> toList({
    final bool reverse = false,
  }) =>
      reverse ? List<dynamic>.from([b, a]) : List<dynamic>.from([a, b]);
}

class Triad<A, B, C> extends Pair<A, B> {
  C _c;

  C get c => _c;

  set c(C data) {
    if (unmodifiable) {
      throw 'Error! Unmodifiable Pair';
    }
    _c = data;
  }

  Triad(A a, B b, C c, {bool unmodifiable = false})
      : _c = c,
        super(
          a,
          b,
          unmodifiable: unmodifiable,
        );

  @override
  bool operator ==(Object o) =>
      o is Triad<A, B, C> && o._a == _a && o._b == _b && o._c == _c;

  @override
  int get hashCode => super.hashCode + c.hashCode;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "c": _c,
    });

  factory Triad.from(Triad<A, B, C> other) =>
      Triad<A, B, C>(other.a, other.b, other.c);
}

class CTriad<A, B, C> extends CPair<A, B> {
  final C c;
  const CTriad(A a, B b, this.c) : super(a, b);
}

class Quad<A, B, C, D> extends Triad<A, B, C> {
  D _d;

  D get d => _d;

  set d(D data) {
    if (unmodifiable) {
      throw 'Error! Unmodifiable Pair';
    }
    _d = data;
  }

  Quad(A a, B b, C c, D d, {bool unmodifiable = false})
      : _d = d,
        super(
          a,
          b,
          c,
          unmodifiable: unmodifiable,
        );

  @override
  bool operator ==(Object o) =>
      o is Quad<A, B, C, D> &&
      o._a == _a &&
      o._b == _b &&
      o._c == _c &&
      o._d == _d;

  @override
  int get hashCode => super.hashCode + d.hashCode;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "d": _d,
    });

  factory Quad.from(Quad<A, B, C, D> other) =>
      Quad<A, B, C, D>(other.a, other.b, other.c, other.d);
}

class CQuad<A, B, C, D> extends CTriad<A, B, C> {
  final D d;
  const CQuad(A a, B b, C c, this.d) : super(a, b, c);
}
