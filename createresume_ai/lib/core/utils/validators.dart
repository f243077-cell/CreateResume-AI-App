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

  /// Optional phone number: empty is fine, otherwise 7-20 characters of
  /// digits, spaces and + - ( ) . with at least 7 digits.
  static String? optionalPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final digits = text.replaceAll(RegExp(r'\D'), '').length;
    if (!RegExp(r'^\+?[\d\s\-().]{7,20}$').hasMatch(text) || digits < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Optional web address: empty is fine; the scheme may be omitted
  /// (e.g. "linkedin.com/in/name").
  static String? optionalUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final regex = RegExp(r'^(https?://)?[\w-]+(\.[\w-]+)+(/\S*)?$', caseSensitive: false);
    if (!regex.hasMatch(text)) {
      return 'Enter a valid link, e.g. linkedin.com/in/your-name';
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
