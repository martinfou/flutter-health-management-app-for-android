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
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';

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
  /// Also migrates any existing health metrics from old/default userIds to the authenticated user
  /// and syncs the profile to the backend
  Future<void> _saveUserProfileAfterLogin(AuthUser user) async {
    try {
      final userProfile = _createProfileFromAuthUser(user);
      final userRepo = ref.read(userProfileRepositoryProvider);
      await userRepo.saveUserProfile(userProfile);
      print('LoginPage: User profile saved locally for user ${user.id}');

      // Migrate any existing health metrics to this user
      await _migrateExistingMetrics(user.id);

      // Sync the user profile to the backend so subsequent sync operations can fetch it
      // This ensures the backend has the user before health metrics sync
      await _syncUserProfileToBackend(userProfile);
    } catch (e) {
      print('LoginPage: Error saving user profile: $e');
      // Don't fail login if profile save fails
    }
  }

  /// Sync the authenticated user profile to the backend
  /// This is necessary so that the backend has the user record before health metrics sync
  Future<void> _syncUserProfileToBackend(UserProfile profile) async {
    try {
      // TODO: Implement user profile sync to backend
      // For now, this is a placeholder that would call an API to save the profile
      print('LoginPage: User profile sync to backend needed for user ${profile.id}');
      // In a full implementation, this would call: await userRepo.syncUserProfileToBackend(profile);
    } catch (e) {
      print('LoginPage: Warning - could not sync profile to backend: $e');
      // Don't fail - the profile is at least saved locally
    }
  }

  /// Migrate existing health metrics to the authenticated user
  ///
  /// This finds any health metrics that were created before authentication
  /// (with default/random userIds) and reassigns them to the authenticated user.
  Future<void> _migrateExistingMetrics(String newUserId) async {
    try {
      final healthRepo = ref.read(healthTrackingRepositoryProvider);

      // Get all metrics to find old userIds
      final allMetricsResult = await healthRepo.getAllHealthMetrics();

      await allMetricsResult.fold(
        (failure) {
          print('LoginPage: Could not get all metrics for migration: ${failure.message}');
        },
        (allMetrics) async {
          if (allMetrics.isEmpty) {
            print('LoginPage: No metrics to migrate');
            return;
          }

          // Find non-authenticated userIds (these are from before login)
          // These typically start with 'user-' (from millisecond timestamp)
          final oldUserIds = allMetrics
              .map((m) => m.userId)
              .toSet()
              .where((userId) => userId != newUserId && userId.startsWith('user-'))
              .toList();

          if (oldUserIds.isEmpty) {
            print('LoginPage: No metrics to migrate (all already have correct userId or were mock)');
            return;
          }

          print('LoginPage: Found ${oldUserIds.length} old userIds to migrate');

          // Migrate metrics from each old userId
          for (final oldUserId in oldUserIds) {
            final migrateResult = await healthRepo.migrateMetricsToUserId(
              fromUserId: oldUserId,
              toUserId: newUserId,
            );

            migrateResult.fold(
              (failure) {
                print('LoginPage: Migration failed for $oldUserId: ${failure.message}');
              },
              (count) {
                print('LoginPage: Migrated $count metrics from $oldUserId to $newUserId');
              },
            );
          }
        },
      );
    } catch (e) {
      print('LoginPage: Error during metrics migration: $e');
      // Don't fail login if migration fails
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
