import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/password_validator.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final PasswordStrength strength;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    Color color;
    String text;
    double width;
    Color backgroundColor;

    switch (strength) {
      case PasswordStrength.weak:
        color = Colors.red;
        text = 'Weak';
        width = 0.25;
        backgroundColor = Colors.red.shade100;
        break;
      case PasswordStrength.medium:
        color = Colors.orange;
        text = 'Medium';
        width = 0.5;
        backgroundColor = Colors.orange.shade100;
        break;
      case PasswordStrength.strong:
        color = Colors.green;
        text = 'Strong';
        width = 0.75;
        backgroundColor = Colors.green.shade100;
        break;
      case PasswordStrength.veryStrong:
        color = Colors.green.shade700;
        text = 'Very Strong';
        width = 1.0;
        backgroundColor = Colors.green.shade100;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: width,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PasswordRequirementsChecklist extends StatelessWidget {
  final String password;

  const PasswordRequirementsChecklist({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('At least 8 characters', hasMinLength),
          const SizedBox(height: 4),
          _buildRequirement('One uppercase letter (A-Z)', hasUppercase),
          const SizedBox(height: 4),
          _buildRequirement('One lowercase letter (a-z)', hasLowercase),
          const SizedBox(height: 4),
          _buildRequirement('One number (0-9)', hasNumber),
          const SizedBox(height: 4),
          _buildRequirement('One special character (!@#\$%^&*)', hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.grey.shade400,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: isValid ? Colors.green.shade700 : Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
