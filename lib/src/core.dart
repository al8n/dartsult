class Ok<T> {
  final T val;

  Ok(this.val);

  @override
  String toString() {
    return 'Ok(${val.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Ok && other.val == val;
  }

  @override
  int get hashCode => val.hashCode;
}

/// [Error] is
class Error {
  /// [error]
  final Object? error;

  /// [stackTrace] traces the call sequence that triggered an exception.
  final StackTrace? stackTrace;

  /// the parent error, default is null. e.g. [dart:io Error]
  ///
  /// ```dart
  /// import dart:io as io;
  ///
  /// Error err = Error(
  ///   error: someError,
  ///   stackTrace: someTrace,
  ///   from: Error(
  ///     error: io.IOException,
  ///     stackTrace: someTrace1,
  ///   ),
  /// );
  /// ```
  final Error? from;

  /// Default constructor
  const Error({
    required this.error,
    this.stackTrace,
    this.from,
  });

  @override
  String toString() {
    if (from != null) {
      return 'error: ${error?.toString()}\nfrom: ${from!.toString()}';
    }

    return <String, dynamic>{
      'error': error,
      'from': from,
    }.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Error && other.error == error && other.from == from;
  }

  @override
  int get hashCode => error.hashCode ^ from.hashCode;
}

/// Void is a class for function returns a void.
///
///
///
/// If you do not use `dartsult`:
/// ```dart
/// Future<void> foo() async {
///   return await bar().onError((error, stackTrace) => error);
/// }
///
/// Future<void> bar() async {
///   return;
/// }
/// ```
///
/// If use `dartsult`:
/// ```dart
/// Future<Result<Void, Error>> fooResult() async {
///   return await bar().then(
///     (value) => Result(ok: Void()),
///     onError: (error, stackTrace) => Result(
///       error: Error(
///         error: error,
///         stackTrace: stackTrace,
///       ),
///     ),
///   );
/// }
///
/// Future<void> bar() async {
///   return;
/// }
/// ```
class Void {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Void;
  }

  @override

  /// All [Void] instance should equal.
  int get hashCode => 0;
}

/// `Result` is a type that represents either success ([`ok`]) or failure ([`error`]).
class Result {
  /// Contains the success value
  final Ok? _ok;

  /// Contains the failure value
  final Error? _error;

  const Result({
    Ok? ok,
    Error? error,
  })  : _ok = ok,
        _error = error;

  /// Returns `true` if the result is [`ok`].
  bool isOk() => _ok != null;

  /// Returns `true` if the result is [`error`].
  bool isError() => _error != null;

  /// Returns `true` if the result is an [`ok`] value containing the given value.
  bool contains<T>(T instance) {
    if (_ok != null) {
      return Ok(instance) == _ok;
    }

    return false;
  }

  /// Returns `true` if the result is an [`error`] value containing the given value.
  bool containsError(Error err) {
    if (_error != null) {
      return err == _error;
    }

    return false;
  }

  /// Returns the contained [`ok`] value.
  ///
  /// Because this function may panic, its use is generally discouraged.
  /// Instead, prefer to use pattern matching and handle the [error]
  /// case explicitly, or call [unwrapOr] or [unwrapOrElse].
  T unwrap<T>() => _ok!.val;

  /// Returns the contained [error] value.
  Error unwrapError() => _error!;

  /// Returns the contained [`ok`] value or a provided default.
  ///
  /// Arguments passed to `unwrapOr` are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to use [unwrapOrElse],
  /// which is lazily evaluated.
  T unwrapOr<T>(T instance) => _ok != null ? _ok!.val : instance;

  /// Returns the contained [ok] value or computes it from a closure.
  T unwrapOrElse<T>(T Function() builder) => _ok != null ? _ok!.val : builder();
}
