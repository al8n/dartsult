import 'package:dartsult/dartsult.dart';
import 'package:dartsult/src/core.dart';
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
    onError: (error, stackTrace) =>
        Result.error<Void, MockException>(
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
  group('dartsult tests', () {
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
      expect(intErrRst.unwrapOrElse(() => 7), 7);
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
      expect(voidErrRst.unwrapOrElse(() => Void()), Void());
    });

    test('Test map', () {
      Result<int, String> x = Result.ok<int, String>(1);
      var v = x.map<String>((p0) => Result.ok('foo'));
      expect(v.unwrap(), 'foo');
    });

    test('test mapError', () async {
      var x = await intResult(true);
      expect(x.mapError((err) => err.msg).toString(), 'Error(${mock.msg})');
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
