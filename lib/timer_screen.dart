import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'coffee_stats_provider.dart';
import 'coffee_time_editor.dart';
import 'l10n/app_localizations.dart';
import 'models/coffee_log.dart';
import 'time_format.dart';

/// The visual state of the CAF gauge.
enum CafGaugeMode { empty, running, low, zero }

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  static const lowLevelThreshold = 20;

  static String formatCountdown(Duration duration) {
    final seconds = math.max(0, (duration.inMilliseconds / 1000).ceil());
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$remainingSeconds';
  }

  static String formatInterval(Duration duration) {
    if (duration.inHours > 0 && duration.inMinutes.remainder(60) == 0) {
      return '${duration.inHours} h';
    }
    return '${duration.inMinutes} min';
  }

  static CafGaugeMode modeFor({
    required bool hasCoffee,
    required bool isReady,
    required int percent,
  }) {
    if (!hasCoffee) return CafGaugeMode.empty;
    if (isReady) return CafGaugeMode.zero;
    if (percent <= lowLevelThreshold) return CafGaugeMode.low;
    return CafGaugeMode.running;
  }

  /// The one useful line under the gauge: when CAF reaches zero, or, once it
  /// has, when the latest coffee was logged.
  static String? statusLine({
    required AppLocalizations localizations,
    required String locale,
    required DateTime now,
    required CoffeeLog? latestCoffee,
    required DateTime? zeroAt,
    bool alwaysUse24HourFormat = false,
  }) {
    if (latestCoffee == null || zeroAt == null) return null;
    final localNow = now.toLocal();
    final localZero = zeroAt.toLocal();
    final timeFormat = AppTimeFormat.time(
      locale,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
    if (localZero.isAfter(localNow)) {
      final time = timeFormat.format(localZero);
      return DateUtils.isSameDay(localZero, localNow)
          ? localizations.cafZeroAt(time)
          : localizations.cafZeroTomorrowAt(time);
    }
    final localLatest = latestCoffee.createdAt.toLocal();
    if (DateUtils.isSameDay(localLatest, localNow)) {
      return localizations.lastCoffeeAt(timeFormat.format(localLatest));
    }
    return localizations.lastCoffeeOn(
      AppTimeFormat.withTime(
        DateFormat.MMMd(locale),
        locale,
        alwaysUse24HourFormat: alwaysUse24HourFormat,
      ).format(localLatest),
    );
  }

  /// End of the CAF window of a coffee from an earlier day that still runs
  /// past today's midnight (local time), or null. Today's timeline shows it as
  /// a window clipped at 0:00, without a dot.
  static DateTime? carryOverEnd(
    List<CoffeeLog> logs,
    DateTime now,
    Duration duration,
  ) {
    final localNow = now.toLocal();
    final midnight = DateTime(localNow.year, localNow.month, localNow.day);
    DateTime? latestBefore;
    for (final log in logs) {
      final time = log.createdAt.toLocal();
      if (time.isBefore(midnight) &&
          (latestBefore == null || time.isAfter(latestBefore))) {
        latestBefore = time;
      }
    }
    if (latestBefore == null) return null;
    final end = latestBefore.add(duration);
    return end.isAfter(midnight) ? end : null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = context.watch<CoffeeStatsProvider>();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final use24h = AppTimeFormat.alwaysUse24HourFormatOf(context);

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

    final latestCoffee = state.latestCoffee;
    final percent = state.caffLevelPercent;
    final mode = modeFor(
      hasCoffee: latestCoffee != null,
      isReady: state.isReady,
      percent: percent,
    );
    final line = statusLine(
      localizations: localizations,
      locale: locale,
      now: state.now,
      latestCoffee: latestCoffee,
      zeroAt: state.caffZeroAt,
      alwaysUse24HourFormat: use24h,
    );
    final semanticsLabel = switch (mode) {
      CafGaugeMode.empty =>
        '${localizations.noCoffeeYet}. ${localizations.caffEmptyHint}',
      CafGaugeMode.zero =>
        '${localizations.caffZeroTitle}. ${line ?? ''}. ${localizations.caffZeroHint}',
      // Minute precision on purpose: a live region must not chatter every
      // second.
      _ => '${localizations.caffLevelValue(percent)}. ${line ?? ''}',
    };

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCard(
                        mode: mode,
                        progress: state.timerProgress.clamp(0.0, 1.0),
                        countdown: formatCountdown(state.remaining),
                        statusLine: line,
                        semanticsLabel: semanticsLabel,
                        intervalLabel: localizations.caffCountdownLength(
                          formatInterval(state.caffLevelDuration),
                        ),
                        isLoading: state.isMutating,
                        onLogCoffee: () => _logCoffee(context, state),
                        onEditLastCoffeeTime: latestCoffee != null &&
                                state.canEditCoffee(latestCoffee)
                            ? () => CoffeeTimeEditor.edit(
                                  context,
                                  state,
                                  latestCoffee,
                                )
                            : null,
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
                      const SizedBox(height: 16),
                      _TodayCard(
                        coffees: state.coffeesToday,
                        carryOverEnd: carryOverEnd(
                          state.logs,
                          state.now,
                          state.caffLevelDuration,
                        ),
                        now: state.now,
                        duration: state.caffLevelDuration,
                        locale: locale,
                        alwaysUse24HourFormat: use24h,
                      ),
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

  Future<void> _logCoffee(
    BuildContext context,
    CoffeeStatsProvider state,
  ) async {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await state.addCoffee();
    if (!context.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success ? localizations.coffeeLogged : localizations.actionFailed,
          ),
          duration: const Duration(seconds: 6),
          action: success
              ? SnackBarAction(
                  label: localizations.undo,
                  onPressed: () async {
                    final undone = await state.undoLastAddedCoffee();
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            undone
                                ? localizations.coffeeUndone
                                : localizations.actionFailed,
                          ),
                        ),
                      );
                  },
                )
              : null,
        ),
      );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.mode,
    required this.progress,
    required this.countdown,
    required this.statusLine,
    required this.semanticsLabel,
    required this.intervalLabel,
    required this.isLoading,
    required this.onLogCoffee,
    this.onEditLastCoffeeTime,
  });

  final CafGaugeMode mode;
  final double progress;
  final String countdown;
  final String? statusLine;
  final String semanticsLabel;
  final String intervalLabel;
  final bool isLoading;
  final VoidCallback onLogCoffee;

  /// Null when there is no coffee from the last 24 hours to correct.
  final VoidCallback? onEditLastCoffeeTime;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isLow = mode == CafGaugeMode.low;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.hero),
        border: Border.all(color: AppColors.roast.withValues(alpha: 0.10)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.foam, Color(0xFFF8EEE4)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          final padding = isNarrow ? 16.0 : 24.0;
          final gaugeSize =
              math.min(constraints.maxWidth - padding * 2, 300.0).toDouble();
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizations.timerEyebrow,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.eyebrow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Pill(icon: Icons.schedule_rounded, label: intervalLabel),
                  ],
                ),
                SizedBox(height: isNarrow ? 12 : 16),
                Center(
                  child: Semantics(
                    liveRegion: true,
                    label: semanticsLabel,
                    child: ExcludeSemantics(
                      child: CafGauge(
                        size: gaugeSize,
                        mode: mode,
                        progress: progress,
                        countdown: countdown,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isNarrow ? 14 : 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    statusLine ?? localizations.caffEmptyHint,
                    key: ValueKey(statusLine ?? 'empty'),
                    textAlign: TextAlign.center,
                    style: statusLine == null
                        ? textTheme.bodyLarge?.copyWith(color: AppColors.roast)
                        : textTheme.titleMedium?.copyWith(
                            color: isLow ? AppColors.ember : AppColors.espresso,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                ),
                SizedBox(height: isNarrow ? 16 : 22),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : onLogCoffee,
                        icon: isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.coffee_rounded),
                        label: Text(localizations.logCoffee),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (onEditLastCoffeeTime != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : onEditLastCoffeeTime,
                      child: Text(
                        localizations.editTime,
                        semanticsLabel: localizations.editLastCoffeeTime,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Circular CAF gauge: a caramel → espresso ring that empties over four hours
/// with a soft "cup" fill inside.
class CafGauge extends StatelessWidget {
  const CafGauge({
    required this.size,
    required this.mode,
    required this.progress,
    required this.countdown,
    super.key,
  });

  final double size;
  final CafGaugeMode mode;
  final double progress;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final target = mode == CafGaugeMode.empty ? 0.0 : progress;
    final isLow = mode == CafGaugeMode.low;
    final accent = isLow ? AppColors.ember : AppColors.espresso;
    final innerSize = size * 0.70;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: target),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final shownPercent = (value * 100).round().clamp(0, 100);
        final Widget center = switch (mode) {
          CafGaugeMode.empty => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.coffee_outlined,
                  size: 44,
                  color: AppColors.caramel,
                ),
                const SizedBox(height: 10),
                Text(
                  localizations.noCoffeeYet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.espresso,
                  ),
                ),
              ],
            ),
          CafGaugeMode.zero => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PercentText(
                  percent: shownPercent,
                  color: AppColors.roast.withValues(alpha: 0.45),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.caffZeroTitle,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.espresso,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations.caffZeroHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.roast),
                ),
              ],
            ),
          _ => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('CAF', style: AppText.eyebrow),
                const SizedBox(height: 4),
                _PercentText(percent: shownPercent, color: accent),
                const SizedBox(height: 8),
                Text(
                  countdown,
                  style: AppText.mono.copyWith(
                    fontSize: 22,
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isLow ? localizations.caffLowHint : localizations.caffToZero,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isLow ? FontWeight.w700 : FontWeight.w400,
                    color: isLow ? AppColors.ember : AppColors.roast,
                  ),
                ),
              ],
            ),
        };
        return SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: CafGaugePainter(progress: value, isLow: isLow),
            child: Center(
              child: SizedBox(
                width: innerSize * 0.86,
                height: innerSize * 0.80,
                child: FittedBox(fit: BoxFit.scaleDown, child: center),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PercentText extends StatelessWidget {
  const _PercentText({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$percent'),
          TextSpan(
            text: ' %',
            style: TextStyle(
              fontSize: 30,
              letterSpacing: 0,
              color: color.withValues(alpha: color.a * 0.7),
            ),
          ),
        ],
      ),
      style: AppText.mono.copyWith(
        fontSize: 72,
        height: 1,
        letterSpacing: -3,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

class CafGaugePainter extends CustomPainter {
  const CafGaugePainter({required this.progress, required this.isLow});

  final double progress;
  final bool isLow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.width * 0.075;
    final radius = size.width / 2 - stroke / 2 - 4;
    final ringRect = Rect.fromCircle(center: center, radius: radius);
    final value = progress.clamp(0.0, 1.0);

    // Soft "cup" inside the ring, filled to the current level.
    final cupRadius = radius - stroke / 2 - size.width * 0.035;
    final cupRect = Rect.fromCircle(center: center, radius: cupRadius);
    final cup = Path()..addOval(cupRect);
    canvas.drawPath(cup, Paint()..color = Colors.white.withValues(alpha: 0.7));
    if (value > 0) {
      canvas.save();
      canvas.clipPath(cup);
      final top = cupRect.bottom - cupRect.height * value;
      final wave = cupRadius * 0.045;
      final surface = Path()
        ..moveTo(cupRect.left, top)
        ..quadraticBezierTo(
          center.dx - cupRadius / 2,
          top - wave,
          center.dx,
          top,
        )
        ..quadraticBezierTo(
          center.dx + cupRadius / 2,
          top + wave,
          cupRect.right,
          top,
        )
        ..lineTo(cupRect.right, cupRect.bottom)
        ..lineTo(cupRect.left, cupRect.bottom)
        ..close();
      final fillColors = isLow
          ? [
              AppColors.ember.withValues(alpha: 0.10),
              AppColors.ember.withValues(alpha: 0.20),
            ]
          : [
              AppColors.caramel.withValues(alpha: 0.16),
              AppColors.caramel.withValues(alpha: 0.32),
            ];
      canvas.drawPath(
        surface,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: fillColors,
          ).createShader(
            Rect.fromLTRB(cupRect.left, top, cupRect.right, cupRect.bottom),
          ),
      );
      canvas.restore();
    }

    // Track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.roast.withValues(alpha: 0.09),
    );

    // Hour ticks: the countdown is four hours, one quarter each.
    final tickPaint = Paint()
      ..color = AppColors.roast.withValues(alpha: 0.25)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      final angle = -math.pi / 2 + index * math.pi / 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius - stroke / 2 - 3),
        center + direction * (radius - stroke / 2 - 8),
        tickPaint,
      );
    }

    if (value <= 0) return;

    // Progress arc from 12 o'clock clockwise: caramel at the start, deep
    // espresso as the cup gets fuller; warmer ember when almost empty.
    final sweep = 2 * math.pi * value;
    final colors = isLow
        ? const [AppColors.caramel, AppColors.ember]
        : const [AppColors.caramel, AppColors.roast, AppColors.espresso];
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: colors,
        stops: colors.length == 3 ? const [0.0, 0.55, 1.0] : null,
        // Start the gradient half a cap earlier, so the rounded start cap is
        // caramel instead of wrapping around to the end colour.
        transform: GradientRotation(-math.pi / 2 - stroke / 2 / radius),
      ).createShader(ringRect);
    canvas.drawArc(ringRect, -math.pi / 2, sweep, false, arcPaint);

    // A small foam bead at the head of the arc.
    final headAngle = -math.pi / 2 + sweep;
    final head =
        center + Offset(math.cos(headAngle), math.sin(headAngle)) * radius;
    canvas.drawCircle(
      head,
      stroke * 0.24,
      Paint()..color = AppColors.foam.withValues(alpha: 0.95),
    );
  }

  @override
  bool shouldRepaint(CafGaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isLow != isLow;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.roast.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.roast),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.roast,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Today" card: count with the correct plural and a thin day timeline.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.coffees,
    required this.carryOverEnd,
    required this.now,
    required this.duration,
    required this.locale,
    required this.alwaysUse24HourFormat,
  });

  final List<CoffeeLog> coffees;
  final DateTime? carryOverEnd;
  final DateTime now;
  final Duration duration;
  final String locale;
  final bool alwaysUse24HourFormat;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final timeFormat = AppTimeFormat.time(
      locale,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
    final times = coffees
        .map((log) => timeFormat.format(log.createdAt.toLocal()))
        .toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: 20,
                  color: AppColors.roast,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    localizations.coffeesTodayCount(coffees.length),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.espresso,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (coffees.isEmpty && carryOverEnd == null)
              Text(
                localizations.todayTimelineEmpty,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.roast),
              )
            else
              Semantics(
                label: times.isEmpty
                    ? localizations.todayTimelineEmpty
                    : localizations.todayTimelineSemantics(times.join(', ')),
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: 58,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: DayTimelinePainter(
                        coffees: coffees
                            .map((log) => log.createdAt.toLocal())
                            .toList(growable: false),
                        labels: times,
                        carryOverEnd: carryOverEnd,
                        now: now.toLocal(),
                        duration: duration,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Thin day strip (6:00–24:00, earlier when a coffee was logged before six)
/// with a dot per coffee, its CAF window and a "now" marker. A CAF window
/// carried over from yesterday starts the strip at 0:00, clipped, no dot.
class DayTimelinePainter extends CustomPainter {
  DayTimelinePainter({
    required this.coffees,
    required this.labels,
    required this.now,
    required this.duration,
    this.carryOverEnd,
  });

  final List<DateTime> coffees;
  final List<String> labels;
  final DateTime now;
  final Duration duration;
  final DateTime? carryOverEnd;

  static int startHourFor(List<DateTime> coffees, {DateTime? carryOverEnd}) {
    if (carryOverEnd != null) return 0;
    var start = 6;
    for (final coffee in coffees) {
      start = math.min(start, coffee.hour);
    }
    return start;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Calendar hours, not `day.add(Duration(hours:))`: on a daylight-saving
    // day a fixed number of hours from midnight is not the same clock hour.
    DateTime hourOfDay(int hour) =>
        DateTime(now.year, now.month, now.day, hour);
    final startHour = startHourFor(coffees, carryOverEnd: carryOverEnd);
    final start = hourOfDay(startHour);
    final end = DateTime(now.year, now.month, now.day + 1);
    final span = end.difference(start).inSeconds.toDouble();
    const inset = 8.0;
    final width = size.width - inset * 2;
    double x(DateTime time) {
      final fraction = time.difference(start).inSeconds / span;
      return inset + width * fraction.clamp(0.0, 1.0);
    }

    const trackY = 30.0;
    const trackHeight = 8.0;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, trackY - trackHeight / 2, width, trackHeight),
      const Radius.circular(trackHeight / 2),
    );
    canvas.drawRRect(
      track,
      Paint()..color = AppColors.roast.withValues(alpha: 0.08),
    );

    // CAF window after each coffee (opaque colour, so overlaps don't darken).
    final windowPaint = Paint()
      ..color = Color.lerp(AppColors.crema, AppColors.caramel, 0.55)!;
    canvas.save();
    canvas.clipRRect(track);
    final carried = carryOverEnd;
    if (carried != null && carried.isAfter(start)) {
      canvas.drawRect(
        Rect.fromLTRB(
          x(start),
          trackY - trackHeight / 2,
          x(carried),
          trackY + trackHeight / 2,
        ),
        windowPaint,
      );
    }
    for (final coffee in coffees) {
      canvas.drawRect(
        Rect.fromLTRB(
          x(coffee),
          trackY - trackHeight / 2,
          x(coffee.add(duration)),
          trackY + trackHeight / 2,
        ),
        windowPaint,
      );
    }
    canvas.restore();

    // Now marker.
    if (now.isAfter(start) && now.isBefore(end)) {
      final nowX = x(now);
      canvas.drawLine(
        Offset(nowX, trackY - 11),
        Offset(nowX, trackY + 11),
        Paint()
          ..color = AppColors.roast.withValues(alpha: 0.55)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Hour labels under the strip.
    final axisStyle = AppText.mono.copyWith(
      fontSize: 10,
      color: AppColors.roast.withValues(alpha: 0.7),
    );
    final axisHours = <int>{startHour, 12, 18, 24}.toList()..sort();
    for (final hour in axisHours) {
      final painter = _text('$hour', axisStyle);
      final hx = x(hourOfDay(hour));
      final dx = (hx - painter.width / 2)
          .clamp(0.0, size.width - painter.width)
          .toDouble();
      painter.paint(canvas, Offset(dx, trackY + 12));
    }

    // Coffee dots with time labels above (labels that would touch are left
    // out; screen readers get the full list).
    final labelStyle = AppText.mono.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
    double? lastLabelRight;
    for (var index = 0; index < coffees.length; index++) {
      final cx = x(coffees[index]);
      canvas.drawCircle(
        Offset(cx, trackY),
        6.5,
        Paint()..color = AppColors.foam,
      );
      canvas.drawCircle(
        Offset(cx, trackY),
        4.5,
        Paint()..color = AppColors.espresso,
      );
      final painter = _text(labels[index], labelStyle);
      final left = (cx - painter.width / 2)
          .clamp(0.0, size.width - painter.width)
          .toDouble();
      if (lastLabelRight == null || left >= lastLabelRight + 4) {
        painter.paint(canvas, Offset(left, trackY - 27));
        lastLabelRight = left + painter.width;
      }
    }
  }

  TextPainter _text(String text, TextStyle style) => TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  bool shouldRepaint(DayTimelinePainter oldDelegate) =>
      oldDelegate.now.minute != now.minute ||
      oldDelegate.labels.join() != labels.join() ||
      oldDelegate.coffees.join() != coffees.join() ||
      oldDelegate.carryOverEnd != carryOverEnd;
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
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: ListTile(
        leading: const Icon(Icons.error_outline_rounded),
        title: Text(message),
        trailing: TextButton(onPressed: onDismiss, child: Text(dismiss)),
      ),
    );
  }
}
