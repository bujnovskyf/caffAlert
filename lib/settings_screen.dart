import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'coffee_stats_provider.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.userEmail, super.key});

  final String userEmail;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static final _playStoreUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.zachrana.app',
  );
  static final _feedbackUri = Uri(
    scheme: 'mailto',
    path: 'bujnovskyf@gmail.com',
    queryParameters: const {
      'subject': 'CaffAlert — feedback',
    },
  );

  final _nameController = TextEditingController();
  bool _profileInitialized = false;
  bool _isSigningOut = false;
  bool _isDeletingAccount = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<CoffeeStatsProvider>();
    if (!_profileInitialized && !state.isLoading) {
      _nameController.text = state.profile?.displayName ?? '';
      _profileInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final coffeeState = context.watch<CoffeeStatsProvider>();
    final localeController = context.watch<LocaleController>();
    final selectedLanguage = localeController.locale?.languageCode ?? 'system';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.settingsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.espresso,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 28),
                  _SectionCard(
                    icon: Icons.person_outline_rounded,
                    title: localizations.profileSection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          maxLength: 80,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: localizations.displayNameLabel,
                            helperText: localizations.displayNameHint,
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          onSubmitted: (_) => _saveProfile(coffeeState),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: coffeeState.isMutating
                                ? null
                                : () => _saveProfile(coffeeState),
                            child: Text(localizations.save),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.translate_rounded,
                    title: localizations.languageSection,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedLanguage,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: localizations.languageSection,
                        prefixIcon: const Icon(Icons.language_rounded),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'system',
                          child: Text(localizations.systemLanguage),
                        ),
                        DropdownMenuItem(
                          value: 'cs',
                          child: Text(localizations.czech),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(localizations.english),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        context.read<LocaleController>().setLocale(
                              value == 'system' ? null : Locale(value),
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.favorite_outline_rounded,
                    title: localizations.appTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.rateAppHint,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.roast,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _rateApp,
                          icon: const Icon(Icons.star_outline_rounded),
                          label: Text(localizations.rateApp),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.mark_email_read_outlined,
                    title: localizations.feedbackSection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.feedbackHint,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.roast,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _sendFeedback,
                          icon: const Icon(Icons.send_outlined),
                          label: Text(localizations.contactDeveloper),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.warning_amber_rounded,
                    title: localizations.aboutCaffAlertSection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.aboutCaffAlertHint,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.roast,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _showCaffEmergencyBrief,
                          icon: const Icon(Icons.info_outline_rounded),
                          label: Text(localizations.caffEmergencyBrief),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.shield_outlined,
                    title: localizations.accountSection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.signedInAs,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.roast,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          widget.userEmail,
                          style: const TextStyle(
                            color: AppColors.espresso,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: _isSigningOut ? null : _signOut,
                          icon: _isSigningOut
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.logout_rounded),
                          label: Text(localizations.logout),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.45),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          localizations.deleteAccountHint,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.roast,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed:
                              _isDeletingAccount ? null : _confirmDeleteAccount,
                          icon: _isDeletingAccount
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.delete_forever_outlined),
                          label: Text(localizations.deleteAccount),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.45),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile(CoffeeStatsProvider state) async {
    final localizations = AppLocalizations.of(context);
    final success = await state.saveDisplayName(_nameController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? localizations.saved : localizations.actionFailed,
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final localizations = AppLocalizations.of(context);
    setState(() => _isSigningOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.actionFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _rateApp() async {
    final opened = await launchUrl(
      _playStoreUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).couldNotOpenStore)),
      );
    }
  }

  Future<void> _sendFeedback() async {
    final opened = await launchUrl(
      _feedbackUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).couldNotOpenEmail)),
      );
    }
  }

  Future<void> _showCaffEmergencyBrief() async {
    final localizations = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.caramel,
        ),
        title: Text(localizations.caffEmergencyTitle),
        content: SingleChildScrollView(
          child: Text(localizations.caffEmergencyBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localizations.dismiss),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
        title: Text(localizations.deleteAccountTitle),
        content: Text(localizations.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(localizations.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    try {
      final client = Supabase.instance.client;
      await client.rpc('delete_own_account');
      await client.auth.signOut();
    } on AuthException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.actionFailed)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.actionFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.roast),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.espresso,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}
