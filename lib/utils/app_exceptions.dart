/// Base exception class for app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when file operations fail
class FileOperationException extends AppException {
  final String? filePath;

  const FileOperationException(
    super.message, {
    this.filePath,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (filePath != null) {
      return '$message (File: $filePath)';
    }
    return message;
  }
}

/// Exception thrown when encryption/decryption fails
class EncryptionException extends FileOperationException {
  final String? operation;

  const EncryptionException(
    super.message, {
    this.operation,
    super.filePath,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (operation != null) {
      buffer.write(' (Operation: $operation)');
    }
    if (filePath != null) {
      buffer.write(' (File: $filePath)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return '$message (Status: $statusCode)';
    }
    return message;
  }
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  final String? permissionType;

  const PermissionException(
    super.message, {
    this.permissionType,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (permissionType != null) {
      return '$message (Permission: $permissionType)';
    }
    return message;
  }
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final String? field;

  const ValidationException(
    super.message, {
    this.field,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (field != null) {
      return '$message (Field: $field)';
    }
    return message;
  }
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Helper to convert common exceptions to AppException
class ExceptionHandler {
  static AppException handleException(
    Object error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    if (error is AppException) {
      return error;
    }

    final errorMessage = error.toString();
    final contextPrefix = context != null ? '[$context] ' : '';

    // Handle common error types
    if (error is FormatException) {
      return ValidationException(
        '${contextPrefix}Invalid format: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is ArgumentError) {
      return ValidationException(
        '${contextPrefix}Invalid argument: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error.toString().contains('Permission')) {
      return PermissionException(
        '${contextPrefix}Permission denied: $errorMessage',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error.toString().contains('Network') || error.toString().contains('socket')) {
      return NetworkException(
        '${contextPrefix}Network error: $errorMessage',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Generic exception - use a concrete type
    if (error.toString().contains('File') || error.toString().contains('file')) {
      return FileOperationException(
        '${contextPrefix}An error occurred: $errorMessage',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Default to AuthenticationException for auth-related, otherwise FileOperationException
    return FileOperationException(
      '${contextPrefix}An error occurred: $errorMessage',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
