import 'package:riverpod/riverpod.dart';
import 'package:health_app/core/constants/auth_config.dart';
import 'package:health_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:health_app/features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:health_app/features/user_profile/data/datasources/local/user_profile_local_datasource.dart';

/// Provider for UserProfileLocalDataSource
final userProfileLocalDataSourceProvider =
    Provider<UserProfileLocalDataSource>((ref) {
  return UserProfileLocalDataSource();
});

/// Provider for UserProfileRepository
final userProfileRepositoryProvider =
    Provider<UserProfileRepository>((ref) {
  final localDataSource = ref.watch(userProfileLocalDataSourceProvider);
  final authEnabled = ref.watch(authEnabledProvider);
  final authDisabled = !authEnabled;
  return UserProfileRepositoryImpl(localDataSource, authDisabled: authDisabled);
});

