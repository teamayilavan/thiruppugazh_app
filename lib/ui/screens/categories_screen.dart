import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/song_repository.dart';
import 'song_list_screen.dart';
import '../widgets/error_display_widget.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_constants.dart';

// ✨ It's now a simpler StatelessWidget
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      // ✅ Wrap the body with a Consumer to listen for changes
      body: Consumer<SongRepository>(
        builder: (context, repository, child) {
          // The Consumer rebuilds this whenever notifyListeners() is called,
          // giving the FutureBuilder a new future and causing it to reload.
          return FutureBuilder<List<Category>>(
            future: repository.getAllCategories(), // ✨ Get future from the repository
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ErrorDisplayWidget(
                  errorMessage: AppStrings.failedToLoadCategories,
                  onRetry: null,
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text(AppStrings.noCategoriesFound));
              }

              final categories = snapshot.data!;
              return Scrollbar(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Semantics(
                      button: true,
                      label: '${category.name} category',
                      hint: '${category.songCount} songs',
                      child: ListTile(
                        leading: Icon(
                          category.name == 'Favorites'
                              ? Icons.favorite
                              : Icons.folder_open_outlined,
                        ),
                        title: Text(category.name),
                        trailing: Text(
                          category.songCount.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // ✨ The onTap is simple again. No need for setState.
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  SongListScreen(category: category),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Create new category',
        hint: 'Tap to create a new song category',
        child: FloatingActionButton(
          onPressed: () {
            // This dialog now triggers a repository method, which will
            // automatically update UI thanks to the Consumer.
            _showCreateCategoryDialog(context);
          },
          tooltip: 'Create Category',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // This helper function can now be part of the StatelessWidget
  void _showCreateCategoryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isCreating = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(AppStrings.createNewCategory),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  autofocus: false,
                  decoration: const InputDecoration(
                    labelText: AppStrings.categoryName,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Validation
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.pleaseEnterCategoryName;
                    }

                    final trimmed = value.trim();

                    // Minimum length: 2 characters
                    if (trimmed.length < AppConstants.categoryMinNameLength) {
                      return AppStrings.categoryMinLength;
                    }

                    // Maximum length: 50 characters
                    if (trimmed.length > AppConstants.categoryMaxNameLength) {
                      return AppStrings.categoryMaxLength;
                    }

                    // Sanitize: Remove special characters (keep letters, numbers, spaces)
                    final sanitized = trimmed.replaceAll(RegExp(r'[^\w\s]'), '').trim();
                    if (sanitized.isEmpty) {
                      return AppStrings.enterValidCategoryName;
                    }

                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCreating ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                FilledButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final repo = Provider.of<SongRepository>(
                                context,
                                listen: false);
                            final categoryName = controller.text.trim();

                            setState(() {
                              isCreating = true;
                            });

                            // Check for duplicate category names
                            try {
                              final categories = await repo.getAllCategories();
                              final isDuplicate = categories.any(
                                (cat) => cat.name.toLowerCase() ==
                                    categoryName.toLowerCase(),
                              );

                              if (isDuplicate) {
                                setState(() {
                                  isCreating = false;
                                });
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(
                                      content: Text(AppStrings.categoryExists),
                                    ),
                                  );
                                }
                                return;
                              }

                              await repo.createCategory(categoryName);

                              // Pop the dialog
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            } catch (e) {
                              setState(() {
                                isCreating = false;
                              });
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${AppStrings.errorCreatingCategory}: $e'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(AppStrings.create),
                ),
              ],
            );
          },
        );
      },
    );
  }
}