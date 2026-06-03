import 'package:balance_sheet_ledger/services/backend_api.dart';
import 'package:balance_sheet_ledger/state/auth_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_theme.dart';
import '../widgets/brand_identity.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _api = BackendApi();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _agreeToTerms = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }

    if (name.length < 2) {
      setState(() => _error = 'Name must be at least 2 characters.');
      return;
    }

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      setState(() => _error = 'Please enter a password.');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    if (!_agreeToTerms) {
      setState(() =>
          _error = 'Please agree to the Terms of Service and Privacy Policy.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final result = await _api.register(
        name: name,
        email: email,
        password: password,
      );
      if (mounted) {
        await context.read<AuthCubit>().authenticate(result, rememberMe: true);
        if (!mounted) {
          return;
        }
        context.go(_nextRouteAfterSignup(context));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = _getUserFriendlyError(error.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  String _getUserFriendlyError(String error) {
    if (error.toLowerCase().contains('email already exists') ||
        error.toLowerCase().contains('already registered')) {
      return 'This email is already registered. Please login instead.';
    } else if (error.toLowerCase().contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (error.toLowerCase().contains('weak password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppThemes.financeGold : AppThemes.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(theme, isDark, primaryColor),
        tablet: _buildTabletLayout(theme, isDark, primaryColor),
        desktop: _buildDesktopLayout(theme, isDark, primaryColor),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, bool isDark, Color primaryColor) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, isDark, primaryColor),
            const SizedBox(height: 30),
            _buildSignUpForm(theme, isDark, primaryColor),
            const SizedBox(height: 24),
            _buildFooter(theme, isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme, bool isDark, Color primaryColor) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, isDark, primaryColor),
              const SizedBox(height: 40),
              _buildSignUpForm(theme, isDark, primaryColor),
              const SizedBox(height: 32),
              _buildFooter(theme, isDark, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, bool isDark, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [primaryColor.withOpacity(0.15), Colors.transparent]
                    : [primaryColor.withOpacity(0.08), Colors.transparent],
              ),
            ),
            child: _buildHeroSection(theme, isDark, primaryColor),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme, isDark, primaryColor),
                    const SizedBox(height: 40),
                    _buildSignUpForm(theme, isDark, primaryColor),
                    const SizedBox(height: 32),
                    _buildFooter(theme, isDark, primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isDark, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            child: LedgerBrandLockup(
              logoSize: 128,
              titleSize: 34,
              subtitleSize: 13,
              center: true,
              titleColor: theme.colorScheme.onSurface,
              subtitleColor: primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Join Ledger',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Create your account and start managing your crypto assets securely',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSecurityBadges(theme, isDark, primaryColor),
          const SizedBox(height: 36),
          const DhinadtsCompanyMark(height: 76, center: true),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: LedgerBrandLockup(
            logoSize: 46,
            titleSize: 19,
            subtitleSize: 9,
            dense: true,
            titleColor: theme.colorScheme.onSurface,
            subtitleColor: primaryColor,
          ),
        ),
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: primaryColor,
          ),
          onPressed: AppThemeController.toggleTheme,
        ),
      ],
    );
  }

  Widget _buildSignUpForm(ThemeData theme, bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get started with your free account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),

        // Error message display
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Name field
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'John Doe',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? AppThemes.darkPanel : Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 20),

        // Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'hello@ledger.com',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? AppThemes.darkPanel : Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 20),

        // Password field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a strong password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            helperText: 'Minimum 6 characters',
            helperStyle: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? AppThemes.darkPanel : Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 20),

        // Confirm Password field
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            prefixIcon: const Icon(Icons.verified_user_outlined, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? AppThemes.darkPanel : Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 24),

        // Terms and Conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() => _agreeToTerms = value ?? false);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Sign Up button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: _isSubmitting
              ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                )
              : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor:
                        isDark ? AppThemes.darkBackground : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  child: const Text('CREATE ACCOUNT'),
                ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, bool isDark, Color primaryColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: theme.textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSecurityNote(theme, isDark, primaryColor),
      ],
    );
  }

  Widget _buildSecurityBadges(
      ThemeData theme, bool isDark, Color primaryColor) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildBadge(
            Icons.shield_outlined, '256-bit SSL', theme, isDark, primaryColor),
        _buildBadge(
            Icons.verified_outlined, '2FA Secure', theme, isDark, primaryColor),
        _buildBadge(Icons.fingerprint_outlined, 'Biometric', theme, isDark,
            primaryColor),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, ThemeData theme, bool isDark,
      Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote(ThemeData theme, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkPanel : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_outlined,
            size: 20,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your information is protected with bank-grade encryption',
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _nextRouteAfterSignup(BuildContext context) {
  if (kIsWeb || MediaQuery.sizeOf(context).shortestSide >= 600) {
    return '/dashboard';
  }

  return '/bank-details';
}

// Responsive layout helper (same as login screen)
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return desktop;
    } else if (width >= 600) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
