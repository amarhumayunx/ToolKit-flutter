import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_exceptions.dart';
import 'app_logger.dart';
import 'app_snackbar.dart';

/// Centralized error handling service
/// Provides consistent error handling across the app
class ErrorHandler {
  /// Handle error and show appropriate user message
  static Future<void> handleError(
    BuildContext? buildContext,
    Object error, {
    String? operationContext,
    StackTrace? stackTrace,
    bool showToUser = true,
    String? userMessage,
  }) async {
    final appException = ExceptionHandler.handleException(
      error,
      context: operationContext,
      stackTrace: stackTrace,
    );

    // Log the error
    AppLogger.error(
      'Error in ${operationContext ?? "unknown"}: ${appException.message}',
      tag: operationContext ?? 'ErrorHandler',
      error: appException.originalError ?? error,
      stackTrace: appException.stackTrace ?? stackTrace,
      additionalData: {
        'code': appException.code,
        'message': appException.message,
      },
    );

    // Show user-friendly message if requested
    if (showToUser) {
      final message = userMessage ?? _getUserFriendlyMessage(appException);
      if (buildContext != null) {
        AppSnackBar.show(
          buildContext,
          message: message,
        );
      } else if (Get.context != null) {
        AppSnackBar.show(
          Get.context!,
          message: message,
        );
      }
    }
  }

  /// Get user-friendly error message from exception
  static String _getUserFriendlyMessage(AppException exception) {
    // Try to get localized message
    try {
      if (exception is AuthenticationException) {
        if (exception.code == 'invalid-phone-number') {
          return 'invalid_phone_number'.tr;
        } else if (exception.code == 'too-many-requests') {
          return 'too_many_requests'.tr;
        } else if (exception.code == 'wrong-password') {
          return 'wrong_password'.tr;
        }
        return 'auth_error'.tr;
      }

      if (exception is FileOperationException) {
        if (exception.code == 'file-not-found') {
          return 'file_not_found'.tr;
        } else if (exception.code == 'permission-denied') {
          return 'permission_denied_open_file'.tr;
        } else if (exception.code == 'disk-full') {
          return 'insufficient_storage'.tr;
        }
        return 'file_operation_failed'.tr;
      }

      if (exception is EncryptionException) {
        return 'encryption_error'.tr;
      }

      if (exception is PermissionException) {
        return 'permission_denied_open_file'.tr;
      }

      if (exception is NetworkException) {
        if (exception.statusCode == 404) {
          return 'network_error_not_found'.tr;
        } else if (exception.statusCode == 401 || exception.statusCode == 403) {
          return 'network_error_unauthorized'.tr;
        } else if (exception.statusCode == 500) {
          return 'network_error_server'.tr;
        }
        return 'network_error'.tr;
      }

      if (exception is ValidationException) {
        return exception.message;
      }

      // Generic error
      return 'unknown_error'.tr;
    } catch (e) {
      // Fallback to English if translation fails
      return exception.message;
    }
  }

  /// Handle error silently (only log, no UI feedback)
  static void handleErrorSilently(
    Object error, {
    String? operationContext,
    StackTrace? stackTrace,
  }) {
    handleError(
      null,
      error,
      operationContext: operationContext,
      stackTrace: stackTrace,
      showToUser: false,
    );
  }

  /// Handle error with retry callback
  static Future<T?> handleErrorWithRetry<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? operationName,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        attempts++;
        
        if (attempts >= maxRetries) {
          await handleError(
            context,
            error,
            operationContext: operationName ?? 'Operation',
            stackTrace: stackTrace,
          );
          return null;
        }

      AppLogger.warning(
        'Operation failed, retrying ($attempts/$maxRetries)',
        'ErrorHandler',
      );

        await Future.delayed(retryDelay);
      }
    }
    
    return null;
  }

  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? buttonText,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }
}
