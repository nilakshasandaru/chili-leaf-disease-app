import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.register(
          _userCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.mark_email_read_outlined,
                    color: AppColors.successGreen),
                SizedBox(width: 10),
                Text('Check your email'),
              ],
            ),
            content: const Text(
              'We sent a verification link to your email address. '
              'Open your email app, find the message from Chili Doctor, '
              'and tap the link inside it to activate your account. '
              'Then come back here and log in.',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('DEBUG REGISTER ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not reach the server: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                const Text('Chili Doctor',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyan,
                    )),
                const SizedBox(height: 8),
                const Text('Join the Community',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    )),
                const SizedBox(height: 6),
                const Text(
                  'Start identifying chili diseases with AI precision today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
                const SizedBox(height: 28),

                // Username
                _buildLabel('Username'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. farmer_john',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) => v!.isEmpty ? 'Username ඇතුළත් කරන්න' : null,
                ),
                const SizedBox(height: 16),

                // Email
                _buildLabel('Email Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'name@farm.com',
                    prefixIcon: Icon(Icons.mail_outline, size: 20),
                  ),
                  validator: (v) => v!.isEmpty ? 'Email ඇතුළත් කරන්න' : null,
                ),
                const SizedBox(height: 16),

                // Password
                _buildLabel('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    hintText: 'Create a strong password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textLight,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) => v!.length < 8
                      ? 'Minimum 8 characters'
                      : (!RegExp(r'[A-Za-z]').hasMatch(v))
                          ? 'Must include at least one letter'
                          : (!RegExp(r'[0-9]').hasMatch(v))
                              ? 'Must include at least one number'
                              : null,
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: AppColors.textLight),
                    SizedBox(width: 4),
                    Text('At least 8 characters, with letters and numbers',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildLabel('Confirm Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Repeat your password',
                    prefixIcon: const Icon(Icons.shield_outlined, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textLight,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) =>
                      v != _passCtrl.text ? 'Passwords match නැහැ' : null,
                ),
                const SizedBox(height: 28),

                // Create Account button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBtn,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style:
                            TextStyle(fontSize: 14, color: AppColors.textGrey)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      child: const Text('Login',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Terms
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    children: [
                      TextSpan(
                          text: 'By creating an account, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Align(
        alignment: Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            )),
      );
}