# dartsult
`dartsult` is a library for developers who want to handle error in Rust style.

## Usage

A simple usage example:

```dart
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
  // TODO: implement hashCode
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
          stackTrace: stackTrace,
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
      stackTrace: stackTrace,
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

void main() async {

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
  assert(intErrRst.unwrapOrElse(() => 7) == 7);

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
  assert(voidErrRst.unwrapOrElse(() => Void()) == Void());
}
```

## TODO
1. Implements `Option` class

2. Implements below methods for `Result`
    - [ ] `Option<T> ok()` 
    - [ ] `Option<E> err()`
    - [ ] `or`
    - [ ] `or_else`
    - [ ] `and` 
    - [ ] `and_then`
    - [ ] `iter`
