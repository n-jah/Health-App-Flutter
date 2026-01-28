import 'package:flutter/material.dart';
import '../../services/health_service.dart';
import '../../core/models/health_data_type.dart';
import '../permissions/permissions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HealthService _healthService = HealthService();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar.medium(title: const Text('Settings')),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Health Data section
              Text(
                'Health Data',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enable or disable specific health metrics',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: HealthDataTypeInfo.all.map((info) {
                    return _DataTypeToggle(
                      info: info,
                      enabled:
                          _healthService.enabledTypes[info.category] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _healthService.toggleDataType(info.category, value);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Appearance section
              Text(
                'Appearance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    _ThemeOption(
                      title: 'Light',
                      icon: Icons.light_mode,
                      selected: _themeMode == ThemeMode.light,
                      onTap: () => setState(() => _themeMode = ThemeMode.light),
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      title: 'Dark',
                      icon: Icons.dark_mode,
                      selected: _themeMode == ThemeMode.dark,
                      onTap: () => setState(() => _themeMode = ThemeMode.dark),
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      title: 'System',
                      icon: Icons.brightness_auto,
                      selected: _themeMode == ThemeMode.system,
                      onTap: () =>
                          setState(() => _themeMode = ThemeMode.system),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Permissions section
              Text(
                'Permissions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _healthService.isUsingDemoData
                    ? 'Currently using demo data. Follow steps below to use real data.'
                    : 'Using real health data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _healthService.isUsingDemoData
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Setup Guide'),
                      subtitle: const Text('How to get real health data'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const _SetupGuideDialog(),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Grant Permissions'),
                      subtitle: const Text('Allow health data access'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final granted = await _healthService
                            .requestPermissions();

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              _healthService.isUsingDemoData
                                  ? 'Permissions granted but no health data found. Install Health Connect and a health app.'
                                  : 'Permissions granted! Using real health data.',
                            ),
                            backgroundColor: _healthService.isUsingDemoData
                                ? Colors.orange
                                : Colors.green,
                            duration: const Duration(seconds: 4),
                          ),
                        );

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // About section
              Text(
                'About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Version'),
                      trailing: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to privacy policy
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }
}

class _DataTypeToggle extends StatelessWidget {
  final HealthDataTypeInfo info;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _DataTypeToggle({
    required this.info,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: info.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(info.icon, color: info.color, size: 20),
      ),
      title: Text(info.title),
      subtitle: Text('Track ${info.title.toLowerCase()} data'),
      trailing: Switch(value: enabled, onChanged: onChanged),
    );
  }
}

class _SetupGuideDialog extends StatelessWidget {
  const _SetupGuideDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Get Real Health Data'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To use real health data instead of demo data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStep(
              '1',
              'Install Health Connect',
              'Open Play Store and install "Health Connect by Google"',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '2',
              'Install a Health App',
              'Install Mi Fitness, Google Fit, or another health tracking app',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '3',
              'Record Some Data',
              'Walk around or manually add health data in your health app',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '4',
              'Grant Permissions',
              'Tap "Grant Permissions" in Settings and allow all health data access',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '5',
              'Restart App',
              'Close and reopen HealthTrack to load real data',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
