/// Input validation utilities.
///
/// Pure functions for validating user inputs across the application.
/// Used in forms, URL scanning, and password checking.
library;

class Validators {
  Validators._();

  /// Validate email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validate URL format.
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      // Try adding https://
      final withScheme = Uri.tryParse('https://$trimmed');
      if (withScheme == null || withScheme.host.isEmpty) {
        return 'Please enter a valid URL';
      }
    }
    return null;
  }

  /// Validate non-empty field.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number (basic).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\+?[\d\s-]{10,15}$').hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate confirm password.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Calculate password strength score (0-100).
  static int passwordStrengthScore(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // Length scoring
    if (password.length >= 8) score += 15;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;
    if (password.length >= 20) score += 5;

    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 15;

    // Pattern penalties
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score -= 10; // Repeated chars
    if (RegExp(r'(012|123|234|345|456|567|678|789)')
        .hasMatch(password)) {
      score -= 10; // Sequential digits
    }
    if (_commonPasswords.contains(password.toLowerCase())) {
      score = 5; // Common password
    }

    // Entropy bonus
    final uniqueChars = password.split('').toSet().length;
    score += (uniqueChars / password.length * 15).round();

    return score.clamp(0, 100);
  }

  /// Common passwords list (abbreviated — expand in production).
  static final Set<String> _commonPasswords = {
    'password', '123456', '12345678', 'qwerty', 'abc123',
    'monkey', 'master', 'dragon', 'letmein', 'login',
    'princess', 'admin', 'welcome', 'shadow', 'sunshine',
    'trustno1', 'iloveyou', 'batman', 'football', 'charlie',
    'password1', 'password123', 'qwerty123', '1234567890',
  };
}
