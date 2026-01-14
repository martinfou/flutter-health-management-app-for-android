// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/providers/auth_provider.dart';
import 'package:health_app/core/utils/validation_utils.dart';
import 'package:health_app/core/utils/google_sign_in_button_util.dart';
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// Registration page for new user signup
class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Create a minimal UserProfile from AuthUser with default values
  UserProfile _createProfileFromAuthUser(AuthUser user) {
    final now = DateTime.now();
    final dateOfBirth = DateTime(now.year - 30, now.month, now.day);

    return UserProfile(
      id: user.id,
      name: user.name ?? 'User',
      email: user.email,
      dateOfBirth: dateOfBirth,
      gender: Gender.other,
      height: 170.0, // Default height in cm
      weight: 75.0, // Default weight in kg
      targetWeight: 70.0, // Default target weight in kg
      fitnessGoals: [],
      dietaryApproach: 'Standard',
      dislikes: [],
      allergies: [],
      healthConditions: [],
      syncEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Save user profile to local database after authentication
  Future<void> _saveUserProfileAfterRegistration(AuthUser user) async {
    try {
      final userProfile = _createProfileFromAuthUser(user);
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.saveUserProfile(userProfile);
      print('RegistrationPage: User profile saved for user ${user.id}');
    } catch (e) {
      print('RegistrationPage: Error saving user profile: $e');
      // Don't fail registration if profile save fails
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
        );

    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated && authState.user != null && mounted) {
      // Save the authenticated user profile to local database
      await _saveUserProfileAfterRegistration(authState.user!);
      // Navigate to home page
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (authState.error != null && mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Color _getPasswordStrengthColor(String password) {
    final strength = PasswordValidator.getStrength(password);
    switch (strength) {
      case 'weak':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPasswordStrengthText(String password) {
    return PasswordValidator.getStrength(password).toUpperCase();
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authStateProvider.notifier).loginWithGoogle();

    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated && authState.user != null && mounted) {
      // Save the authenticated user profile to local database
      await _saveUserProfileAfterRegistration(authState.user!);
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (authState.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showGoogleToggleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Options'),
        content: Consumer(
          builder: (context, ref, child) {
            final isEnabled = ref.watch(googleLoginEnabledProvider);
            return SwitchListTile(
              title: const Text('Enable Google Sign-In'),
              value: isEnabled,
              onChanged: (value) async {
                ref.read(googleLoginEnabledProvider.notifier).state = value;
                await setGoogleLoginEnabled(value);
                if (mounted) Navigator.of(context).pop();
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleToggleInline() {
    return Consumer(
      builder: (context, ref, child) {
        final isEnabled = ref.watch(googleLoginEnabledProvider);
        return SwitchListTile(
          title: const Text('Enable Google Sign-In'),
          value: isEnabled,
          onChanged: (value) async {
            ref.read(googleLoginEnabledProvider.notifier).state = value;
            await setGoogleLoginEnabled(value);
          },
        );
      },
    );
  }

  Widget _buildGoogleSignInButton(AuthState authState) {
    final isEnabled = ref.watch(googleLoginEnabledProvider);
    return buildGoogleSignInButton(
      isEnabled: isEnabled,
      isLoading: authState.isLoading,
      onPressed: _handleGoogleSignIn,
    );
  }

  Widget _buildOrDivider() {
    return Consumer(
      builder: (context, ref, child) {
        final isEnabled = ref.watch(googleLoginEnabledProvider);
        if (!isEnabled) return const SizedBox.shrink();
        return Column(
          children: [
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildOrSignUpWithEmailText() {
    return Consumer(
      builder: (context, ref, child) {
        final isEnabled = ref.watch(googleLoginEnabledProvider);
        if (!isEnabled) return const SizedBox.shrink();
        return const Text(
          'Or sign up with email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Registration options',
            onPressed: _showGoogleToggleDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildGoogleToggleInline(),
                const SizedBox(height: 16),
                _buildGoogleSignInButton(authState),
                _buildOrDivider(),
                _buildOrSignUpWithEmailText(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name (Optional)',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: EmailValidator.validate,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: PasswordValidator.validate,
                  enabled: !authState.isLoading,
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show strength indicator
                  },
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: PasswordValidator.getStrength(
                                      _passwordController.text) ==
                                  'weak'
                              ? 0.33
                              : PasswordValidator.getStrength(
                                          _passwordController.text) ==
                                      'medium'
                                  ? 0.66
                                  : 1.0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPasswordStrengthColor(_passwordController.text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getPasswordStrengthText(_passwordController.text),
                        style: TextStyle(
                          color: _getPasswordStrengthColor(
                              _passwordController.text),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validateConfirmPassword,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
