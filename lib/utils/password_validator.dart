/// Password Validator Utility
/// Proper password validation ke liye yeh class use karein

class PasswordValidator {
  /// Minimum password length
  static const int minLength = 8;
  
  /// Maximum password length
  static const int maxLength = 128;
  
  /// Password validation result
  static PasswordValidationResult validatePassword(String password) {
    // Empty check
    if (password.isEmpty) {
      return PasswordValidationResult(
        isValid: false,
        errors: ['Password cannot be empty'],
        strength: PasswordStrength.weak,
      );
    }
    
    List<String> errors = [];
    int strengthScore = 0;
    
    // 1. Length check
    if (password.length < minLength) {
      errors.add('Password must be at least $minLength characters long');
    } else {
      strengthScore += 1;
      
      // Extra points for longer passwords
      if (password.length >= 12) {
        strengthScore += 1;
      }
      if (password.length >= 16) {
        strengthScore += 1;
      }
    }
    
    if (password.length > maxLength) {
      errors.add('Password must be less than $maxLength characters');
    }
    
    // 2. Uppercase letter check
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter (A-Z)');
    } else {
      strengthScore += 1;
    }
    
    // 3. Lowercase letter check
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter (a-z)');
    } else {
      strengthScore += 1;
    }
    
    // 4. Number check
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number (0-9)');
    } else {
      strengthScore += 1;
    }
    
    // 5. Special character check
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password must contain at least one special character (!@#\$%^&*)');
    } else {
      strengthScore += 1;
    }
    
    // 6. Common password check
    if (_isCommonPassword(password)) {
      errors.add('This password is too common. Please choose a stronger password');
      strengthScore = 0;
    }
    
    // 7. Sequential characters check (e.g., "1234", "abcd")
    if (_hasSequentialChars(password)) {
      errors.add('Password should not contain sequential characters (e.g., 1234, abcd)');
      strengthScore -= 1;
    }
    
    // 8. Repeated characters check (e.g., "1111", "aaaa")
    if (_hasRepeatedChars(password)) {
      errors.add('Password should not contain repeated characters (e.g., 1111, aaaa)');
      strengthScore -= 1;
    }
    
    // Determine strength
    PasswordStrength strength;
    if (strengthScore <= 2) {
      strength = PasswordStrength.weak;
    } else if (strengthScore <= 4) {
      strength = PasswordStrength.medium;
    } else if (strengthScore <= 6) {
      strength = PasswordStrength.strong;
    } else {
      strength = PasswordStrength.veryStrong;
    }
    
    return PasswordValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      strength: strength,
      strengthScore: strengthScore,
    );
  }
  
  /// Check if password is common/weak
  static bool _isCommonPassword(String password) {
    final commonPasswords = [
      'password',
      'password123',
      '12345678',
      '123456789',
      '1234567890',
      'qwerty',
      'abc123',
      'monkey',
      '1234567',
      'letmein',
      'trustno1',
      'dragon',
      'baseball',
      'iloveyou',
      'master',
      'sunshine',
      'ashley',
      'bailey',
      'passw0rd',
      'shadow',
      '123123',
      '654321',
      'superman',
      'qazwsx',
      'michael',
      'football',
      'welcome',
      'jesus',
      'ninja',
      'mustang',
      'password1',
      '123456',
      'admin',
      'root',
      'toor',
      'pass',
      'test',
      'guest',
      'info',
      'adm',
      'mysql',
      'user',
      'administrator',
      'oracle',
      'ftp',
      'pi',
      'puppet',
      'ansible',
      'ec2-user',
      'vagrant',
      'azureuser',
      'administrator',
      'root',
      'admin',
      'test',
      'guest',
      'info',
      'adm',
      'mysql',
      'user',
      'administrator',
      'oracle',
      'ftp',
      'pi',
      'puppet',
      'ansible',
      'ec2-user',
      'vagrant',
      'azureuser',
    ];
    
    return commonPasswords.contains(password.toLowerCase());
  }
  
  /// Check for sequential characters
  static bool _hasSequentialChars(String password) {
    // Check for numeric sequences
    for (int i = 0; i < password.length - 3; i++) {
      final char1 = password.codeUnitAt(i);
      final char2 = password.codeUnitAt(i + 1);
      final char3 = password.codeUnitAt(i + 2);
      final char4 = password.codeUnitAt(i + 3);
      
      // Check ascending sequence
      if (char2 == char1 + 1 && char3 == char2 + 1 && char4 == char3 + 1) {
        return true;
      }
      
      // Check descending sequence
      if (char2 == char1 - 1 && char3 == char2 - 1 && char4 == char3 - 1) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Check for repeated characters
  static bool _hasRepeatedChars(String password) {
    if (password.length < 4) return false;
    
    for (int i = 0; i < password.length - 3; i++) {
      final char = password[i];
      if (password[i + 1] == char && 
          password[i + 2] == char && 
          password[i + 3] == char) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Get password strength message
  static String getStrengthMessage(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.medium:
        return 'Medium strength password';
      case PasswordStrength.strong:
        return 'Strong password';
      case PasswordStrength.veryStrong:
        return 'Very strong password';
    }
  }
  
  /// Get password strength color (for UI)
  static int getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 0xFFFF0000; // Red
      case PasswordStrength.medium:
        return 0xFFFFA500; // Orange
      case PasswordStrength.strong:
        return 0xFF00FF00; // Green
      case PasswordStrength.veryStrong:
        return 0xFF008000; // Dark Green
    }
  }
  
  /// Calculate password entropy (measure of randomness)
  static double calculateEntropy(String password) {
    int poolSize = 0;
    
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) poolSize += 32;
    
    if (poolSize == 0) return 0;
    
    return password.length * (log(poolSize) / log(2));
  }
  
  static double log(num x) {
    return x > 0 ? (x / 2.302585092994046).clamp(0.0, double.infinity) : 0.0;
  }
}

/// Password validation result
class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;
  final PasswordStrength strength;
  final int strengthScore;
  
  PasswordValidationResult({
    required this.isValid,
    required this.errors,
    required this.strength,
    this.strengthScore = 0,
  });
  
  String get errorMessage => errors.join('\n');
}

/// Password strength levels
enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong,
}

/// Proper Password Requirements Summary:
/// 
/// ✅ MINIMUM REQUIREMENTS:
/// 1. At least 8 characters (better: 12+)
/// 2. At least one uppercase letter (A-Z)
/// 3. At least one lowercase letter (a-z)
/// 4. At least one number (0-9)
/// 5. At least one special character (!@#$%^&*)
/// 
/// ❌ SHOULD NOT CONTAIN:
/// 1. Common passwords (password, 123456, etc.)
/// 2. Sequential characters (1234, abcd)
/// 3. Repeated characters (1111, aaaa)
/// 4. Personal information (name, DOB, etc.)
/// 
/// 💡 BEST PRACTICES:
/// - Use 12-16 characters for better security
/// - Mix of letters, numbers, and symbols
/// - Avoid dictionary words
/// - Use passphrase instead of single word
/// - Don't reuse passwords across accounts
/// 
/// Example of GOOD passwords:
/// - "MyP@ssw0rd2024!" (12 chars, mixed case, numbers, symbols)
/// - "Tr0ub@dor&3" (11 chars, strong)
/// - "C0ffee!Te@2024" (14 chars, very strong)
/// 
/// Example of BAD passwords:
/// - "1234" (too short, only numbers)
/// - "password" (common word, no numbers/symbols)
/// - "11111111" (repeated characters)
/// - "abcd1234" (sequential characters)
