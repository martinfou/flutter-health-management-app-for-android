# Medication Management Module Specification

## Overview

The Medication Management Module provides comprehensive medication tracking including medication logging, reminder scheduling, side effect monitoring, and medication-aware nutrition integration. The module includes safety alerts and clinical safety protocol integration.

**Reference**: 
- Architecture: `artifacts/phase-1-foundations/architecture-documentation.md`
- Data Models: `artifacts/phase-1-foundations/data-models.md`
- Health Domain: `artifacts/phase-1-foundations/health-domain-specifications.md`
- Clinical Safety: `artifacts/phase-1-foundations/clinical-safety-protocols.md`

## Module Structure

```
lib/features/medication_management/
├── data/
│   ├── models/
│   │   ├── medication_model.dart
│   │   ├── medication_log_model.dart
│   │   └── side_effect_model.dart
│   ├── repositories/
│   │   └── medication_repository_impl.dart
│   └── datasources/
│       └── local/
│           └── medication_local_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── medication.dart
│   │   ├── medication_log.dart
│   │   └── side_effect.dart
│   ├── repositories/
│   │   └── medication_repository.dart
│   └── usecases/
│       ├── add_medication.dart
│       ├── log_medication_dose.dart
│       ├── track_side_effect.dart
│       ├── get_active_medications.dart
│       └── generate_reminders.dart
└── presentation/
    ├── pages/
    │   ├── medication_list_page.dart
    │   ├── medication_entry_page.dart
    │   ├── medication_detail_page.dart
    │   ├── medication_log_page.dart
    │   └── side_effects_page.dart
    ├── widgets/
    │   ├── medication_card_widget.dart
    │   ├── medication_reminder_widget.dart
    │   └── side_effect_form_widget.dart
    └── providers/
        ├── medications_provider.dart
        ├── medication_logs_provider.dart
        └── side_effects_provider.dart
```

## Medication Tracking

### Features

- Add/edit/delete medications
- Medication details: name, dosage, frequency, times
- Active/inactive medication status
- Medication history tracking
- Medication reminders

### UI Components

**Medication List Screen**:
- List of all medications (active and inactive)
- Filter: Active, Inactive, All
- Medication cards showing:
  - Medication name and dosage
  - Frequency (e.g., "Twice Daily")
  - Next scheduled time
  - Active status indicator
- Floating action button: "Add Medication"
- Tap medication to view details

**Medication Entry Screen**:
- Medication name input
- Dosage input (e.g., "150mg", "0.5mg")
- Frequency selector:
  - Once Daily
  - Twice Daily
  - Three Times Daily
  - Weekly
  - As Needed
- Time pickers (based on frequency):
  - Once Daily: 1 time picker
  - Twice Daily: 2 time pickers
  - Three Times Daily: 3 time pickers
  - Weekly: 1 time picker with day selector
  - As Needed: No scheduled times
- Start date picker
- End date picker (optional, for temporary medications)
- Reminder toggle (enable/disable notifications)
- Save button

**Medication Detail Screen**:
- Full medication information
- Edit/Delete buttons
- Medication log history
- Side effects list
- Adherence statistics (days taken, missed doses)
- Link to side effects tracking

### Business Logic

**AddMedicationUseCase**:
```dart
class AddMedicationUseCase {
  final MedicationRepository repository;
  
  Future<Either<Failure, Medication>> call({
    required String name,
    required String dosage,
    required MedicationFrequency frequency,
    required List<TimeOfDay> times,
    required DateTime startDate,
    DateTime? endDate,
    bool reminderEnabled = true,
  }) async {
    // Validate inputs
    if (name.isEmpty || name.length > 100) {
      return Left(ValidationFailure('Medication name must be 1-100 characters'));
    }
    
    if (dosage.isEmpty || dosage.length > 50) {
      return Left(ValidationFailure('Dosage must be 1-50 characters'));
    }
    
    if (times.isEmpty && frequency != MedicationFrequency.asNeeded) {
      return Left(ValidationFailure('At least one time must be specified'));
    }
    
    if (endDate != null && endDate.isBefore(startDate)) {
      return Left(ValidationFailure('End date must be after start date'));
    }
    
    // Create medication
    final medication = Medication(
      id: UUID().v4(),
      userId: currentUserId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      times: times,
      startDate: startDate,
      endDate: endDate,
      reminderEnabled: reminderEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save to repository
    return await repository.saveMedication(medication);
  }
}
```

**Validation Rules**:
- **Name**: Required, 1-100 characters
- **Dosage**: Required, 1-50 characters
- **Times**: At least one time required (unless frequency is "As Needed")
- **Start Date**: Required, cannot be in future
- **End Date**: Optional, must be after start date if provided
- **Maximum Times**: 10 times per day maximum

## Medication Reminders

### Features

- Automatic reminder generation based on medication schedule
- Local notifications for reminders
- Reminder customization per medication
- Missed dose alerts
- Reminder status tracking

### Reminder Generation

**GenerateRemindersUseCase**:
```dart
class GenerateRemindersUseCase {
  final NotificationScheduler notificationScheduler;
  
  Future<Either<Failure, List<Notification>>> call(Medication medication) async {
    if (!medication.reminderEnabled || !medication.isActive) {
      return Right([]);
    }
    
    final reminders = <Notification>[];
    
    for (final timeOfDay in medication.times) {
      final nextOccurrence = _calculateNextOccurrence(timeOfDay);
      
      reminders.add(Notification(
        id: '${medication.id}_${timeOfDay.hour}_${timeOfDay.minute}',
        title: 'Medication Reminder',
        body: 'Time to take ${medication.name} (${medication.dosage})',
        scheduledTime: nextOccurrence,
        repeatDaily: medication.frequency == MedicationFrequency.daily ||
                     medication.frequency == MedicationFrequency.twiceDaily ||
                     medication.frequency == MedicationFrequency.threeTimesDaily,
        channelId: 'medication_reminders',
        importance: NotificationImportance.high,
      ));
    }
    
    // Schedule notifications
    for (final reminder in reminders) {
      await notificationScheduler.schedule(reminder);
    }
    
    return Right(reminders);
  }
  
  DateTime _calculateNextOccurrence(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    
    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
    
    return scheduledTime;
  }
}
```

### Notification Channel

**Configuration**: See platform specifications for detailed notification channel configuration.

**Channel Details**:
- **Channel ID**: `medication_reminders`
- **Channel Name**: "Medication Reminders"
- **Importance**: High
- **Description**: "Notifications for medication reminders"
- **Sound**: Default notification sound
- **Vibration**: Enabled

### Missed Dose Detection

**Missed Dose Alert**:
- Check if medication was not logged within 2 hours of scheduled time
- Show missed dose alert on medication list
- Option to log missed dose
- Track adherence statistics

## Medication Logging

### Features

- Log when medication is taken
- Log missed doses
- Dosage tracking (actual vs scheduled)
- Notes field for medication log entries
- Medication history view

### UI Components

**Medication Log Entry**:
- Quick log button from medication card
- Medication name and dosage display
- Time picker (defaults to now, can select past time)
- Notes field (optional)
- Save button

**Medication Log History**:
- List of all medication logs
- Grouped by medication
- Sortable by date
- Filter: All, Taken, Missed
- Display: Date, time, dosage, notes

### Business Logic

**LogMedicationDoseUseCase**:
```dart
class LogMedicationDoseUseCase {
  final MedicationRepository repository;
  
  Future<Either<Failure, MedicationLog>> call({
    required String medicationId,
    required DateTime takenAt,
    String? dosage,
    String? notes,
  }) async {
    // Get medication
    final medicationResult = await repository.getMedication(medicationId);
    
    return medicationResult.fold(
      (failure) => Left(failure),
      (medication) async {
        // Use medication dosage if not provided
        final actualDosage = dosage ?? medication.dosage;
        
        // Create log entry
        final log = MedicationLog(
          id: UUID().v4(),
          medicationId: medicationId,
          takenAt: takenAt,
          dosage: actualDosage,
          notes: notes,
          createdAt: DateTime.now(),
        );
        
        // Save log
        return await repository.saveMedicationLog(log);
      },
    );
  }
}
```

**Validation Rules**:
- **Taken At**: Required, cannot be in future
- **Dosage**: Optional, defaults to medication dosage
- **Notes**: Optional, max 500 characters

## Side Effect Tracking

### Features

- Track medication side effects
- Side effect severity levels (mild, moderate, severe)
- Side effect start/end dates
- Notes for side effects
- Link side effects to medications
- Side effect history

### UI Components

**Side Effect Entry Screen**:
- Medication selector (pre-select if accessed from medication detail)
- Side effect name input (or selector from common side effects)
- Severity selector:
  - Mild
  - Moderate
  - Severe
- Start date picker (defaults to today)
- End date picker (optional, for resolved side effects)
- Notes field (optional)
- Save button

**Side Effects List**:
- List of all side effects
- Grouped by medication
- Filter: All, Active, Resolved
- Severity indicators (color-coded)
- Tap to view/edit details

**Common Side Effects**:
- Nausea
- Headache
- Dizziness
- Fatigue
- Insomnia
- Dry mouth
- Constipation
- Diarrhea
- Appetite changes
- Other (custom entry)

### Business Logic

**TrackSideEffectUseCase**:
```dart
class TrackSideEffectUseCase {
  final MedicationRepository repository;
  
  Future<Either<Failure, SideEffect>> call({
    required String medicationId,
    required String name,
    required SideEffectSeverity severity,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    // Validate inputs
    if (name.isEmpty || name.length > 200) {
      return Left(ValidationFailure('Side effect name must be 1-200 characters'));
    }
    
    if (endDate != null && endDate.isBefore(startDate)) {
      return Left(ValidationFailure('End date must be after start date'));
    }
    
    // Create side effect
    final sideEffect = SideEffect(
      id: UUID().v4(),
      medicationId: medicationId,
      name: name,
      severity: severity,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      createdAt: DateTime.now(),
    );
    
    // Save side effect
    return await repository.saveSideEffect(sideEffect);
  }
}
```

**Validation Rules**:
- **Name**: Required, 1-200 characters
- **Severity**: Required, must be one of: mild, moderate, severe
- **Start Date**: Required, cannot be in future
- **End Date**: Optional, must be after start date if provided
- **Notes**: Optional, max 1000 characters

### Clinical Safety Integration

**Safety Alerts**:
- Severe side effects trigger safety alerts
- Multiple side effects trigger escalated alert
- Link to clinical safety protocols

**Integration Points**:
- Link side effects to health metrics (e.g., nausea affecting nutrition)
- Track medication impact on sleep and energy levels
- Monitor medication interactions

## Adherence Tracking

### Features

- Calculate medication adherence percentage
- Track taken vs missed doses
- Display adherence statistics
- Weekly/monthly adherence reports

### Adherence Calculation

**Adherence Percentage**:
```dart
class CalculateAdherenceUseCase {
  double call(Medication medication, List<MedicationLog> logs, DateTime startDate, DateTime endDate) {
    // Calculate expected doses
    final expectedDoses = _calculateExpectedDoses(medication, startDate, endDate);
    
    // Count actual doses
    final actualDoses = logs
        .where((log) =>
            log.medicationId == medication.id &&
            log.takenAt.isAfter(startDate) &&
            log.takenAt.isBefore(endDate))
        .length;
    
    // Calculate percentage
    if (expectedDoses == 0) return 0.0;
    
    return (actualDoses / expectedDoses) * 100;
  }
  
  int _calculateExpectedDoses(Medication medication, DateTime startDate, DateTime endDate) {
    // Calculate based on frequency
    final days = endDate.difference(startDate).inDays;
    
    switch (medication.frequency) {
      case MedicationFrequency.daily:
        return days;
      case MedicationFrequency.twiceDaily:
        return days * 2;
      case MedicationFrequency.threeTimesDaily:
        return days * 3;
      case MedicationFrequency.weekly:
        return (days / 7).ceil();
      case MedicationFrequency.asNeeded:
        return 0; // Cannot calculate expected for as-needed
    }
  }
}
```

**Display**:
- Adherence percentage (e.g., "95%")
- Taken: X doses
- Missed: Y doses
- Expected: Z doses
- Visual indicator (progress bar, color-coded)

## Integration Points

### Health Tracking Module

- Link medication to heart rate tracking
- Track medication impact on sleep quality
- Track medication impact on energy levels
- Display medication context in health metrics

### Nutrition Module

- Medication-aware nutrition (protein-first strategy)
- Adjust meal plans based on medication side effects
- Track medication impact on appetite
- Meal timing recommendations based on medication schedule

### Clinical Safety Alerts

- Integrate with clinical safety protocols
- Display safety alerts for severe side effects
- Link to pause protocol if needed
- Medication-related safety alerts

## User Flows

### Add Medication Flow

```
Medication List → Add Medication → Enter Details
    ↓
Select Frequency → Add Times → Set Dates
    ↓
Enable Reminders → Save Medication
    ↓
Generate Reminders → Schedule Notifications
    ↓
Return to Medication List
```

### Log Medication Dose Flow

```
Medication List → Tap Medication → Log Dose
    ↓
Select Time → Add Notes (optional) → Save
    ↓
Update Medication Log → Update Adherence Stats
    ↓
Return to Medication Detail
```

### Track Side Effect Flow

```
Medication Detail → Track Side Effect → Enter Details
    ↓
Select Severity → Set Dates → Add Notes
    ↓
Save Side Effect → Check Safety Alerts
    ↓
Display Alert (if severe) → Return to Medication Detail
```

## Testing Requirements

### Unit Tests

- Medication validation logic
- Reminder generation algorithm
- Adherence calculation
- Side effect tracking logic
- Date range calculations

### Widget Tests

- Medication entry form
- Medication list display
- Side effect form
- Reminder scheduling UI

### Integration Tests

- Complete medication entry flow
- Medication logging flow
- Side effect tracking flow
- Reminder notification delivery
- Adherence calculation accuracy

## Performance Considerations

- Efficient querying of medication logs
- Optimized reminder scheduling
- Fast medication list loading
- Efficient side effect filtering

## Accessibility

- Screen reader labels for all inputs
- Keyboard navigation support
- High contrast mode support
- Clear visual indicators for medication status

## References

- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **Data Models**: `artifacts/phase-1-foundations/data-models.md`
- **Health Domain**: `artifacts/phase-1-foundations/health-domain-specifications.md`
- **Clinical Safety**: `artifacts/phase-1-foundations/clinical-safety-protocols.md`
- **Platform Specs**: `artifacts/phase-3-integration/platform-specifications.md`

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Medication Management Module Specification Complete

