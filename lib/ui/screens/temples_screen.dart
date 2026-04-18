import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import 'temple_songs_screen.dart';
import '../../l10n/app_localizations.dart';

class TemplesScreen extends StatefulWidget {
  const TemplesScreen({super.key});

  @override
  State<TemplesScreen> createState() => _TemplesScreenState();
}

class _TemplesScreenState extends State<TemplesScreen> {
  late Future<List<Map<String, dynamic>>> _templesFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshTemples();
  }

  void _refreshTemples() {
    setState(() {
      _templesFuture = DatabaseHelper().getAllTemples();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.temples),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _templesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('${AppLocalizations.of(context)!.anErrorOccurred}: ${snapshot.error}'));
          }

          final temples = snapshot.data ?? [];

          if (temples.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noTemplesFound));
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            thickness: 10.0,
            radius: const Radius.circular(10.0),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: temples.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final temple = temples[index];
                final name = temple['name'] as String;
                final count = temple['song_count'] as int;

                return ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  title: Text(name),
                  trailing: Text(
                    '$count',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TempleSongsScreen(templeName: name),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
