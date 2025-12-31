import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/health_constants.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/core/entities/user_preferences.dart';
import 'package:health_app/core/utils/calorie_calculation_utils.dart';
import 'package:health_app/features/nutrition_management/domain/entities/meal_type.dart';
import 'package:health_app/features/nutrition_management/domain/usecases/calculate_macros.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/eating_reason.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/nutrition_management/presentation/widgets/hunger_scale_widget.dart';
import 'package:health_app/features/nutrition_management/presentation/widgets/eating_reasons_widget.dart';
import 'package:health_app/features/user_profile/presentation/providers/user_profile_repository_provider.dart';
import 'package:health_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:health_app/features/health_tracking/presentation/providers/health_tracking_repository_provider.dart';

/// Simple food item model for meal logging
class FoodItem {
  final String name;
  final double protein;
  final double fats;
  final double netCarbs;
  final double calories;
  final List<String> ingredients;

  FoodItem({
    required this.name,
    required this.protein,
    required this.fats,
    required this.netCarbs,
    required this.calories,
    required this.ingredients,
  });

  FoodItem copyWith({
    String? name,
    double? protein,
    double? fats,
    double? netCarbs,
    double? calories,
    List<String>? ingredients,
  }) {
    return FoodItem(
      name: name ?? this.name,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      netCarbs: netCarbs ?? this.netCarbs,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}

/// Meal logging page for logging meals with macro information
class MealLoggingPage extends ConsumerStatefulWidget {
  const MealLoggingPage({super.key});

  @override
  ConsumerState<MealLoggingPage> createState() => _MealLoggingPageState();
}

class _MealLoggingPageState extends ConsumerState<MealLoggingPage> {
  MealType _selectedMealType = MealType.breakfast;
  final List<FoodItem> _foodItems = [];
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Behavioral tracking fields
  int? _hungerLevelBefore;
  int? _hungerLevelAfter;
  Set<EatingReason> _selectedEatingReasons = {};

  /// Calculate meal totals from food items
  MacroSummary _calculateMealTotals() {
    if (_foodItems.isEmpty) {
      return MacroSummary(
        protein: 0.0,
        fats: 0.0,
        netCarbs: 0.0,
        calories: 0.0,
        proteinPercent: 0.0,
        fatsPercent: 0.0,
        carbsPercent: 0.0,
      );
    }

    // Calculate totals from macros
    double totalProtein = 0.0;
    double totalFats = 0.0;
    double totalNetCarbs = 0.0;

    for (final item in _foodItems) {
      totalProtein += item.protein;
      totalFats += item.fats;
      totalNetCarbs += item.netCarbs;
    }

    // Calculate calories from macros to ensure accuracy (avoids rounding errors when combining recipes)
    final totalCalories = (totalProtein * HealthConstants.caloriesPerGramProtein) +
        (totalFats * HealthConstants.caloriesPerGramFat) +
        (totalNetCarbs * HealthConstants.caloriesPerGramCarbs);

    // Calculate percentages
    final proteinPercent = totalCalories > 0
        ? (totalProtein * HealthConstants.caloriesPerGramProtein / totalCalories) * 100
        : 0.0;
    final fatsPercent = totalCalories > 0
        ? (totalFats * HealthConstants.caloriesPerGramFat / totalCalories) * 100
        : 0.0;
    final carbsPercent = totalCalories > 0
        ? (totalNetCarbs * HealthConstants.caloriesPerGramCarbs / totalCalories) * 100
        : 0.0;

    return MacroSummary(
      protein: double.parse(totalProtein.toStringAsFixed(1)),
      fats: double.parse(totalFats.toStringAsFixed(1)),
      netCarbs: double.parse(totalNetCarbs.toStringAsFixed(1)),
      calories: double.parse(totalCalories.toStringAsFixed(1)),
      proteinPercent: double.parse(proteinPercent.toStringAsFixed(1)),
      fatsPercent: double.parse(fatsPercent.toStringAsFixed(1)),
      carbsPercent: double.parse(carbsPercent.toStringAsFixed(1)),
    );
  }

  /// Show add food item dialog
  Future<void> _showAddFoodItemDialog() async {
    final result = await showDialog<FoodItem>(
      context: context,
      builder: (context) => _AddFoodItemDialog(),
    );

    if (result != null) {
      setState(() {
        _foodItems.add(result);
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  /// Edit food item
  Future<void> _editFoodItem(int index) async {
    final item = _foodItems[index];
    final result = await showDialog<FoodItem>(
      context: context,
      builder: (context) => _AddFoodItemDialog(initialItem: item),
    );

    if (result != null) {
      setState(() {
        _foodItems[index] = result;
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  /// Remove food item
  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
      _errorMessage = null;
      _successMessage = null;
    });
  }

  /// Show recipe selector dialog
  Future<void> _showRecipeSelector() async {
    final recipesAsync = ref.read(recipesProvider);
    
    await recipesAsync.when(
      data: (recipes) async {
        if (recipes.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No recipes available. Please add recipes first.'),
            ),
          );
          return;
        }

        if (!mounted) return;
        final selectedRecipe = await showDialog<Recipe>(
          context: context,
          builder: (context) => _RecipeSelectorDialog(recipes: recipes),
        );

        if (selectedRecipe != null) {
          // Convert recipe to FoodItem
          final foodItem = FoodItem(
            name: selectedRecipe.name,
            protein: selectedRecipe.protein,
            fats: selectedRecipe.fats,
            netCarbs: selectedRecipe.netCarbs,
            calories: selectedRecipe.calories,
            ingredients: selectedRecipe.ingredients,
          );

          setState(() {
            _foodItems.add(foodItem);
            _errorMessage = null;
            _successMessage = null;
          });
        }
      },
      loading: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading recipes...'),
          ),
        );
      },
      error: (error, stack) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading recipes: $error'),
          ),
        );
      },
    );
  }

  /// Save meal
  Future<void> _saveMeal() async {
    if (_foodItems.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one food item';
      });
      return;
    }

    // Calculate totals for display
    final totals = _calculateMealTotals();
    final allIngredients = _foodItems
        .expand((item) => item.ingredients)
        .toSet()
        .toList(); // Remove duplicates

    // Calculate unrounded macros and calories for saving (to avoid rounding errors)
    double unroundedProtein = 0.0;
    double unroundedFats = 0.0;
    double unroundedNetCarbs = 0.0;

    for (final item in _foodItems) {
      unroundedProtein += item.protein;
      unroundedFats += item.fats;
      unroundedNetCarbs += item.netCarbs;
    }

    // Calculate calories from unrounded macros to ensure exact match with validation
    final unroundedCalories = (unroundedProtein * HealthConstants.caloriesPerGramProtein) +
        (unroundedFats * HealthConstants.caloriesPerGramFat) +
        (unroundedNetCarbs * HealthConstants.caloriesPerGramCarbs);

    // Get meal name from food items
    final mealName = _foodItems.length == 1
        ? _foodItems.first.name
        : '${_selectedMealType.displayName} Meal';

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // Get user ID
    String? userId;
    try {
      final userRepo = ref.read(userProfileRepositoryProvider);
      final userResult = await userRepo.getCurrentUserProfile();
      userId = userResult.fold((_) => null, (profile) => profile.id);
    } catch (e) {
      userId = null;
    }

    if (userId == null) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'User profile not found. Please set up your profile first.';
      });
      return;
    }

    // Use LogMealUseCase to save with unrounded values
    // This ensures calories calculated from macros in validation exactly match what we pass
    final useCase = ref.read(logMealUseCaseProvider);
    final result = await useCase.call(
      userId: userId,
      mealType: _selectedMealType,
      name: mealName,
      protein: unroundedProtein,
      fats: unroundedFats,
      netCarbs: unroundedNetCarbs,
      calories: unroundedCalories,
      ingredients: allIngredients,
      hungerLevelBefore: _hungerLevelBefore,
      hungerLevelAfter: _hungerLevelAfter,
      eatingReasons: _selectedEatingReasons.isEmpty ? null : _selectedEatingReasons.toList(),
    );

    result.fold(
      (failure) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (savedMeal) async {
        // Get user preferences (use defaults for now)
        final preferences = UserPreferences.defaults();
        
        // Only show warnings if enabled in preferences
        String? calorieWarning;
        if (preferences.showCalorieWarnings) {
          try {
            // Get user profile
            final userRepo = ref.read(userProfileRepositoryProvider);
            final userResult = await userRepo.getCurrentUserProfile();
            
            UserProfile? userProfile;
            userResult.fold(
              (_) => null,
              (profile) {
                userProfile = profile;
              },
            );
            
            if (userProfile != null) {
              // Try to get current weight for more accurate calculations
              double? currentWeight;
              try {
                final healthRepo = ref.read(healthTrackingRepositoryProvider);
                final weightResult = await healthRepo.getLatestWeight(userProfile!.id);
                currentWeight = weightResult.fold((_) => null, (metric) => metric.weight);
              } catch (e) {
                // Weight not available, will use target weight
              }
              
              // Calculate personalized calorie thresholds
              final thresholds = CalorieCalculationUtils.calculateMealCalorieThresholds(
                userProfile!,
                currentWeight,
                objective: preferences.weightLossObjective,
                activityFactor: preferences.activityFactor,
                mealsPerDay: preferences.mealsPerDay,
              );
              
              // Check if calories warrant a warning
              calorieWarning = thresholds.getWarningMessage(totals.calories);
            }
          } catch (e) {
            // If we can't calculate personalized thresholds, use simple defaults
            if (totals.calories < 100.0) {
              calorieWarning = 'Note: This meal has very few calories (${totals.calories.toStringAsFixed(0)} cal). Please verify the values are correct.';
            } else if (totals.calories > 2000.0) {
              calorieWarning = 'Note: This meal has very high calories (${totals.calories.toStringAsFixed(0)} cal). Please verify the values are correct.';
            }
          }
        }
        
        setState(() {
          _isSaving = false;
          _successMessage = 'Meal saved successfully!';
          if (calorieWarning != null) {
            _errorMessage = calorieWarning; // Show as informational message
          }
          _foodItems.clear();
          // Reset behavioral tracking fields
          _hungerLevelBefore = null;
          _hungerLevelAfter = null;
          _selectedEatingReasons.clear();
        });
        // Invalidate providers to refresh data
        ref.invalidate(dailyMealsProvider);
        ref.invalidate(macroSummaryProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = _calculateMealTotals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meal Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    SegmentedButton<MealType>(
                      segments: MealType.values.map((type) {
                        return ButtonSegment<MealType>(
                          value: type,
                          label: Text(type.displayName),
                        );
                      }).toList(),
                      selected: {_selectedMealType},
                      onSelectionChanged: (Set<MealType> newSelection) {
                        setState(() {
                          _selectedMealType = newSelection.first;
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Food items list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Food Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restaurant_menu),
                              onPressed: _showRecipeSelector,
                              tooltip: 'Select Recipe',
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _showAddFoodItemDialog,
                              tooltip: 'Add Food Item',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    if (_foodItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(UIConstants.spacingMd),
                        child: Text(
                          'No food items added yet. Tap the + button to add.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _foodItems.length,
                        itemBuilder: (context, index) {
                          final item = _foodItems[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              '${item.protein.toStringAsFixed(1)}g P / '
                              '${item.fats.toStringAsFixed(1)}g F / '
                              '${item.netCarbs.toStringAsFixed(1)}g C / '
                              '${item.calories.toStringAsFixed(0)} cal',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editFoodItem(index),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeFoodItem(index),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Meal totals card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meal Totals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    _MacroRow(
                      label: 'Protein',
                      value: totals.protein,
                      unit: 'g',
                      percent: totals.proteinPercent,
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    _MacroRow(
                      label: 'Fats',
                      value: totals.fats,
                      unit: 'g',
                      percent: totals.fatsPercent,
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    _MacroRow(
                      label: 'Net Carbs',
                      value: totals.netCarbs,
                      unit: 'g',
                      percent: totals.carbsPercent,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Calories',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${totals.calories.toStringAsFixed(0)} cal',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Meal Context section (Optional)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meal Context (Optional)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    
                    // Hunger Before scale
                    HungerScaleWidget(
                      selectedValue: _hungerLevelBefore,
                      label: 'How hungry are you? (Before eating)',
                      onChanged: (value) {
                        setState(() {
                          _hungerLevelBefore = value;
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                    ),
                    
                    const SizedBox(height: UIConstants.spacingLg),
                    
                    // Hunger After scale
                    HungerScaleWidget(
                      selectedValue: _hungerLevelAfter,
                      label: 'How full are you now? (After eating)',
                      onChanged: (value) {
                        setState(() {
                          _hungerLevelAfter = value;
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                    ),
                    
                    const SizedBox(height: UIConstants.spacingLg),
                    const Divider(),
                    const SizedBox(height: UIConstants.spacingMd),
                    
                    // Eating reasons
                    EatingReasonsWidget(
                      selectedReasons: _selectedEatingReasons,
                      onChanged: (reasons) {
                        setState(() {
                          _selectedEatingReasons = reasons;
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingMd),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Success message
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                child: Text(
                  _successMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Save button
            CustomButton(
              label: 'Save Meal',
              onPressed: _isSaving ? null : _saveMeal,
              isLoading: _isSaving,
              width: double.infinity,
            ),
            const SizedBox(height: UIConstants.spacingMd),
          ],
        ),
      ),
    );
  }
}

/// Macro row widget for displaying macro information
class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double percent;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              '(${percent.toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Dialog for adding/editing food items
class _AddFoodItemDialog extends StatefulWidget {
  final FoodItem? initialItem;

  const _AddFoodItemDialog({this.initialItem});

  @override
  State<_AddFoodItemDialog> createState() => _AddFoodItemDialogState();
}

class _AddFoodItemDialogState extends State<_AddFoodItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatsController = TextEditingController();
  final _netCarbsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _ingredientsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      final item = widget.initialItem!;
      _nameController.text = item.name;
      _proteinController.text = item.protein.toStringAsFixed(1);
      _fatsController.text = item.fats.toStringAsFixed(1);
      _netCarbsController.text = item.netCarbs.toStringAsFixed(1);
      _caloriesController.text = item.calories.toStringAsFixed(1);
      _ingredientsController.text = item.ingredients.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _proteinController.dispose();
    _fatsController.dispose();
    _netCarbsController.dispose();
    _caloriesController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    final protein = double.tryParse(_proteinController.text) ?? 0.0;
    final fats = double.tryParse(_fatsController.text) ?? 0.0;
    final netCarbs = double.tryParse(_netCarbsController.text) ?? 0.0;

    final calculatedCalories = (protein * HealthConstants.caloriesPerGramProtein) +
        (fats * HealthConstants.caloriesPerGramFat) +
        (netCarbs * HealthConstants.caloriesPerGramCarbs);

    setState(() {
      _caloriesController.text = calculatedCalories.toStringAsFixed(1);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final protein = double.tryParse(_proteinController.text) ?? 0.0;
    final fats = double.tryParse(_fatsController.text) ?? 0.0;
    final netCarbs = double.tryParse(_netCarbsController.text) ?? 0.0;
    final calories = double.tryParse(_caloriesController.text) ?? 0.0;
    final ingredientsText = _ingredientsController.text.trim();
    final ingredients = ingredientsText.isEmpty
        ? [name]
        : ingredientsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final item = FoodItem(
      name: name,
      protein: protein,
      fats: fats,
      netCarbs: netCarbs,
      calories: calories,
      ingredients: ingredients,
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialItem == null ? 'Add Food Item' : 'Edit Food Item'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g., Grilled Chicken',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UIConstants.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      onChanged: (_) => _calculateCalories(),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingSm),
                  Expanded(
                    child: TextFormField(
                      controller: _fatsController,
                      decoration: const InputDecoration(
                        labelText: 'Fats (g)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      onChanged: (_) => _calculateCalories(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _netCarbsController,
                      decoration: const InputDecoration(
                        labelText: 'Net Carbs (g)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Invalid';
                        }
                        if (num > 40.0) {
                          return 'Max 40g';
                        }
                        return null;
                      },
                      onChanged: (_) => _calculateCalories(),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingSm),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingSm),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients (comma-separated)',
                  hintText: 'e.g., chicken, olive oil, salt',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: UIConstants.spacingSm),
              OutlinedButton.icon(
                onPressed: _calculateCalories,
                icon: const Icon(Icons.calculate),
                label: const Text('Auto-calculate Calories'),
              ),
              const SizedBox(height: UIConstants.spacingXs),
            ],
          ),
        ),
      ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Dialog for selecting a recipe to add to meal
class _RecipeSelectorDialog extends StatelessWidget {
  final List<Recipe> recipes;

  const _RecipeSelectorDialog({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Select Recipe'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                leading: Icon(
                  Icons.restaurant_menu,
                  color: theme.colorScheme.primary,
                ),
                title: Text(recipe.name),
                subtitle: Text(
                  '${recipe.calories.toStringAsFixed(0)} cal • '
                  '${recipe.protein.toStringAsFixed(1)}g P / '
                  '${recipe.fats.toStringAsFixed(1)}g F / '
                  '${recipe.netCarbs.toStringAsFixed(1)}g C',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onTap: () {
                  Navigator.of(context).pop(recipe);
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

