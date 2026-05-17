import 'package:flutter/material.dart';

import '../../core/settings/app_settings.dart';
import '../../core/registry/tool_registry.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final AppSettings _settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compactMode = _settings.compactMode;
    final pagePadding = compactMode ? 16.0 : 24.0;
    final sectionGap = compactMode ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(ToolRegistry.homeRoute),
            child: const Text('Home'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(pagePadding),
        children: [
          Text(
            'App Preferences',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure the shell locally. Theme changes take effect instantly and other controls are wired as interactive placeholders.',
            style: theme.textTheme.bodyLarge,
          ),
          SizedBox(height: sectionGap),
          _SectionCard(
            title: 'Appearance',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ThemeChoice(
                      label: 'System',
                      selected: _settings.themeMode == ThemeMode.system,
                      onSelected: () =>
                          _settings.setThemeMode(ThemeMode.system),
                    ),
                    _ThemeChoice(
                      label: 'Light',
                      selected: _settings.themeMode == ThemeMode.light,
                      onSelected: () => _settings.setThemeMode(ThemeMode.light),
                    ),
                    _ThemeChoice(
                      label: 'Dark',
                      selected: _settings.themeMode == ThemeMode.dark,
                      onSelected: () => _settings.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Accent color',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (
                      var index = 0;
                      index < AppSettings.accentSwatches.length;
                      index++
                    )
                      _AccentChoice(
                        label: AppSettings.accentLabels[index],
                        color: AppSettings.accentSwatches[index],
                        selected: _settings.accentIndex == index,
                        onSelected: () =>
                            setState(() => _settings.setAccentIndex(index)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Font scale',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Slider(
                  value: _settings.fontScale,
                  min: 0.9,
                  max: 1.2,
                  divisions: 3,
                  label: _settings.fontScale.toStringAsFixed(2),
                  onChanged: (value) =>
                      setState(() => _settings.setFontScale(value)),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Compact mode'),
                  subtitle: const Text(
                    'Tightens cards and panels for denser layouts.',
                  ),
                  value: _settings.compactMode,
                  onChanged: (value) =>
                      setState(() => _settings.toggleCompactMode(value)),
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Editor',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _BulletedList([
                  'Indent size and tab settings',
                  'Word wrap and line numbers',
                  'Auto-format on paste',
                ]),
              ],
            ),
          ),
          _SectionCard(
            title: 'Privacy',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Local history would be cleared here.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear history'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export settings placeholder triggered.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('Export settings'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Import settings placeholder triggered.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Import settings'),
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'About',
            child: const _BulletedList([
              'Version and build number',
              'Changelog and licenses',
              'Offline-first processing only',
            ]),
          ),
          _SectionCard(
            title: 'Keyboard shortcuts',
            child: const _BulletedList([
              'Ctrl/Cmd+K to open the command palette',
              'Esc to close overlays',
              'Enter to open selected tool',
            ]),
          ),
          _SectionCard(
            title: 'Platform-specific',
            child: const _BulletedList([
              'Web drag-and-drop and PWA support',
              'Desktop keyboard shortcuts and window integration',
              'Mobile share intents and navigation bar',
            ]),
          ),
          SizedBox(height: compactMode ? 8 : 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {
                setState(() {
                  _settings.reset();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults.')),
                );
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset all preferences'),
            ),
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
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.14),
      onSelected: (_) => onSelected(),
    );
  }
}

class _AccentChoice extends StatelessWidget {
  const _AccentChoice({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: CircleAvatar(radius: 5, backgroundColor: color),
      selected: selected,
      selectedColor: color.withValues(alpha: 0.18),
      onSelected: (_) => onSelected(),
    );
  }
}

class _BulletedList extends StatelessWidget {
  const _BulletedList(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}
