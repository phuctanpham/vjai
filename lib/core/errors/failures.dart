/// Base failure class for application errors.
abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Represents failure during server communication.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.', super.cause]);
}

/// Represents network connectivity failures.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable.', super.cause]);
}

/// Represents cache or local storage errors.
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed.', super.cause]);
}

