import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/widgets/empty_state_widget.dart';
import 'package:health_app/core/widgets/loading_indicator.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe.dart';
import 'package:health_app/features/nutrition_management/domain/entities/recipe_difficulty.dart';
import 'package:health_app/features/nutrition_management/presentation/providers/nutrition_providers.dart';
import 'package:health_app/features/nutrition_management/presentation/widgets/recipe_card_widget.dart';
import 'package:health_app/features/nutrition_management/presentation/pages/recipe_detail_page.dart';

/// Recipe library page for browsing and searching recipes
class RecipeLibraryPage extends ConsumerStatefulWidget {
  const RecipeLibraryPage({super.key});

  @override
  ConsumerState<RecipeLibraryPage> createState() => _RecipeLibraryPageState();
}

class _RecipeLibraryPageState extends ConsumerState<RecipeLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<RecipeDifficulty> _selectedDifficulties = {};
  int? _maxPrepTime; // in minutes

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    var filtered = recipes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((recipe) {
        // Search in name
        if (recipe.name.toLowerCase().contains(query)) {
          return true;
        }
        // Search in description
        if (recipe.description != null &&
            recipe.description!.toLowerCase().contains(query)) {
          return true;
        }
        // Search in ingredients
        if (recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(query))) {
          return true;
        }
        // Search in tags
        if (recipe.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return true;
        }
        return false;
      }).toList();
    }

    // Apply difficulty filter
    if (_selectedDifficulties.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return _selectedDifficulties.contains(recipe.difficulty);
      }).toList();
    }

    // Apply prep time filter
    if (_maxPrepTime != null) {
      filtered = filtered.where((recipe) {
        return recipe.prepTime <= _maxPrepTime!;
      }).toList();
    }

    return filtered;
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FiltersBottomSheet(
        selectedDifficulties: _selectedDifficulties,
        maxPrepTime: _maxPrepTime,
        onApply: (difficulties, maxPrepTime) {
          setState(() {
            _selectedDifficulties = difficulties;
            _maxPrepTime = maxPrepTime;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active filters indicator
          if (_selectedDifficulties.isNotEmpty || _maxPrepTime != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.screenPaddingHorizontal,
                vertical: UIConstants.spacingSm,
              ),
              child: Wrap(
                spacing: UIConstants.spacingXs,
                runSpacing: UIConstants.spacingXs,
                children: [
                  if (_selectedDifficulties.isNotEmpty)
                    ..._selectedDifficulties.map((difficulty) {
                      return Chip(
                        label: Text(difficulty.displayName),
                        onDeleted: () {
                          setState(() {
                            _selectedDifficulties.remove(difficulty);
                          });
                        },
                      );
                    }),
                  if (_maxPrepTime != null)
                    Chip(
                      label: Text('Prep ≤ $_maxPrepTime min'),
                      onDeleted: () {
                        setState(() {
                          _maxPrepTime = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Recipes grid
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                final filtered = _filterRecipes(recipes);

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    title: recipes.isEmpty ? 'No recipes found' : 'No matching recipes',
                    description: recipes.isEmpty
                        ? 'Recipe library is empty'
                        : 'Try adjusting your search or filters',
                    icon: Icons.restaurant_menu,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: UIConstants.spacingMd,
                    mainAxisSpacing: UIConstants.spacingMd,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final recipe = filtered[index];
                    return RecipeCardWidget(
                      recipe: recipe,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => EmptyStateWidget(
                title: 'Error loading recipes',
                description: 'Failed to load recipe library',
                icon: Icons.error_outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for recipe filters
class _FiltersBottomSheet extends StatefulWidget {
  final Set<RecipeDifficulty> selectedDifficulties;
  final int? maxPrepTime;
  final Function(Set<RecipeDifficulty>, int?) onApply;

  const _FiltersBottomSheet({
    required this.selectedDifficulties,
    required this.maxPrepTime,
    required this.onApply,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late Set<RecipeDifficulty> _difficulties;
  late int? _maxPrepTime;

  @override
  void initState() {
    super.initState();
    _difficulties = Set.from(widget.selectedDifficulties);
    _maxPrepTime = widget.maxPrepTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _difficulties.clear();
                    _maxPrepTime = null;
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingLg),
          
          // Difficulty filter
          Text(
            'Difficulty',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: UIConstants.spacingSm),
          Wrap(
            spacing: UIConstants.spacingSm,
            children: RecipeDifficulty.values.map((difficulty) {
              final isSelected = _difficulties.contains(difficulty);
              return FilterChip(
                label: Text(difficulty.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _difficulties.add(difficulty);
                    } else {
                      _difficulties.remove(difficulty);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: UIConstants.spacingLg),
          
          // Prep time filter
          Text(
            'Maximum Prep Time (minutes)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: UIConstants.spacingSm),
          Wrap(
            spacing: UIConstants.spacingSm,
            children: [15, 30, 45, 60].map((minutes) {
              final isSelected = _maxPrepTime == minutes;
              return FilterChip(
                label: Text('≤ $minutes min'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _maxPrepTime = selected ? minutes : null;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: UIConstants.spacingLg),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_difficulties, _maxPrepTime);
                Navigator.of(context).pop();
              },
              child: const Text('Apply Filters'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + UIConstants.spacingMd),
        ],
      ),
    );
  }
}

