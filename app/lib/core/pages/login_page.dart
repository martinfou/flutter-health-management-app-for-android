// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project
import 'package:health_app/core/providers/auth_provider.dart';
import 'package:health_app/core/utils/validation_utils.dart';
import 'package:health_app/core/utils/google_sign_in_button_util.dart';
import 'package:health_app/core/pages/registration_page.dart';
import 'package:health_app/core/pages/password_reset_request_page.dart';
import 'package:health_app/core/navigation/app_router.dart';
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/user_profile/domain/entities/gender.dart';

/// Login page for user authentication
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
  Future<void> _saveUserProfileAfterLogin(AuthUser user) async {
    try {
      final userProfile = _createProfileFromAuthUser(user);
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.saveUserProfile(userProfile);
      print('LoginPage: User profile saved for user ${user.id}');
    } catch (e) {
      print('LoginPage: Error saving user profile: $e');
      // Don't fail login if profile save fails
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authStateProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated && authState.user != null && mounted) {
      // Save the authenticated user profile to local database
      await _saveUserProfileAfterLogin(authState.user!);
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

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authStateProvider.notifier).loginWithGoogle();

    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated && authState.user != null && mounted) {
      // Save the authenticated user profile to local database
      await _saveUserProfileAfterLogin(authState.user!);
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
        title: const Text('Login Options'),
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

  Widget _buildOrSignInWithEmailText() {
    return Consumer(
      builder: (context, ref, child) {
        final isEnabled = ref.watch(googleLoginEnabledProvider);
        if (!isEnabled) return const SizedBox.shrink();
        return const Text(
          'Or sign in with email',
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
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Login options',
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
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
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
                _buildOrSignInWithEmailText(),
                const SizedBox(height: 24),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: authState.isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                        ),
                        const Text('Remember me'),
                      ],
                    ),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PasswordResetRequestPage(),
                                ),
                              );
                            },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegistrationPage(),
                                ),
                              );
                            },
                      child: const Text('Sign Up'),
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
