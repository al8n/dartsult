<div align="center">
<h1>dartsult</h1>
</div>
<div align="center">

`dartsult` is a library for developers who want to handle error in Rust style.

English | [简体中文](README-zh_CN.md)

[<img alt="github" src="https://img.shields.io/badge/GITHUB-dartsult-8da0cb?style=for-the-badge&logo=Github" height="22">][Github-url]
[<img alt="pub package" src="https://img.shields.io/pub/v/dartsult.svg?style=for-the-badge&logo=dart&color=5ab5f0" height="22">][package-url]

[<img alt="Build" src="https://img.shields.io/badge/Build-passing-brightgreen?style=for-the-badge&logo=Github-Actions" height="22">][CI-url]
[<img alt="codecov" src="https://img.shields.io/codecov/c/gh/al8n/dartsult?style=for-the-badge&logo=codecov" height="22">][codecov-url]

[<img alt="lisence" src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge&logo=Apache" height="22">][license-url]



</div>

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
    - [ ] `iter`
   
3. Implements `Either` class

#### License

<sup>
Licensed under <a href="LICENSE">Apache License, Version
2.0</a>.
</sup>
<br>
<sub>
Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in this crate by you, as defined in the Apache-2.0 license.
</sub>

[Github-url]: https://github.com/al8n/dartsult/
[CI-url]: https://github.com/al8n/dartsult
[codecov-url]: https://app.codecov.io/gh/al8n/dartsult/
[license-url]: LICENSE
[package-url]: https://pub.dartlang.org/packages/dartsult 