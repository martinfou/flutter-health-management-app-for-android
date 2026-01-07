
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_app/features/health_tracking/data/services/health_metrics_sync_service.dart';
import 'package:health_app/features/health_tracking/data/datasources/local/health_tracking_local_datasource.dart';
import 'package:health_app/features/health_tracking/data/datasources/remote/health_tracking_remote_datasource.dart';
import 'package:health_app/core/network/auth_helper.dart';
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/health_tracking/domain/entities/health_metric.dart';
import 'package:health_app/features/health_tracking/data/models/health_metric_model.dart';

@GenerateMocks([
  HealthTrackingLocalDataSource,
  HealthTrackingRemoteDataSource,
  AuthHelper,
])
import 'health_metrics_sync_service_test.mocks.dart';

void main() {
  late HealthMetricsSyncService service;
  late MockHealthTrackingLocalDataSource mockLocalDataSource;
  late MockHealthTrackingRemoteDataSource mockRemoteDataSource;
  late MockAuthHelper mockAuthHelper;

  setUp(() {
    mockLocalDataSource = MockHealthTrackingLocalDataSource();
    mockRemoteDataSource = MockHealthTrackingRemoteDataSource();
    mockAuthHelper = MockAuthHelper();
    
    SharedPreferences.setMockInitialValues({});
    
    // Provide dummy values for Mockito
    provideDummy<Result<AuthUser>>(Left(NetworkFailure('Dummy Fail')));
    provideDummy<Result<List<HealthMetric>>>(const Right([]));
    provideDummy<Result<List<HealthMetricModel>>>(const Right([]));
    
    service = HealthMetricsSyncService(
      mockLocalDataSource,
      mockRemoteDataSource,
      mockAuthHelper,
    );
  });

  final tUser = AuthUser(
    id: 'user1',
    name: 'Test',
    email: 'test@example.com',
  );

  test('should skip sync if not authenticated', () async {
    // Arrange
    when(mockAuthHelper.isAuthenticated()).thenAnswer((_) async => false);

    // Act
    final result = await service.syncHealthMetrics();

    // Assert
    expect(result.isRight(), true);
    verify(mockAuthHelper.isAuthenticated());
    verifyZeroInteractions(mockLocalDataSource);
    verifyZeroInteractions(mockRemoteDataSource);
  });

  test('should sync if authenticated', () async {
    // Arrange
    when(mockAuthHelper.isAuthenticated()).thenAnswer((_) async => true);
    when(mockAuthHelper.getProfile()).thenAnswer((_) async => Right(tUser));
    when(mockLocalDataSource.getHealthMetricsByUserId(any))
        .thenAnswer((_) async => const Right([]));
    when(mockRemoteDataSource.getHealthMetrics(
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
            limit: anyNamed('limit'),
            offset: anyNamed('offset')))
        .thenAnswer((_) async => const Right([]));

    // Act
    final result = await service.syncHealthMetrics();

    // Assert
    expect(result.isRight(), true);
    verify(mockAuthHelper.isAuthenticated());
    verify(mockLocalDataSource.getHealthMetricsByUserId('user1'));
  });
}
