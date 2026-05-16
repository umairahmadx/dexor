import 'package:flutter/material.dart';

import '../../core/models/tool_entry.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';

class ToolPlaceholderScreen extends StatelessWidget {
  const ToolPlaceholderScreen({super.key, required this.entry});

  final ToolEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final compactMode = AppSettings.instance.compactMode;
    final accent = entry.accentOverride ?? colorScheme.primary;
    final pagePadding = compactMode ? 16.0 : 24.0;
    final gap = compactMode ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.name),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Home'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(entry.icon, color: accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text('${entry.category} · ${entry.route}'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),
              Wrap(
                spacing: gap - 2,
                runSpacing: gap - 2,
                children: [
                  _Badge(label: 'Offline-first', color: AppColors.green),
                  _Badge(label: 'Placeholder scaffold', color: accent),
                  if (entry.isNew) const _Badge(label: 'NEW', color: AppColors.amber),
                ],
              ),
              SizedBox(height: gap),
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width >= 1000 ? 3 : 1,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                  childAspectRatio: 1.5,
                  children: [
                    _Panel(
                      title: 'What will live here',
                      body: Text(
                        entry.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    _Panel(
                      title: 'Implementation status',
                      body: const Text(
                        'This route is wired and ready for the real tool logic to be plugged in without changing navigation.',
                      ),
                    ),
                    _Panel(
                      title: 'Next integration steps',
                      body: Text(
                        'Connect file handling, persistence, and on-device processing for ${entry.name.toLowerCase()}.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: gap),
              _StatusBar(accent: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      avatar: CircleAvatar(radius: 5, backgroundColor: color),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: accent),
          const SizedBox(width: 10),
          const Text('Offline route active'),
          const Spacer(),
          Text(MediaQuery.of(context).size.width.toStringAsFixed(0)),
          const SizedBox(width: 12),
          const Text('px viewport'),
        ],
      ),
    );
  }
}



