import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/state/app_settings.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<AppSettings>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _SectionHeader(l10n.language),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'fr', label: Text(l10n.french)),
                ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                ButtonSegment(value: 'en', label: Text(l10n.english)),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (sel) {
                final code = sel.first;
                context.read<AppSettings>().setLocale(Locale(code));
              },
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.themeSystem),
                  icon: const Icon(Icons.brightness_auto, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode, size: 18),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (sel) {
                context.read<AppSettings>().setThemeMode(sel.first);
              },
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.searchRadius),
          ...AppConfig.radiusOptionsMeters.map((m) {
            final km = (m / 1000).toStringAsFixed(m % 1000 == 0 ? 0 : 1);
            final selected = settings.searchRadiusMeters == m;
            return ListTile(
              leading: Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              title: Text(l10n.radiusKm(km)),
              selected: selected,
              onTap: () =>
                  context.read<AppSettings>().setSearchRadiusMeters(m),
            );
          }),
          const Divider(),
          _SectionHeader(l10n.filters),
          SwitchListTile(
            title: Text(l10n.openOnly),
            value: settings.openOnlyFilter,
            onChanged: (v) =>
                context.read<AppSettings>().setOpenOnlyFilter(v),
          ),
          SwitchListTile(
            title: Text(l10n.includeUnknownHours),
            subtitle: Text(l10n.includeUnknownHoursSubtitle),
            value: settings.includeUnknownWhenOpenOnly,
            onChanged: (v) => context
                .read<AppSettings>()
                .setIncludeUnknownWhenOpenOnly(v),
          ),
          const Divider(),
          _SectionHeader(l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appName),
            subtitle: Text(l10n.appTagline),
          ),
          ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: Text(l10n.version),
            subtitle: const Text(AppConfig.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: Text(l10n.poweredBy),
            subtitle: Text(l10n.dataSource),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: Text(l10n.madeWith),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
