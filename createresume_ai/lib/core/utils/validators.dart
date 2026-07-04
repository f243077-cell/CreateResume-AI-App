/// Form field validators for CreateResume AI.
///
/// Each returns `null` on valid input, or an error message string.
abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w\-.+]+@[\w\-]+\.[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Generic required-field validator.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Enforces a maximum character length.
  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must be $max characters or fewer';
    }
    return null;
  }

  /// Ensures [end] is after [start].
  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }
    return null;
  }
}
