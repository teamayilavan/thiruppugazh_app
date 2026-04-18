import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/song_repository.dart';
import '../../data/models/song_model.dart';
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

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.addToCategories),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    // Skip 'Favorites' category usually ID 1, assuming explicit check or ID-based check
                    if (category.id == 1) return const SizedBox.shrink();
                    
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
                  },
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

                            if (!mounted) return;

                            widget.onCategoryIdsChanged(currentCategoryIds.toList());

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
