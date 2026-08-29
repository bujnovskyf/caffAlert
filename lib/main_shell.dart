import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'dashboard_screen.dart';
import 'l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'timer_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    required this.userEmail,
    super.key,
  });

  final String userEmail;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.hourglass_bottom_rounded),
        selectedIcon: const Icon(Icons.hourglass_top_rounded),
        label: localizations.timerNavigation,
      ),
      NavigationDestination(
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights_rounded),
        label: localizations.statsNavigation,
      ),
      NavigationDestination(
        icon: const Icon(Icons.tune_rounded),
        selectedIcon: const Icon(Icons.tune),
        label: localizations.settingsNavigation,
      ),
    ];
    final pages = [
      const TimerScreen(),
      const DashboardScreen(),
      SettingsScreen(userEmail: widget.userEmail),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;
        final content = IndexedStack(index: _selectedIndex, children: pages);

        if (!useRail) {
          return Scaffold(
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              labelBehavior: constraints.maxWidth < 360
                  ? NavigationDestinationLabelBehavior.alwaysHide
                  : NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (value) {
                setState(() => _selectedIndex = value);
              },
              destinations: destinations,
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 0, 16),
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 1180,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() => _selectedIndex = value);
                    },
                    backgroundColor: AppColors.foam.withValues(alpha: 0.66),
                    indicatorColor: AppColors.caramel.withValues(alpha: 0.25),
                    leading: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: _BrandMark(),
                    ),
                    destinations: destinations
                        .map(
                          (item) => NavigationRailDestination(
                            icon: item.icon,
                            selectedIcon: item.selectedIcon,
                            label: Text(item.label),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppLocalizations.of(context).appTitle,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.espresso,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.coffee_rounded, color: Colors.white),
      ),
    );
  }
}
