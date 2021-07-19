import 'package:meta/meta.dart';

/// [ResultType] represents the type of [Result].
///
/// [ok] representing success and containing a value.
///
/// [error] representing error and containing an error
enum ResultType {
  /// [ok] representing success and containing a value.
  ok,

  /// [error] representing error and containing an error value.
  error,
}

/// [_Ok], representing success and containing a value.
class _Ok<T> {
  final T? val;

  _Ok({this.val});

  @override
  String toString() {
    return 'Ok(${val?.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _Ok<T> && other.val == val;
  }

  @override
  int get hashCode => "Ok".hashCode + val.hashCode;
}

/// [_Error], representing error and containing an error value.
class _Error<E> {
  final E? val;

  /// Default constructor
  const _Error({this.val});

  @override
  String toString() {
    return 'Error(${val?.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _Error<E> && other.val == val;
  }

  @override
  int get hashCode => "Error".hashCode + val.hashCode;
}

/// Void is a class for function returns a void.
@immutable
class Void {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Void;
  }

  /// All [Void] instance should equal.
  @override
  int get hashCode => 0;
}

/// `Result` is a type that represents either success ([`ok`]) or failure ([`error`]).
@immutable
class Result<T, E> {
  final ResultType type;

  final dynamic rawValue;

  /// Contains the success value
  final _Ok<T> _ok;

  /// Contains the failure value
  final _Error<E> _error;

  const Result._({
    required _Ok<T> ok,
    required _Error<E> error,
    required this.type,
    required this.rawValue,
  })  : _ok = ok,
        _error = error;

  static Result<T, E> ok<T, E>(T val) {
    return Result._(
        ok: _Ok<T>(val: val),
        error: _Error<E>(),
        type: ResultType.ok,
        rawValue: val);
  }

  static Result<T, E> error<T, E>(E err) {
    return Result._(
        ok: _Ok<T>(),
        error: _Error<E>(val: err),
        type: ResultType.error,
        rawValue: err);
  }

  /// Returns `true` if the result is [ok].
  bool isOk() => type == ResultType.ok;

  /// Returns `true` if the result is [error].
  bool isError() => type == ResultType.error;

  /// Returns `true` if the result is an [`ok`] value containing the given value.
  bool contains(T val) {
    if (_ok.val != null) {
      return _Ok(val: val) == _ok;
    }

    return false;
  }

  /// Returns `true` if the result is an [`error`] value containing the given value.
  bool containsError(E err) {
    if (_error.val != null) {
      return _Error(val: err) == _error;
    }

    return false;
  }

  /// Returns the contained [ok] value.
  ///
  /// Because this function may panic, its use is generally discouraged.
  /// Instead, prefer to use pattern matching and handle the [error]
  /// case explicitly, or call [unwrapOr] or [unwrapOrElse].
  ///
  /// ## Example
  ///
  /// Basic Usage
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   Result<int, String> x = Result.ok(2);
  ///   assert(x.unwrap() == 2);
  ///
  ///   x = Result.error("emergency failure");
  ///   try {
  ///     x.unwrap();
  ///   } catch(e) {
  ///     assert(e.toString() == "Null check operator used on a null value");
  ///   }
  /// }
  /// ```
  T unwrap() => _ok.val!;

  /// Returns the contained [error] value.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   Result<int, String> x = Result.error("emergency failure");
  ///   assert(x.unwrapError() == "emergency failure");
  ///
  ///   x = Result.ok(2);
  ///   try {
  ///     x.unwrapError();
  ///   } catch (e) {
  ///     assert(e.toString() == "Null check operator used on a null value");
  ///   }
  /// }
  /// ```
  E unwrapError() => _error.val!;

  /// Returns the contained [ok] value or a provided default.
  ///
  /// Arguments passed to [unwrapOr] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to use [unwrapOrElse],
  /// which is lazily evaluated.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   int defaultt = 2;
  ///   Result<int, String> x = Result.ok(9);
  ///   assert(x.unwrapOr(defaultt) == 9);
  ///
  ///   x = Result.error("error");
  ///   assert(x.unwrapOr(defaultt) == defaultt);
  /// }
  /// ```
  T unwrapOr(T instance) => _ok.val != null ? _ok.val! : instance;

  /// Returns the contained [ok] value or computes it from a closure.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   int count(String x) {
  ///     return x.length;
  ///   }
  ///
  ///   assert(Result.ok<int, String>(2).unwrapOrElse(count) == 2);
  ///   assert(Result.error<int, String>("foo").unwrapOrElse(count) == 3);
  /// }
  /// ```
  T unwrapOrElse(T Function(E err) op) =>
      _ok.val != null ? _ok.val! : op(_error.val!);

  /// Maps a `Result<T, E>` to `Result<U, E>` by applying a function to a
  /// contained [ok] value, leaving an [error] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  ///
  /// ## Example
  ///
  /// Basic Usage
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   String stringify(int x) {
  ///     return 'code: $x';
  ///   }
  ///
  ///   Result<int, String> x = Result.ok<int, String>(13);
  ///   assert(x.map(stringify) == Result.ok<String, String>('code: 13'));
  /// }
  /// ```
  Result<U, E> map<U>(U Function(T val) op) {
    if (_ok.val != null) {
      return Result.ok(op(_ok.val!));
    }
    return Result.error(_error.val!);
  }

  /// Maps a `Result<T, E>` to `Result<T, F>` by applying a function to a
  /// contained [error] value, leaving an [ok] value untouched.
  ///
  /// This function can be used to pass through a successful result while handling
  /// an error.
  ///
  /// ## Example
  ///
  /// Basic Usage
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   String stringify(int x) {
  ///     return 'error code: $x';
  ///   }
  ///
  ///   Result<int, int> x = Result.ok(2);
  ///   assert(x.mapError(stringify) == Result.ok<int, String>(2));
  ///
  ///   x = Result.error(13);
  ///   assert(x.mapError(stringify) == Result.error<int, String>("error code: 13"));
  /// }
  /// ```
  Result<T, F> mapError<F>(F Function(E err) op) {
    if (_ok.val != null) {
      return Result.ok(_ok.val!);
    }
    return Result.error(op(_error.val!));
  }

  /// Returns the provided default (if [error]), or
  /// applies a function to the contained value (if [ok]),
  ///
  /// Arguments passed to `map_or` are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to use [mapOrElse],
  /// which is lazily evaluated.
  ///
  /// ## Example
  ///
  /// Basic Usage
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   Result<dynamic, String> x = Result.ok<dynamic, String>("foo");
  ///   int val = x.mapOr<int>(42, (v) => v.length);
  ///   assert(val == 3);
  ///
  ///   Result<String, dynamic> y = Result.error<String, dynamic>("bar");
  ///   int val1 = y.mapOr<int>(42, (v) => v.length);
  ///   assert(val1 == 42);
  /// }
  /// ```
  U mapOr<U>(U defaultt, U Function(T val) op) {
    if (_ok.val != null) {
      return op(_ok.val!);
    }
    return defaultt;
  }

  /// Maps a `Result<T, E>` to `U` by applying a fallback function to a
  /// contained [error] value, or a default function to a
  /// contained [ok] value.
  ///
  /// This function can be used to unpack a successful result
  /// while handling an error.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   int k = 21;
  ///
  ///   Result<dynamic, String> x = Result.ok<dynamic, String>("foo");
  ///   int val = x.mapOrElse<int>((v) => k * 2, (v) => v.length);
  ///   assert(val == 3);
  ///
  ///   Result<String, dynamic> y = Result.error<String, dynamic>("bar");
  ///   int val1 = y.mapOrElse<int>((v) => k * 2, (v) => v.length);
  ///   assert(val1 == 42);
  /// }
  /// ```
  U mapOrElse<U>(U Function(E err) defaultt, U Function(T val) op) {
    if (_ok.val != null) {
      return op(_ok.val!);
    }
    return defaultt(_error.val!);
  }

  /// Returns `res` if the result is [ok], otherwise returns the [error] value of class.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   Result<int, String> x = Result.ok(2);
  ///   Result<String,String> y = Result.error("late error");
  ///
  ///   assert(x.and(y) == Result.error<String, String>("late error"));
  ///
  ///   x = Result.error("early error");
  ///   y = Result.ok("foo");
  ///   assert(x.and(y) == Result.error<String, String>("early error"));
  ///
  ///   x = Result.error("not a 2");
  ///   y = Result.error("late error");
  ///   assert(x.and(y) == Result.error<String, String>("not a 2"));
  ///
  ///   x = Result.ok(2);
  ///   y = Result.ok("different result type");
  ///   assert(x.and(y) == Result.ok<String, String>("different result type"));
  /// }
  /// ```
  Result<U, E> and<U>(Result<U, E> res) {
    if (_error.val != null) {
      return Result.error(_error.val!);
    }
    return res;
  }

  /// Calls `op` if the result is [`Ok`], otherwise returns the [`Err`] value of `self`.
  ///
  ///
  /// This function can be used for control flow based on `Result` values.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// Result<int, int> sq(int x) {
  ///   return Result.ok(x * x);
  /// }
  ///
  /// Result<int, int> err(int x) {
  ///   return Result.error(x);
  /// }
  ///
  /// main() {
  ///   assert(Result.ok<int, int>(2).andThen(sq).andThen(sq) == Result.ok<int, int>(16));
  ///   assert(Result.ok<int, int>(2).andThen(sq).andThen(err) == Result.error<int, int>(4));
  ///   assert(Result.ok<int, int>(2).andThen(err).andThen(sq) == Result.error<int, int>(2));
  ///   assert(Result.error<int, int>(3).andThen(sq).andThen(sq) == Result.error<int, int>(3));
  /// }
  /// ```
  Result<U, E> andThen<U>(Result<U, E> Function(T val) op) {
    if (_ok.val != null) {
      return op(_ok.val!);
    }
    return Result.error(_error.val!);
  }

  /// Returns `res` if the result is [error], otherwise returns the [ok] value of class.
  ///
  /// Arguments passed to `or` are eagerly evaluated; if you are passing the
  /// result of a function call, it is recommended to use [orElse], which is
  /// lazily evaluated.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   Result<int, String> x = Result.ok(2);
  ///   Result<int, String> y = Result.error("late error");
  ///   assert(x.or(y) == Result.ok<int, String>(2));
  ///
  ///   x = Result.error("early error");
  ///   y = Result.ok(2);
  ///   assert(x.or(y) == Result.ok<int, String>(2));
  ///
  ///   x = Result.ok(2);
  ///   y = Result.ok(100);
  ///   assert(x.or(y) == Result.ok<int, String>(2));
  /// }
  /// ```
  Result<T, F> or<F>(Result<T, F> res) {
    if (_ok.val != null) {
      return Result.ok(_ok.val!);
    }

    return res;
  }

  /// Calls `op` if the result is [error], otherwise returns the [ok] value of class`.
  ///
  /// This function can be used for control flow based on result values.
  ///
  /// ## Example
  ///
  /// Basic Usage:
  ///
  /// ```dart
  /// import 'package:dartsult/dartsult.dart';
  ///
  /// main() {
  ///   Result<int, int> sq(int x) {
  ///     return Result.ok(x * x);
  ///   }
  ///
  ///   Result<int, int> err(int x) {
  ///     return Result.error(x);
  ///   }
  ///
  ///   assert(Result.ok<int, int>(2).orElse(sq).orElse(sq) == Result.ok<int, int>(2));
  ///   assert(Result.ok<int, int>(2).orElse(err).orElse(sq) == Result.ok<int, int>(2));
  ///   assert(Result.error<int, int>(3).orElse(sq).orElse(err) == Result.ok<int, int>(9));
  ///   assert(Result.error<int, int>(3).orElse(err).orElse(err) == Result.error<int, int>(3));
  /// }
  /// ```
  Result<T, F> orElse<F>(Result<T, F> Function(E err) op) {
    if (_ok.val != null) {
      return Result.ok(_ok.val!);
    }
    return op(_error.val!);
  }

  @override
  int get hashCode {
    switch (type) {
      case ResultType.ok:
        return _ok.hashCode;
      case ResultType.error:
        return _error.hashCode;
    }
  }

  @override
  String toString() {
    switch (type) {
      case ResultType.ok:
        return _ok.toString();
      case ResultType.error:
        return _error.toString();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    if (other is Result<T, E>) {
      if (type != other.type) {
        return false;
      }
      return rawValue == other.rawValue;
    }

    return false;
  }
}
