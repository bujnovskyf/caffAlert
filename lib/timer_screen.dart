import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'coffee_stats_provider.dart';
import 'l10n/app_localizations.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  String _formatDuration(Duration duration) {
    final seconds = math.max(0, (duration.inMilliseconds / 1000).ceil());
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$remainingSeconds';
  }

  String _formatInterval(Duration duration) {
    if (duration.inHours > 0 && duration.inMinutes.remainder(60) == 0) {
      return '${duration.inHours} h';
    }
    return '${duration.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = context.watch<CoffeeStatsProvider>();
    final localeName = Localizations.localeOf(context).toLanguageTag();

    if (state.isLoading && state.logs.isEmpty) {
      return _LoadingState(label: localizations.loadingData);
    }
    if (state.error == CoffeeStateError.load && state.logs.isEmpty) {
      return _LoadErrorState(
        title: localizations.errorLoadingData,
        retry: localizations.retry,
        onRetry: state.refresh,
      );
    }

    final lastCoffee = state.latestCoffee;
    final lastCoffeeText = lastCoffee == null
        ? localizations.noCoffeeYet
        : DateFormat.yMMMd(localeName)
            .add_Hm()
            .format(lastCoffee.createdAt.toLocal());

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth < 600 ? 16 : 32,
                24,
                constraints.maxWidth < 600 ? 16 : 32,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        liveRegion: true,
                        label: state.isReady
                            ? localizations.coffeeReady
                            : '${localizations.nextCoffeeIn} ${_formatDuration(state.remaining)}. ${localizations.caffLevelValue(state.caffLevelPercent)}',
                        child: _TimerCard(
                          progress: state.timerProgress.clamp(0, 1),
                          caffLevelPercent: state.caffLevelPercent,
                          intervalLabel:
                              _formatInterval(state.caffLevelDuration),
                          isReady: state.isReady,
                          time: _formatDuration(state.remaining),
                          headline: state.isReady
                              ? localizations.coffeeReady
                              : localizations.nextCoffeeIn,
                          subtitle: state.isReady
                              ? localizations.coffeeReadySubtitle
                              : null,
                          lowLevelWarning: localizations.coffeeLowLevelWarning,
                          buttonLabel: localizations.logCoffee,
                          isLoading: state.isMutating,
                          onLogCoffee: () async {
                            final success = await state.addCoffee();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? localizations.coffeeLogged
                                      : localizations.actionFailed,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.foam.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.roast.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              size: 20,
                              color: AppColors.roast,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${localizations.lastCoffee}: ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(text: lastCoffeeText),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.error != null &&
                          state.error != CoffeeStateError.load) ...[
                        const SizedBox(height: 16),
                        _InlineError(
                          message: localizations.actionFailed,
                          dismiss: localizations.dismiss,
                          onDismiss: state.clearError,
                        ),
                      ],
                      if (state.logs.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: state.isMutating
                                ? null
                                : () => _confirmRemove(context, state),
                            icon: const Icon(Icons.undo_rounded),
                            label: Text(localizations.removeLastCoffee),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.45),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
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

  Future<void> _confirmRemove(
    BuildContext context,
    CoffeeStatsProvider state,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.undo_rounded),
        title: Text(localizations.removeCoffeeTitle),
        content: Text(localizations.removeCoffeeBody),
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
    final success = await state.removeLatestCoffee();
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.actionFailed)),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.progress,
    required this.caffLevelPercent,
    required this.intervalLabel,
    required this.isReady,
    required this.time,
    required this.headline,
    required this.subtitle,
    required this.lowLevelWarning,
    required this.buttonLabel,
    required this.isLoading,
    required this.onLogCoffee,
  });

  final double progress;
  final int caffLevelPercent;
  final String intervalLabel;
  final bool isReady;
  final String time;
  final String headline;
  final String? subtitle;
  final String lowLevelWarning;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onLogCoffee;

  @override
  Widget build(BuildContext context) {
    final isLowLevel = !isReady && caffLevelPercent <= 20;
    final isNarrow = MediaQuery.sizeOf(context).width < 340;
    final headerInset = isNarrow ? 16.0 : 26.0;
    final headerPadding = EdgeInsets.symmetric(
      horizontal: isNarrow ? 8 : 12,
      vertical: isNarrow ? 7 : 8,
    );
    final headerIconSize = isNarrow ? 15.0 : 17.0;
    final headerFontSize = isNarrow ? 12.0 : 14.0;
    return Container(
      height: 520,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.foam,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.roast.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFCF7), Color(0xFFE9D9C8)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: 1,
                heightFactor: progress,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFD7A47D), AppColors.caramel],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                color: isReady
                    ? AppColors.error.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
            ),
          ),
          Positioned(
            top: headerInset,
            left: headerInset,
            child: Container(
              padding: headerPadding,
              decoration: BoxDecoration(
                color: isReady
                    ? AppColors.error.withValues(alpha: 0.13)
                    : Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isReady
                      ? AppColors.error.withValues(alpha: 0.28)
                      : AppColors.espresso.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isReady
                        ? Icons.notification_important_outlined
                        : Icons.water_drop_outlined,
                    size: headerIconSize,
                    color: isReady ? AppColors.error : AppColors.espresso,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${AppLocalizations.of(context).caffLevel} $caffLevelPercent%',
                    style: TextStyle(
                      color: isReady ? AppColors.error : AppColors.espresso,
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: headerInset,
            right: headerInset,
            child: Container(
              padding: headerPadding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: headerIconSize),
                  const SizedBox(width: 6),
                  Text(
                    intervalLabel,
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(isNarrow ? 16 : 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isReady
                        ? Icons.notification_important_rounded
                        : Icons.hourglass_top_rounded,
                    size: 36,
                    color: isReady ? AppColors.error : AppColors.espresso,
                  ),
                  const SizedBox(height: 18),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color:
                                isReady ? AppColors.error : AppColors.espresso,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (!isReady) ...[
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 62,
                          height: 1,
                          letterSpacing: -2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.espresso,
                        ),
                      ),
                    ),
                  ] else if (subtitle != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isReady ? AppColors.error : AppColors.espresso,
                        fontWeight: isReady ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                  if (isLowLevel) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.caramel.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        lowLevelWarning,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.espresso,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: isLowLevel ? 20 : 34),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : onLogCoffee,
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(buttonLabel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _LoadErrorState extends StatelessWidget {
  const _LoadErrorState({
    required this.title,
    required this.retry,
    required this.onRetry,
  });

  final String title;
  final String retry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              ElevatedButton(onPressed: onRetry, child: Text(retry)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
    required this.dismiss,
    required this.onDismiss,
  });

  final String message;
  final String dismiss;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        leading: const Icon(Icons.error_outline_rounded),
        title: Text(message),
        trailing: TextButton(onPressed: onDismiss, child: Text(dismiss)),
      ),
    );
  }
}
