import 'package:dartsult/dartsult.dart';

class MockException implements Exception {
  final String msg;

  MockException(this.msg);

  @override
  String toString() {
    return 'MockException($msg)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MockException && other.msg == msg;
  }

  @override
  int get hashCode => msg.hashCode;
}

Future<Result<Void, MockException>> voidResult(bool shouldPanic) async {
  return await mockLogic(null, 'cannot get void value',
          shouldPanic: shouldPanic)
      .then(
    (value) => Result.ok<Void, MockException>(Void()),
    onError: (error, stackTrace) => Result.error<Void, MockException>(
      error,
    ),
  );
}

Future<Result<int, MockException>> intResult(bool shouldPanic) async {
  return await mockLogic<int>(5, 'cannot get int value',
          shouldPanic: shouldPanic)
      .then(
    (value) => Result.ok<int, MockException>(value),
    onError: (error, stackTrace) => Result.error<int, MockException>(
      error,
    ),
  );
}

/// mockLogic is used to mock some network I/O, file I/O or other asynchronous
/// logic
Future<T> mockLogic<T>(T val, String msg, {bool shouldPanic = false}) {
  return Future.delayed(Duration(milliseconds: 100), () {
    if (shouldPanic) {
      throw MockException(msg);
    }
    return val;
  });
}

Result<int, int> sq(int x) {
  return Result.ok(x * x);
}

Result<int, int> err(int x) {
  return Result.error(x);
}

void unwrap() {
  Result<int, String> x = Result.ok(2);
  assert(x.unwrap() == 2);

  x = Result.error("emergency failure");
  try {
    x.unwrap();
  } catch (e) {
    assert(e.toString() == "Null check operator used on a null value");
  }
}

void unwrapError() {
  Result<int, String> x = Result.error("emergency failure");
  assert(x.unwrapError() == "emergency failure");

  x = Result.ok(2);
  try {
    x.unwrapError();
  } catch (e) {
    assert(e.toString() == "Null check operator used on a null value");
  }
}

void unwrapOr() {
  int defaultt = 2;
  Result<int, String> x = Result.ok(9);
  assert(x.unwrapOr(defaultt) == 9);

  x = Result.error("error");
  assert(x.unwrapOr(defaultt) == defaultt);
}

void unwrapOrElse() {
  int count(String x) {
    return x.length;
  }

  assert(Result.ok<int, String>(2).unwrapOrElse(count) == 2);
  assert(Result.error<int, String>("foo").unwrapOrElse(count) == 3);
}

void or() {
  Result<int, String> x = Result.ok(2);
  Result<int, String> y = Result.error("late error");
  assert(x.or(y) == Result.ok<int, String>(2));

  x = Result.error("early error");
  y = Result.ok(2);
  assert(x.or(y) == Result.ok<int, String>(2));

  x = Result.ok(2);
  y = Result.ok(100);
  assert(x.or(y) == Result.ok<int, String>(2));
}

void orElse() {
  assert(
      Result.ok<int, int>(2).orElse(sq).orElse(sq) == Result.ok<int, int>(2));
  assert(
      Result.ok<int, int>(2).orElse(err).orElse(sq) == Result.ok<int, int>(2));
  assert(Result.error<int, int>(3).orElse(sq).orElse(err) ==
      Result.ok<int, int>(9));
  assert(Result.error<int, int>(3).orElse(err).orElse(err) ==
      Result.error<int, int>(3));
}

void and() {
  Result<int, String> x = Result.ok(2);
  Result<String, String> y = Result.error("late error");

  assert(x.and(y) == Result.error<String, String>("late error"));

  x = Result.error("early error");
  y = Result.ok("foo");
  assert(x.and(y) == Result.error<String, String>("early error"));

  x = Result.error("not a 2");
  y = Result.error("late error");
  assert(x.and(y) == Result.error<String, String>("not a 2"));

  x = Result.ok(2);
  y = Result.ok("different result type");
  assert(x.and(y) == Result.ok<String, String>("different result type"));
}

void andThen() {
  assert(Result.ok<int, int>(2).andThen(sq).andThen(sq) ==
      Result.ok<int, int>(16));
  assert(Result.ok<int, int>(2).andThen(sq).andThen(err) ==
      Result.error<int, int>(4));
  assert(Result.ok<int, int>(2).andThen(err).andThen(sq) ==
      Result.error<int, int>(2));
  assert(Result.error<int, int>(3).andThen(sq).andThen(sq) ==
      Result.error<int, int>(3));
}

void map() {
  String stringify(int x) {
    return 'code: $x';
  }

  Result<int, String> x = Result.ok<int, String>(13);
  assert(x.map(stringify) == Result.ok<String, String>('code: 13'));
}

void mapError() {
  String stringify(int x) {
    return 'error code: $x';
  }

  Result<int, int> x = Result.ok(2);
  assert(x.mapError(stringify) == Result.ok<int, String>(2));

  x = Result.error(13);
  assert(x.mapError(stringify) == Result.error<int, String>("error code: 13"));
}

void mapOr() {
  Result<dynamic, String> x = Result.ok<dynamic, String>("foo");
  int val = x.mapOr<int>(42, (v) => v.length);
  assert(val == 3);

  Result<String, dynamic> y = Result.error<String, dynamic>("bar");
  int val1 = y.mapOr<int>(42, (v) => v.length);
  assert(val1 == 42);
}

void mapOrElse() {
  int k = 21;

  Result<dynamic, String> x = Result.ok<dynamic, String>("foo");
  int val = x.mapOrElse<int>((v) => k * 2, (v) => v.length);
  assert(val == 3);

  Result<String, dynamic> y = Result.error<String, dynamic>("bar");
  int val1 = y.mapOrElse<int>((v) => k * 2, (v) => v.length);
  assert(val1 == 42);
}

main() async {
  MockException mock = MockException('cannot get int value');
  MockException mock1 = MockException('cannot get void value');
  MockException mock2 = MockException('from another error');

  Result intRst = await intResult(false);
  assert(intRst.isOk());
  assert(intRst.unwrap() == 5);
  assert(intRst.contains(5));
  assert(intRst.contains(6) == false);

  Result<int, MockException> intErrRst = await intResult(true);
  assert(intErrRst.isError(), true);
  assert(intErrRst.unwrapError().toString() ==
      'MockException(cannot get int value)');
  assert(intErrRst.containsError(mock));
  assert(intErrRst.unwrapOr(6) == 6);
  assert(intErrRst.unwrapOrElse((_) => 7) == 7);

  Result voidRst = await voidResult(false);
  assert(voidRst.isOk());
  assert(voidRst.unwrap() == Void());
  assert(voidRst.contains(Void()));

  Result voidErrRst = await voidResult(true);
  assert(voidErrRst.isError(), true);
  assert(voidErrRst.unwrapError().toString() ==
      'MockException(cannot get void value)');
  assert(voidErrRst.containsError(mock1));
  assert(voidErrRst.unwrapOr(Void()) == Void());
  assert(voidErrRst.unwrapOrElse((_) => Void()) == Void());

  // unwrap
  unwrap();

  // unwrapError
  unwrapError();

  // unwrapOr
  unwrapOr();

  // unwrapOrElse
  unwrapOrElse();

  // or
  or();

  // orElse example
  orElse();

  // and
  and();

  // andThen
  andThen();

  // map
  map();

  // mapError
  mapError();

  // mapOr
  mapOr();

  // mapOrElse
  mapOrElse();
}
