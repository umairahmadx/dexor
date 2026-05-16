import 'package:flutter/material.dart';

import '../../core/models/tool_entry.dart';
import '../../core/registry/tool_registry.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/command_palette.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final compactMode = AppSettings.instance.compactMode;
    final pagePadding = compactMode ? 16.0 : 24.0;
    final sectionSpacing = compactMode ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevTools Hub'),
        actions: [
          IconButton(
            tooltip: 'Command palette',
            onPressed: () => showSearch(context: context, delegate: ToolSearchDelegate()),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Preferences',
            onPressed: () => Navigator.of(context).pushNamed(ToolRegistry.preferencesRoute),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _Sidebar(onSelectTool: (route) => Navigator.of(context).pushNamed(route))),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: compactMode ? 280 : 300,
                child: _Sidebar(onSelectTool: (route) => Navigator.of(context).pushNamed(route)),
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(pagePadding),
                children: [
                  Text(
                    'Offline-first developer utilities',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All tooling is wired for local navigation now, with each route landing on a dedicated placeholder shell ready for implementation.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: sectionSpacing,
                    runSpacing: sectionSpacing,
                    children: [
                      const _StatusChip(label: '100% Local Processing', color: AppColors.green),
                      _StatusChip(label: '${ToolRegistry.all.length} tools registered', color: theme.colorScheme.primary),
                      const _StatusChip(label: 'Command palette ready', color: AppColors.blue),
                    ],
                  ),
                  SizedBox(height: sectionSpacing * 2),
                  _SectionCard(
                    title: 'Categories',
                    child: Wrap(
                      spacing: sectionSpacing,
                      runSpacing: sectionSpacing,
                      children: [
                        for (final category in ToolRegistry.categories)
                          _CategoryCard(
                            category: category,
                            onTap: () => _openCategory(context, category),
                          ),
                      ],
                    ),
                  ),
                  _SectionCard(
                    title: 'Recent tools',
                    child: Wrap(
                                  spacing: sectionSpacing,
                                  runSpacing: sectionSpacing,
                      children: [
                        for (final entry in ToolRegistry.recentSeed)
                          ActionChip(
                            avatar: Icon(entry.icon, size: 18),
                            label: Text(entry.name),
                            onPressed: () => Navigator.of(context).pushNamed(entry.route),
                          ),
                      ],
                    ),
                  ),
                  _SectionCard(
                    title: 'Featured tools',
                    child: GridView.count(
                      crossAxisCount: MediaQuery.sizeOf(context).width >= 1200 ? 3 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: sectionSpacing,
                      mainAxisSpacing: sectionSpacing,
                      childAspectRatio: 1.8,
                      children: [
                        for (final entry in ToolRegistry.all.take(6))
                          _ToolCard(
                            entry: entry,
                            onTap: () => Navigator.of(context).pushNamed(entry.route),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  _StatusBar(platformLabel: _platformLabelFor(context), contextLabel: 'Dashboard ready · tap any route to open a tool shell'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.onSelectTool});

  final ValueChanged<String> onSelectTool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compactMode = AppSettings.instance.compactMode;

    return Material(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.all(compactMode ? 12 : 16),
        children: [
          Text('CATEGORIES', style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 12),
          for (final category in ToolRegistry.categories)
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(category),
              subtitle: Text('${ToolRegistry.byCategory(category).length} tools'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openCategory(context, category),
            ),
          const SizedBox(height: 16),
          Text('RECENT', style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 12),
          for (final entry in ToolRegistry.recentSeed)
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: Icon(entry.icon, color: theme.colorScheme.primary),
              title: Text(entry.name),
              onTap: () => onSelectTool(entry.route),
            ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pushNamed(ToolRegistry.preferencesRoute),
            icon: const Icon(Icons.settings),
            label: const Text('Preferences'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tools = ToolRegistry.byCategory(category);
    final compactMode = AppSettings.instance.compactMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: compactMode ? 200 : 220,
        padding: EdgeInsets.all(compactMode ? 12.0 : 14.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${tools.length} tools'),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.entry, required this.onTap});

  final ToolEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(entry.icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(entry.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(entry.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.platformLabel, required this.contextLabel});

  final String platformLabel;
  final String contextLabel;

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
          const Icon(Icons.circle, size: 12, color: AppColors.green),
          const SizedBox(width: 10),
          const Text('100% Local Processing'),
          const Spacer(),
          Flexible(child: Text(contextLabel, overflow: TextOverflow.ellipsis)),
          const Spacer(),
          Text(platformLabel),
        ],
      ),
    );
  }
}

String _platformLabelFor(BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.android:
      return 'Android';
    case TargetPlatform.iOS:
      return 'iOS';
    case TargetPlatform.macOS:
      return 'macOS';
    case TargetPlatform.windows:
      return 'Windows';
    case TargetPlatform.linux:
      return 'Linux';
    case TargetPlatform.fuchsia:
      return 'Fuchsia';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(radius: 5, backgroundColor: color),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}

void _openCategory(BuildContext context, String category) {
  final tools = ToolRegistry.byCategory(category);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
       return ListView.separated(
         padding: const EdgeInsets.all(16),
         itemCount: tools.length,
         separatorBuilder: (_, _) => const SizedBox(height: 8),
         itemBuilder: (context, index) {
          final entry = tools[index];
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Icon(entry.icon, color: AppColors.cyan),
            title: Text(entry.name),
            subtitle: Text(entry.description),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.of(context).pushNamed(entry.route);
            },
          );
        },
      );
    },
  );
}


