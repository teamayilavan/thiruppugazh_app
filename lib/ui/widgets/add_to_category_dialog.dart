import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/song_repository.dart';
import '../../data/models/song_model.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

class AddToCategoryDialog extends StatefulWidget {
  final Song song;
  final List<int> currentCategoryIds;
  final ValueChanged<List<int>> onCategoryIdsChanged;

  const AddToCategoryDialog({
    super.key,
    required this.song,
    required this.currentCategoryIds,
    required this.onCategoryIdsChanged,
  });

  @override
  State<AddToCategoryDialog> createState() => _AddToCategoryDialogState();
}

class _AddToCategoryDialogState extends State<AddToCategoryDialog> {
  bool _isSaving = false;
  String? _newCategoryError;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  String? _validateCategoryName(
    String name,
    List<String> existingNames,
    AppLocalizations l10n,
  ) {
    if (name.isEmpty) {
      return l10n.pleaseEnterCategoryName;
    }
    if (name.length < AppConstants.categoryMinNameLength) {
      return l10n.categoryMinLength;
    }
    if (name.length > AppConstants.categoryMaxNameLength) {
      return l10n.categoryMaxLength;
    }
    final sanitized = name.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (sanitized.isEmpty) {
      return l10n.enterValidCategoryName;
    }
    final isDuplicate = existingNames.any(
      (existing) => existing.toLowerCase() == name.toLowerCase(),
    );
    if (isDuplicate) {
      return l10n.categoryExists;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder(
      future: Provider.of<SongRepository>(context, listen: false).getAllCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final allCategories = snapshot.data!;
        final currentCategoryIds = widget.currentCategoryIds.toSet();
        final pendingNewCategories = <String>[];

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void addPendingCategory() {
              final name = _newCategoryController.text.trim();
              final existingNames = [
                ...allCategories.where((c) => c.id != 1).map((c) => c.name),
                ...pendingNewCategories,
              ];
              final error = _validateCategoryName(name, existingNames, l10n);

              setDialogState(() {
                if (error != null) {
                  _newCategoryError = error;
                } else {
                  pendingNewCategories.add(name);
                  _newCategoryController.clear();
                  _newCategoryError = null;
                }
              });
            }

            return AlertDialog(
              title: Text(l10n.addToCategories),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCategoryController,
                            decoration: InputDecoration(
                              labelText: l10n.categoryName,
                              errorText: _newCategoryError,
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) {
                              if (_newCategoryError != null) {
                                setDialogState(() {
                                  _newCategoryError = null;
                                });
                              }
                            },
                            onSubmitted: (_) => addPendingCategory(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: l10n.create,
                          onPressed: addPendingCategory,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ...allCategories.where((c) => c.id != 1).map((category) {
                          final isSelected = currentCategoryIds.contains(category.id);
                          return CheckboxListTile(
                            title: Text(category.name),
                            value: isSelected,
                            onChanged: (bool? selected) {
                              setDialogState(() {
                                if (selected == true) {
                                  currentCategoryIds.add(category.id!);
                                } else {
                                  currentCategoryIds.remove(category.id!);
                                }
                              });
                            },
                          );
                        }),
                        ...pendingNewCategories.map((name) {
                          return ListTile(
                            leading: const Icon(Icons.fiber_new_outlined),
                            title: Text(name),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setDialogState(() {
                                  pendingNewCategories.remove(name);
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final repo = Provider.of<SongRepository>(context, listen: false);
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          setDialogState(() {
                            _isSaving = true;
                          });

                          try {
                            for (final cat in allCategories) {
                              if (cat.id != 1) {
                                if (currentCategoryIds.contains(cat.id)) {
                                  await repo.addSongToCategory(
                                      widget.song.id, cat.id!);
                                } else {
                                  await repo.removeSongFromCategory(
                                    widget.song.id,
                                    cat.id!,
                                  );
                                }
                              }
                            }

                            final newlyCreatedIds = <int>[];
                            for (final name in pendingNewCategories) {
                              final newId = await repo.createCategory(name);
                              await repo.addSongToCategory(widget.song.id, newId);
                              newlyCreatedIds.add(newId);
                            }

                            if (!mounted) return;

                            widget.onCategoryIdsChanged([
                              ...currentCategoryIds,
                              ...newlyCreatedIds,
                            ]);

                            navigator.pop();

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    l10n.categoriesUpdated(widget.song.title),
                                  ),
                                ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() {
                              _isSaving = false;
                            });
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('${l10n.errorUpdatingCategories}: $e'),
                              ),
                            );
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
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
}
