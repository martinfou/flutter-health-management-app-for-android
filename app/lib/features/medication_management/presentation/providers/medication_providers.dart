import 'package:riverpod/riverpod.dart';
import 'package:health_app/features/medication_management/domain/entities/medication.dart';
import 'package:health_app/features/medication_management/presentation/providers/medication_repository_provider.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';

/// Provider for all medications for the current user
/// 
/// Fetches all medications for the current user from the repository.
/// Returns empty list if user not found or no medications exist.
/// Handles error states by returning empty list.
final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  try {
    // Get user profile to get userId
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    final userProfile = userResult.fold(
      (failure) => null,
      (profile) => profile,
    );

    if (userProfile == null) {
      return <Medication>[];
    }

    // Get medications for the user
    final medicationRepo = ref.watch(medicationRepositoryProvider);
    final result = await medicationRepo.getMedicationsByUserId(userProfile.id);

    return result.fold(
      (failure) {
        // Return empty list on error
        return <Medication>[];
      },
      (medications) => medications,
    );
  } catch (e) {
    // Return empty list on exception
    return <Medication>[];
  }
});

/// Provider for active medications for the current user
/// 
/// Fetches only active medications (those without an end date or with end date in the future)
/// for the current user from the repository.
/// Returns empty list if user not found or no active medications exist.
/// Handles error states by returning empty list.
final activeMedicationsProvider = FutureProvider<List<Medication>>((ref) async {
  try {
    // Get user profile to get userId
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final userResult = await userProfileRepo.getCurrentUserProfile();

    final userProfile = userResult.fold(
      (failure) => null,
      (profile) => profile,
    );

    if (userProfile == null) {
      return <Medication>[];
    }

    // Get active medications for the user
    final medicationRepo = ref.watch(medicationRepositoryProvider);
    final result = await medicationRepo.getActiveMedications(userProfile.id);

    return result.fold(
      (failure) {
        // Return empty list on error
        return <Medication>[];
      },
      (medications) => medications,
    );
  } catch (e) {
    // Return empty list on exception
    return <Medication>[];
  }
});

