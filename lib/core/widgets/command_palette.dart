import 'package:flutter/material.dart';

import '../registry/tool_registry.dart';

class ToolSearchDelegate extends SearchDelegate<void> {
  @override
  String? get searchFieldLabel => 'Search tools';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults(context);

  Widget _buildResults(BuildContext context) {
    final results = ToolRegistry.search(query);

    if (results.isEmpty) {
      return const Center(
        child: Text('No tools found.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
            foregroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(entry.icon),
          ),
          title: Text(entry.name),
          subtitle: Text('${entry.category} · ${entry.description}'),
          trailing: entry.isNew ? const Chip(label: Text('NEW')) : null,
          onTap: () {
            close(context, null);
            Navigator.of(context).pushNamed(entry.route);
          },
        );
      },
    );
  }
}

