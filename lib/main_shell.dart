import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'coffee_stats_provider.dart';
import 'caff_alert_home_widget.dart';
import 'dashboard_screen.dart';
import 'l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'timer_screen.dart';
import 'widget_launch_handler.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    required this.userEmail,
    required this.userId,
    this.signedInAt,
    super.key,
  });

  final String userEmail;
  final String userId;

  /// When the user signed in during this app run, or null when the session
  /// was already there at start. Widget taps from before this moment were
  /// made while signed out and are dropped, never logged later.
  final DateTime? signedInAt;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _onboardingKeyPrefix = 'onboarding_completed_';

  StreamSubscription<Uri?>? _widgetClicks;

  int _selectedIndex = 0;
  bool _isCheckingOnboarding = true;
  bool _showOnboarding = false;
  bool _isStartingOnboarding = false;
  // A coffee logged from the widget counts as the first coffee of the
  // onboarding, even before the onboarding flag has been read.
  bool _loggedFromWidget = false;

  String get _onboardingKey => '$_onboardingKeyPrefix${widget.userId}';
  bool get _isLocalWebPreview =>
      kIsWeb && (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1');

  @override
  void initState() {
    super.initState();
    unawaited(_loadOnboarding());
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_listenForWidget());
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(CaffAlertHomeWidget.syncLanguage(
      Localizations.localeOf(context).languageCode,
    ));
  }

  Future<void> _listenForWidget() async {
    _widgetClicks = HomeWidget.widgetClicked.listen(
      (uri) => unawaited(_logFromWidget(uri)),
      onError: (Object _) {},
    );
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (mounted) await _logFromWidget(uri);
    } catch (_) {
      // Unsupported platform channel must not affect normal app launches.
    }
  }

  Future<void> _logFromWidget(Uri? uri) async {
    if (!mounted) return;
    final state = context.read<CoffeeStatsProvider>();
    if (state.userId != widget.userId) return;
    try {
      if (!await WidgetLaunchHandler.claim(
        uri,
        userId: widget.userId,
        notBefore: widget.signedInAt,
      )) {
        return;
      }
      if (!mounted) return;
      final success = await state.addCoffee();
      if (!mounted) return;
      if (success) {
        _loggedFromWidget = true;
        // The widget already logged the first coffee: finish the onboarding
        // so it cannot log a second "first" one or hide the snackbar.
        if (_showOnboarding || _isCheckingOnboarding) {
          await _finishOnboarding();
          if (!mounted) return;
        }
      }
      final l10n = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(success ? l10n.coffeeLogged : l10n.actionFailed),
            duration: const Duration(seconds: 6),
            action: success
                ? SnackBarAction(
                    label: l10n.widgetUndo,
                    onPressed: () async {
                      // Exactly the coffee the widget added, even if another
                      // device logged one in between (as in TimerScreen).
                      final undone = await state.undoLastAddedCoffee();
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              undone ? l10n.coffeeUndone : l10n.actionFailed,
                            ),
                          ),
                        );
                    },
                  )
                : null,
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).actionFailed)),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_widgetClicks?.cancel());
    super.dispose();
  }

  Future<void> _loadOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    final completed = preferences.getBool(_onboardingKey) ?? false;
    if (!mounted) return;
    setState(() {
      _isCheckingOnboarding = false;
      _showOnboarding =
          !_loggedFromWidget && (_isLocalWebPreview || !completed);
    });
  }

  Future<void> _finishOnboarding() async {
    await (await SharedPreferences.getInstance()).setBool(_onboardingKey, true);
    if (!mounted) return;
    setState(() => _showOnboarding = false);
  }

  Future<void> _startWithFirstCoffee() async {
    setState(() => _isStartingOnboarding = true);
    final success = await context.read<CoffeeStatsProvider>().addCoffee();
    if (!mounted) return;
    if (!success) {
      setState(() => _isStartingOnboarding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).actionFailed)),
      );
      return;
    }

    await _finishOnboarding();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).coffeeLogged)),
    );
  }

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

        final shell = !useRail
            ? Scaffold(
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
              )
            : Scaffold(
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
                          backgroundColor:
                              AppColors.foam.withValues(alpha: 0.66),
                          indicatorColor:
                              AppColors.caramel.withValues(alpha: 0.25),
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

        return Stack(
          children: [
            shell,
            if (!_isCheckingOnboarding && _showOnboarding)
              Positioned.fill(
                child: _OnboardingOverlay(
                  isStarting: _isStartingOnboarding,
                  onSkip: _finishOnboarding,
                  onStart: _startWithFirstCoffee,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OnboardingOverlay extends StatefulWidget {
  const _OnboardingOverlay({
    required this.isStarting,
    required this.onSkip,
    required this.onStart,
  });

  final bool isStarting;
  final Future<void> Function() onSkip;
  final Future<void> Function() onStart;

  @override
  State<_OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<_OnboardingOverlay> {
  final _controller = PageController();
  var _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_page == 2) {
      await widget.onStart();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isLastPage = _page == 2;

    return Material(
      color: AppColors.crema.withValues(alpha: 0.97),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 540,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localizations.onboardingEyebrow,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.caramel,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: PageView(
                            controller: _controller,
                            onPageChanged: (page) =>
                                setState(() => _page = page),
                            children: [
                              _OnboardingPage(
                                icon: Icons.waving_hand_rounded,
                                title: localizations.onboardingWelcomeTitle,
                                body: localizations.onboardingWelcomeBody,
                              ),
                              _OnboardingPage(
                                icon: Icons.add_task_rounded,
                                title: localizations.onboardingLogTitle,
                                body: localizations.onboardingLogBody,
                              ),
                              _OnboardingPage(
                                icon: Icons.bolt_rounded,
                                title: localizations.onboardingTrackTitle,
                                body: localizations.onboardingTrackBody,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: index == _page ? 22 : 7,
                              height: 7,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: index == _page
                                    ? AppColors.roast
                                    : AppColors.roast.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            TextButton(
                              onPressed: widget.isStarting
                                  ? null
                                  : () => widget.onSkip(),
                              child: Text(localizations.onboardingSkip),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.isStarting ? null : _continue,
                                child: widget.isStarting
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        isLastPage
                                            ? localizations.onboardingStart
                                            : localizations.onboardingNext,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.caramel.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(icon, color: AppColors.roast, size: 36),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.espresso,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.roast),
                ),
              ],
            ),
          ),
        ),
      ),
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
