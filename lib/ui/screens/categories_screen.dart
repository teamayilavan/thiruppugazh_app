import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/song_repository.dart';
import 'song_list_screen.dart';
import '../widgets/error_display_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_constants.dart';

// ✨ It's now a simpler StatelessWidget
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.categories)),
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
                  errorMessage: l10n.failedToLoadCategories,
                  onRetry: null,
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(l10n.noCategoriesFound));
              }

              final categories = snapshot.data!;
              // Split categories into favorites and custom
              final favorites = categories.where((c) => c.id == 1).toList();
              final customCategories = categories.where((c) => c.id != 1).toList();

              return Scrollbar(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                  children: [
                    // Favorites Section
                    if (favorites.isNotEmpty) ...favorites.map((category) => _buildCategoryTile(context, category)),
                    
                    if (favorites.isNotEmpty) const Divider(),

                    // Custom Categories Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          l10n.customCategories,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),

                    // Custom Categories List or Empty State
                    if (customCategories.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            l10n.noCustomCategories,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                    else
                      ...customCategories.map((category) => _buildCategoryTile(context, category)),
                  ],
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
          heroTag: 'add_category_fab',
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

  Widget _buildCategoryTile(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: '${category.name} category',
      hint: '${category.songCount} songs',
      child: ListTile(
        leading: Icon(
          category.id == 1
              ? Icons.favorite
              : Icons.folder_open_outlined,
        ),
        title: Text(category.id == 1 ? l10n.favorites : category.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.songCount.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (category.id != 1) ...[ // ID 1 is Favorites
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'rename') {
                    _showRenameCategoryDialog(context, category);
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, category);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.rename),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SongListScreen(category: category),
            ),
          );
        },
      ),
    );
  }

  // This helper function can now be part of the StatelessWidget
  void _showCreateCategoryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isCreating = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.createNewCategory),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Validation
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterCategoryName;
                    }

                    final trimmed = value.trim();

                    // Minimum length: 2 characters
                    if (trimmed.length < AppConstants.categoryMinNameLength) {
                      return l10n.categoryMinLength;
                    }

                    // Maximum length: 50 characters
                    if (trimmed.length > AppConstants.categoryMaxNameLength) {
                      return l10n.categoryMaxLength;
                    }

                    // Sanitize: Remove special characters (keep letters, numbers, spaces)
                    final sanitized = trimmed.replaceAll(RegExp(r'[^\w\s]'), '').trim();
                    if (sanitized.isEmpty) {
                      return l10n.enterValidCategoryName;
                    }

                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCreating ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
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
                                    SnackBar(
                                      content: Text(l10n.categoryExists),
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
                                        '${l10n.errorCreatingCategory}: $e'),
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
                      : Text(l10n.create),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameCategoryDialog(BuildContext context, Category category) {
    final TextEditingController controller = TextEditingController(text: category.name);
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.renameCategory),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterCategoryName;
                    }
                    final trimmed = value.trim();
                    if (trimmed.length < AppConstants.categoryMinNameLength) {
                      return l10n.categoryMinLength;
                    }
                    if (trimmed.length > AppConstants.categoryMaxNameLength) {
                      return l10n.categoryMaxLength;
                    }
                    final sanitized = trimmed.replaceAll(RegExp(r'[^\w\s]'), '').trim();
                    if (sanitized.isEmpty) {
                      return l10n.enterValidCategoryName;
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final repo = Provider.of<SongRepository>(context, listen: false);
                            final newName = controller.text.trim();

                            if (newName == category.name) {
                              Navigator.of(dialogContext).pop();
                              return;
                            }

                            setState(() {
                              isSaving = true;
                            });

                            try {
                              // Check for duplicates
                              final categories = await repo.getAllCategories();
                              final isDuplicate = categories.any(
                                (cat) => cat.id != category.id && 
                                        cat.name.toLowerCase() == newName.toLowerCase(),
                              );

                              if (isDuplicate) {
                                setState(() {
                                  isSaving = false;
                                });
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    SnackBar(content: Text(l10n.categoryExists)),
                                  );
                                }
                                return;
                              }

                              await repo.updateCategory(category.id!, newName);

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            } catch (e) {
                              setState(() {
                                isSaving = false;
                              });
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(content: Text('Error updating category: $e')),
                                );
                              }
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteCategoryTitle),
          content: Text(l10n.deleteCategoryConfirmation(category.name)),
          actions: [
             TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                 final repo = Provider.of<SongRepository>(context, listen: false);
                 await repo.deleteCategory(category.id!);
                 if (dialogContext.mounted) {
                   Navigator.of(dialogContext).pop();
                 }
              },
               style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}