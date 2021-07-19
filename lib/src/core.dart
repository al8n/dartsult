import 'package:meta/meta.dart';

enum ResultType {
  ok,
  error,
}

/// [Ok(T)], representing success and containing a value.
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

/// [Error(E)], representing error and containing an error value.
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
    return Result._(ok: _Ok<T>(val: val), error: _Error<E>(), type: ResultType.ok, rawValue: val);
  }

  static Result<T, E> error<T, E>(E err) {
    return Result._(ok: _Ok<T>(), error: _Error<E>(val: err), type: ResultType.error, rawValue: err);
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
  T unwrap() => _ok.val!;

  /// Returns the contained [error] value.
  E unwrapError() => _error.val!;

  /// Returns the contained [`ok`] value or a provided default.
  ///
  /// Arguments passed to `unwrapOr` are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to use [unwrapOrElse],
  /// which is lazily evaluated.
  T unwrapOr(T instance) => _ok.val != null ? _ok.val! : instance;

  /// Returns the contained [ok] value or computes it from a closure.
  T unwrapOrElse(T Function() builder) => _ok.val != null ? _ok.val! : builder();

  /// Maps a `Result<T, E>` to `Result<U, E>` by applying a function to a
  /// contained [ok] value, leaving an [error] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  Result<U, E> map<U>(Result<U, E> Function(T) op) {
    if (_ok.val != null) {
      return op(_ok.val!);
    }
    return Result.error(_error.val!);
  }

  /// Maps a `Result<T, E>` to `Result<T, F>` by applying a function to a
  /// contained [error] value, leaving an [ok] value untouched.
  ///
  /// This function can be used to pass through a successful result while handling
  /// an error.
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
  U mapOr<U>(U defaultt, U Function(T) op) {
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
  U mapOrElse<U>(U Function(E err) defaultt, U Function(T val) op) {
    if (_ok.val != null) {
      return op(_ok.val!);
    }
    return defaultt(_error.val!);
  }

  @override
  int get hashCode {
    switch(type) {
      case ResultType.ok:
        return _ok.hashCode;
      case ResultType.error:
        return _error.hashCode;
    }
  }

  @override
  String toString() {
    switch (type){
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
