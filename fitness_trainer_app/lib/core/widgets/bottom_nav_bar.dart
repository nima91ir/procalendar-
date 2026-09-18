import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';

class BottomNavBar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int? badgeCount;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tones;
    final s = AppStrings.of(context);
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      indicatorColor: t.primaryLight,
      backgroundColor: Theme.of(context).colorScheme.surface,
      destinations: [
        NavigationDestination(
          icon: badgeCount != null && badgeCount! > 0
              ? Badge(label: Text('${badgeCount!}'), child: const Icon(Icons.dashboard_outlined))
              : const Icon(Icons.dashboard_outlined),
          selectedIcon: badgeCount != null && badgeCount! > 0
              ? Badge(label: Text('${badgeCount!}'), child: const Icon(Icons.dashboard))
              : const Icon(Icons.dashboard),
          label: s.navDashboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: s.navClients,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today),
          label: s.navTemplates,
        ),
        NavigationDestination(
          icon: const Icon(Icons.label_outline),
          selectedIcon: const Icon(Icons.label),
          label: s.navTags,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: s.navSettings,
        ),
      ],
    );
  }
}