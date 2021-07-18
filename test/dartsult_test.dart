import 'package:dartsult/dartsult.dart';
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
  // TODO: implement hashCode
  int get hashCode => msg.hashCode;
}

Future<Result> voidResult(bool shouldPanic) async {
  return await mockLogic(null, 'cannot get void value',
          shouldPanic: shouldPanic)
      .then(
    (value) => Result(ok: Ok(Void())),
    onError: (error, stackTrace) =>
        Result(error: Error(error: error, stackTrace: stackTrace)),
  );
}

Future<Result> intResult(bool shouldPanic) async {
  return await mockLogic<int>(5, 'cannot get int value',
          shouldPanic: shouldPanic)
      .then(
    (value) => Result(ok: Ok(value)),
    onError: (error, stackTrace) => Result(
      error: Error(error: error, stackTrace: stackTrace),
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
    Error expectErr = Error(error: MockException('cannot get int value'));

    Error expectErr1 = Error(error: MockException('cannot get void value'));

    Error expectErr2 = Error(error: MockException('from another error'), from: expectErr1);

    test('Test int result with ok', () async {
      Result intRst = await intResult(false);
      expect(intRst.isOk(), true);
      expect(intRst.unwrap(), 5);
      expect(intRst.contains(5), true);
      expect(intRst.contains(6), false);
    });

    test('Test int result with error', () async {
      Result intErrRst = await intResult(true);
      expect(intErrRst.isError(), true);
      expect(intErrRst.unwrapError().error.toString(),
          'MockException(cannot get int value)');
      expect(intErrRst.containsError(expectErr), true);
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
      expect(voidErrRst.unwrapError().error.toString(),
          'MockException(cannot get void value)');
      expect(voidErrRst.containsError(expectErr1), true);
      expect(voidErrRst.unwrapOr(Void()), Void());
      expect(voidErrRst.unwrapOrElse(() => Void()), Void());
    });

    test('Test to String', () async {
      expect(expectErr1.toString(), '{error: MockException(cannot get void value), from: null}');
      expect(expectErr2.toString(), '{error: MockException(from another error), from: {error: MockException(cannot get void value), from: null}}');
    });
  });
}
