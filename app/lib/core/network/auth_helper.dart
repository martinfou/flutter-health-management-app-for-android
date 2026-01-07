
import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';

/// Helper to wrap static AuthenticationService calls for testing
class AuthHelper {
  Future<bool> isAuthenticated() => AuthenticationService.isAuthenticated();
  Future<Result<AuthUser>> getProfile() => AuthenticationService.getProfile();
}
