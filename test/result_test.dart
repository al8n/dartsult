import 'package:dartsult/src/result.dart';
import 'package:test/test.dart';

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

void main() {
  group('Result tests', () {
    MockException mock = MockException('cannot get int value');

    MockException mock1 = MockException('cannot get void value');

    MockException mock2 = MockException('from another error');

    test('Test int result with ok', () async {
      Result intRst = await intResult(false);
      expect(intRst.isOk(), true);
      expect(intRst.unwrap(), 5);
      expect(intRst.contains(5), true);
      expect(intRst.contains(6), false);
    });

    test('Test int result with error', () async {
      Result<int, MockException> intErrRst = await intResult(true);
      expect(intErrRst.isError(), true);
      expect(intErrRst.unwrapError().toString(),
          'MockException(cannot get int value)');
      expect(intErrRst.containsError(mock), true);
      expect(intErrRst.unwrapOr(6), 6);
      expect(intErrRst.unwrapOrElse((_) => 7), 7);
    });

    test('Test void result with ok', () async {
      Result voidRst = await voidResult(false);
      expect(voidRst.isOk(), true);
      expect(voidRst.unwrap(), Void());
      expect(voidRst.contains(Void()), true);
    });

    test('Test void result with error', () async {
      Result voidErrRst = await voidResult(true);
      expect(voidErrRst.isError(), true);
      expect(voidErrRst.unwrapError().toString(),
          'MockException(cannot get void value)');
      expect(voidErrRst.containsError(mock1), true);
      expect(voidErrRst.unwrapOr(Void()), Void());
      expect(voidErrRst.unwrapOrElse((_) => Void()), Void());
    });

    test('Test unwrap', () {
      Result<int, String> x = Result.ok(2);
      expect(x.unwrap(), 2);

      x = Result.error("emergency failure");
      try {
        x.unwrap();
      } catch (e) {
        expect(e.toString(), "Null check operator used on a null value");
      }
    });

    test('Test unwrapError', () {
      Result<int, String> x = Result.error("emergency failure");
      expect(x.unwrapError(), "emergency failure");

      x = Result.ok(2);
      try {
        x.unwrapError();
      } catch (e) {
        expect(e.toString(), "Null check operator used on a null value");
      }
    });

    test('Test unwrapOr', () {
      int defaultt = 2;
      Result<int, String> x = Result.ok(9);
      expect(x.unwrapOr(defaultt), 9);

      x = Result.error("error");
      expect(x.unwrapOr(defaultt), defaultt);
    });

    test('Test unwrapOrElse', () {
      int count(String x) {
        return x.length;
      }

      expect(Result.ok<int, String>(2).unwrapOrElse(count), 2);
      expect(Result.error<int, String>("foo").unwrapOrElse(count), 3);
    });

    test('Test map', () {
      String stringify(int x) {
        return 'code: $x';
      }

      Result<int, String> x = Result.ok<int, String>(13);
      expect(x.map(stringify), Result.ok<String, String>('code: 13'));
    });

    test('Test mapError', () async {
      String stringify(int x) {
        return 'error code: $x';
      }

      Result<int, int> x = Result.ok(2);
      expect(x.mapError(stringify), Result.ok<int, String>(2));

      x = Result.error(13);
      expect(
          x.mapError(stringify), Result.error<int, String>("error code: 13"));
    });

    test('Test mapOr', () {
      Result<dynamic, String> x = Result.ok<dynamic, String>("foo");
      int val = x.mapOr<int>(42, (v) => v.length);
      expect(val, 3);

      Result<String, dynamic> y = Result.error<String, dynamic>("bar");
      int val1 = y.mapOr<int>(42, (v) => v.length);
      expect(val1, 42);
    });

    test('Test mapOrElse', () {
      int k = 21;

      Result<dynamic, String> x = Result.ok<dynamic, String>("foo");
      int val = x.mapOrElse<int>((v) => k * 2, (v) => v.length);
      expect(val, 3);

      Result<String, dynamic> y = Result.error<String, dynamic>("bar");
      int val1 = y.mapOrElse<int>((v) => k * 2, (v) => v.length);
      expect(val1, 42);
    });

    test('Test or', () {
      Result<int, String> x = Result.ok(2);
      Result<int, String> y = Result.error("late error");
      expect(x.or(y), Result.ok<int, String>(2));

      x = Result.error("early error");
      y = Result.ok(2);
      expect(x.or(y), Result.ok<int, String>(2));

      x = Result.ok(2);
      y = Result.ok(100);
      expect(x.or(y), Result.ok<int, String>(2));
    });

    test('Test orElse', () {
      Result<int, int> sq(int x) {
        return Result.ok(x * x);
      }

      Result<int, int> err(int x) {
        return Result.error(x);
      }

      expect(
          Result.ok<int, int>(2).orElse(sq).orElse(sq), Result.ok<int, int>(2));
      expect(Result.ok<int, int>(2).orElse(err).orElse(sq),
          Result.ok<int, int>(2));
      expect(Result.error<int, int>(3).orElse(sq).orElse(err),
          Result.ok<int, int>(9));
      expect(Result.error<int, int>(3).orElse(err).orElse(err),
          Result.error<int, int>(3));
    });

    test('Test and', () {
      Result<int, String> x = Result.ok(2);
      Result<String, String> y = Result.error("late error");

      expect(x.and(y), Result.error<String, String>("late error"));

      x = Result.error("early error");
      y = Result.ok("foo");
      expect(x.and(y), Result.error<String, String>("early error"));

      x = Result.error("not a 2");
      y = Result.error("late error");
      expect(x.and(y), Result.error<String, String>("not a 2"));

      x = Result.ok(2);
      y = Result.ok("different result type");
      expect(x.and(y), Result.ok<String, String>("different result type"));
    });

    test('Test andThen', () {
      Result<int, int> sq(int x) {
        return Result.ok(x * x);
      }

      Result<int, int> err(int x) {
        return Result.error(x);
      }

      expect(Result.ok<int, int>(2).andThen(sq).andThen(sq),
          Result.ok<int, int>(16));
      expect(Result.ok<int, int>(2).andThen(sq).andThen(err),
          Result.error<int, int>(4));
      expect(Result.ok<int, int>(2).andThen(err).andThen(sq),
          Result.error<int, int>(2));
      expect(Result.error<int, int>(3).andThen(sq).andThen(sq),
          Result.error<int, int>(3));
    });

    test('Test Ok toString, hashCode', () async {
      Result<int, String> okint = Result.ok(5);
      Result<int, String> okint1 = Result.ok(5);
      expect(okint.toString(), 'Ok(5)');
      expect(okint, okint1);
      expect(okint.hashCode, "Ok".hashCode + 5.hashCode);

      Result<int, String> errint = Result.error("asd");
      expect(errint.hashCode, 'Error'.hashCode + 'asd'.hashCode);
    });

    test('Test Void to hashcode', () async {
      expect(Void().hashCode, 0);
    });
  });
}
