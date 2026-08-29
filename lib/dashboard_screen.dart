import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'coffee_metrics.dart';
import 'coffee_stats_provider.dart';
import 'l10n/app_localizations.dart';
import 'models/coffee_log.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatTime(CoffeeLog? log, String locale, String fallback) {
    if (log == null) return fallback;
    return DateFormat.Hm(locale).format(log.createdAt.toLocal());
  }

  String _coffeeStatus(AppLocalizations localizations, CoffeeStatus status) {
    return switch (status) {
      CoffeeStatus.noCoffeeToday => localizations.coffeeStatusNoCoffeeToday,
      CoffeeStatus.calm => localizations.coffeeStatusCalm,
      CoffeeStatus.coffeeShift => localizations.coffeeStatusCoffeeShift,
      CoffeeStatus.espressoDrive => localizations.coffeeStatusEspressoDrive,
      CoffeeStatus.legend => localizations.coffeeStatusLegend,
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = context.watch<CoffeeStatsProvider>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final displayName = state.profile?.displayName?.trim();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 32.0;
            final contentWidth = (constraints.maxWidth - horizontalPadding * 2)
                .clamp(0.0, 1040.0)
                .toDouble();
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (displayName != null && displayName.isNotEmpty) ...[
                        Text(
                          localizations.welcomeName(displayName),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.roast,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        localizations.statsTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.espresso,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.statsSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.roast,
                            ),
                      ),
                      const SizedBox(height: 28),
                      if (state.logs.isEmpty && !state.isLoading)
                        _EmptyStats(
                          title: localizations.emptyStatsTitle,
                          body: localizations.emptyStatsBody,
                        )
                      else
                        _StatsGrid(
                          width: contentWidth,
                          cards: [
                            _StatData(
                              icon: Icons.today_rounded,
                              label: localizations.coffeesToday,
                              value: '${state.dailyCoffees}',
                              prominent: true,
                            ),
                            _StatData(
                              icon: Icons.auto_awesome_rounded,
                              label: localizations.coffeeStatus,
                              value: _coffeeStatus(
                                localizations,
                                state.coffeeStatus,
                              ),
                            ),
                            _StatData(
                              icon: Icons.wb_sunny_outlined,
                              label: localizations.firstCoffeeToday,
                              value: _formatTime(
                                state.firstCoffeeToday,
                                locale,
                                localizations.notAvailable,
                              ),
                            ),
                            _StatData(
                              icon: Icons.nights_stay_outlined,
                              label: localizations.lastCoffeeToday,
                              value: _formatTime(
                                state.lastCoffeeToday,
                                locale,
                                localizations.notAvailable,
                              ),
                            ),
                            _StatData(
                              icon: Icons.timelapse_rounded,
                              label: localizations.averageIntervalToday,
                              value: state.averageIntervalToday == null
                                  ? localizations.notAvailable
                                  : localizations.minutesValue(
                                      (state.averageIntervalToday!.inMinutes)
                                          .toString(),
                                    ),
                            ),
                            _StatData(
                              icon: Icons.calendar_month_outlined,
                              label: localizations.coffeesThisMonth,
                              value: '${state.monthlyCoffees}',
                            ),
                            _StatData(
                              icon: Icons.all_inclusive_rounded,
                              label: localizations.totalCoffees,
                              value: '${state.totalCoffees}',
                            ),
                          ],
                        ),
                      if (state.editableCoffees.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _RecentCoffeeSection(
                          coffees: state.editableCoffees,
                          locale: locale,
                          title: localizations.editRecentCoffeesTitle,
                          editTooltip: localizations.editCoffeeTimeAction,
                          removeTooltip: localizations.remove,
                          isLoading: state.isMutating,
                          onEdit: (coffee) => _editCoffeeTime(
                            context,
                            state,
                            coffee,
                          ),
                          onRemove: (coffee) => _confirmRemoveCoffee(
                            context,
                            state,
                            coffee,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _editCoffeeTime(
    BuildContext context,
    CoffeeStatsProvider state,
    CoffeeLog coffee,
  ) async {
    if (!state.canEditCoffee(coffee)) return;

    final localizations = AppLocalizations.of(context);
    final now = state.now.toLocal();
    final earliestAllowed = now.subtract(CoffeeStatsProvider.coffeeEditWindow);
    final currentTime = coffee.createdAt.toLocal();
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateUtils.dateOnly(earliestAllowed),
      lastDate: DateUtils.dateOnly(now),
      initialDate: DateUtils.dateOnly(currentTime),
      helpText: localizations.editCoffeeTimeTitle,
    );
    if (selectedDate == null || !context.mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
      helpText: localizations.editCoffeeTimeTitle,
    );
    if (selectedTime == null || !context.mounted) return;

    final correctedTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (correctedTime.isBefore(earliestAllowed) || correctedTime.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.editCoffeeTimeOutOfRange)),
      );
      return;
    }

    final success = await state.updateCoffeeTime(coffee, correctedTime);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? localizations.coffeeTimeUpdated
              : localizations.actionFailed,
        ),
      ),
    );
  }

  Future<void> _confirmRemoveCoffee(
    BuildContext context,
    CoffeeStatsProvider state,
    CoffeeLog coffee,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: Text(localizations.removeCoffeeEntryTitle),
        content: Text(localizations.removeCoffeeEntryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(localizations.remove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await state.removeCoffee(coffee);
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.actionFailed)),
    );
  }
}

class _StatData {
  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    this.prominent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool prominent;
}

class _RecentCoffeeSection extends StatelessWidget {
  const _RecentCoffeeSection({
    required this.coffees,
    required this.locale,
    required this.title,
    required this.editTooltip,
    required this.removeTooltip,
    required this.isLoading,
    required this.onEdit,
    required this.onRemove,
  });

  final List<CoffeeLog> coffees;
  final String locale;
  final String title;
  final String editTooltip;
  final String removeTooltip;
  final bool isLoading;
  final ValueChanged<CoffeeLog> onEdit;
  final ValueChanged<CoffeeLog> onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.espresso,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            ...coffees.map(
              (coffee) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.coffee_outlined),
                title: Text(
                  DateFormat.yMMMd(locale)
                      .add_Hm()
                      .format(coffee.createdAt.toLocal()),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: isLoading ? null : () => onEdit(coffee),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: editTooltip,
                    ),
                    IconButton(
                      onPressed: isLoading ? null : () => onRemove(coffee),
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: removeTooltip,
                      color: AppColors.error,
                    ),
                  ],
                ),
                onTap: isLoading ? null : () => onEdit(coffee),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.width, required this.cards});

  final double width;
  final List<_StatData> cards;

  @override
  Widget build(BuildContext context) {
    // Stats are deliberately compact: even the narrowest phone can show two
    // small, glanceable values next to each other.
    final columns = width >= 960 ? 3 : 2;
    const gap = 14.0;
    final availableWidth = width > 1040 ? 1040.0 : width;
    final cardWidth = (availableWidth - gap * (columns - 1)) / columns;
    final cardHeight = width < 360 ? 172.0 : 150.0;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: cards
          .map(
            (data) => SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _StatCard(data: data),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    return Card(
      color: data.prominent ? AppColors.espresso : null,
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              data.icon,
              color: data.prominent ? AppColors.crema : AppColors.roast,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: data.prominent
                              ? Colors.white
                              : AppColors.espresso,
                          fontFamily: 'IBMPlexMono',
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.label,
                  style: TextStyle(
                    color: data.prominent ? AppColors.crema : AppColors.roast,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.caramel.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.coffee_outlined, color: AppColors.roast),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
