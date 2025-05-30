import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/settings_widgets/auth_subtitle_widget.dart';
import '../../widgets/settings_widgets/auth_title_widget.dart';
import '../../widgets/settings_widgets/input_field_widget.dart';
import 'otp_verify_screen.dart';

class EmailRecoveryScreen extends StatefulWidget {
  final String? email;

  const EmailRecoveryScreen({super.key, this.email});

  @override
  State<EmailRecoveryScreen> createState() => _EmailRecoveryScreenState();
}

class _EmailRecoveryScreenState extends State<EmailRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Email Verify',
        onBackPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthTitleWidget(title: 'Enter your\nEmail'),
              const SizedBox(height: 44),
              const AuthSubtitleWidget(
                normalText: 'Please enter your ',
                highlightedText: 'Email',
              ),
              const SizedBox(height: 32),
              AuthInputField(
                controller: _emailController,
                labelText: 'Enter email*',
                hintText: 'abc@abc.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const Spacer(),
              CustomGradientButton(
                text: 'Enter',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OtpVerifyScreen(
                          email: _emailController.text,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}