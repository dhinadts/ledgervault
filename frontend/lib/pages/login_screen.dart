import 'package:balance_sheet_ledger/state/app_providers.dart';
import 'package:balance_sheet_ledger/state/auth_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../services/bank_account_setup_session.dart';
import '../widgets/brand_identity.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    ref
        .read(loginFormProvider.notifier)
        .setRememberMe(prefs.getBool('ledger_remember_session') ?? true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (email.isEmpty) {
      ref
          .read(loginFormProvider.notifier)
          .setError('Please enter your email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      ref
          .read(loginFormProvider.notifier)
          .setError('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      ref
          .read(loginFormProvider.notifier)
          .setError('Please enter your password.');
      return;
    }

    if (password.length < 6) {
      ref
          .read(loginFormProvider.notifier)
          .setError('Password must be at least 6 characters.');
      return;
    }

    final form = ref.read(loginFormProvider);
    final result = await ref.read(loginFormProvider.notifier).submit(
          email: email,
          password: password,
        );
    if (!mounted || result == null) {
      if (result == null) {
        final error = ref.read(loginFormProvider).error;
        ref
            .read(loginFormProvider.notifier)
            .setError(_getUserFriendlyError(error ?? ''));
      }
      return;
    }

    await context.read<AuthCubit>().authenticate(
          result,
          rememberMe: form.rememberMe,
        );
    if (!mounted) {
      return;
    }
    context.go(_nextRouteAfterLogin(context));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  String _getUserFriendlyError(String error) {
    if (error.toLowerCase().contains('invalid credentials') ||
        error.toLowerCase().contains('invalid email') ||
        error.toLowerCase().contains('wrong password')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('xmlhttprequest')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (error.toLowerCase().contains('user not found')) {
      return 'No account found with this email address.';
    }
    return 'Login failed. Please check your credentials and try again.';
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
            const SizedBox(height: 40),
            _buildLoginForm(theme, isDark, primaryColor),
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
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, isDark, primaryColor),
              const SizedBox(height: 48),
              _buildLoginForm(theme, isDark, primaryColor),
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme, isDark, primaryColor),
                    const SizedBox(height: 48),
                    _buildLoginForm(theme, isDark, primaryColor),
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
            'Secure Ledger',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Manage your crypto assets with enterprise-grade security',
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

  Widget _buildLoginForm(ThemeData theme, bool isDark, Color primaryColor) {
    final form = ref.watch(loginFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to access your ledger',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),

        // Error message display
        if (form.error != null) ...[
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
                    form.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

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
          obscureText: form.obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                form.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () =>
                  ref.read(loginFormProvider.notifier).togglePasswordVisibility(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? AppThemes.darkPanel : Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),

        // Remember me & Forgot password
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: form.rememberMe,
                    onChanged: (value) async {
                      ref
                          .read(loginFormProvider.notifier)
                          .setRememberMe(value ?? false);
                      // Save preference immediately
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(
                          'ledger_remember_session', value ?? false);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Navigate to forgot password screen
                context.go('/forgot-password');
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: form.isSubmitting
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
                  child: const Text('LOGIN'),
                ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, bool isDark, Color primaryColor) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'New user?',
              style: theme.textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                context.go('/signup');
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
              child: const Text(
                'Create account',
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
              'Your data is encrypted with bank-grade security',
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

String _nextRouteAfterLogin(BuildContext context) {
  if (kIsWeb || MediaQuery.sizeOf(context).shortestSide >= 600) {
    return '/dashboard';
  }

  return BankAccountSetupSession.isComplete ? '/dashboard' : '/bank-details';
}

// Responsive layout helper
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
