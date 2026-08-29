import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'l10n/app_localizations.dart';

enum _AuthMode { signIn, signUp, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _confirmationSent = false;
  bool _resetLinkSent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  String? get _redirectUrl => kIsWeb ? Uri.base.origin : null;

  void _setMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
      _confirmationSent = false;
      _resetLinkSent = false;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final localizations = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Supabase.instance.client.auth;
      switch (_mode) {
        case _AuthMode.signIn:
          await auth.signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          TextInput.finishAutofillContext();
        case _AuthMode.signUp:
          final response = await auth.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            emailRedirectTo: _redirectUrl,
          );
          TextInput.finishAutofillContext();
          if (response.session == null && mounted) {
            setState(() => _confirmationSent = true);
          }
        case _AuthMode.forgotPassword:
          await auth.resetPasswordForEmail(
            _emailController.text.trim(),
            redirectTo: _redirectUrl,
          );
          if (mounted) setState(() => _resetLinkSent = true);
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _error = _localizedAuthError(error, localizations));
      }
    } catch (_) {
      if (mounted) setState(() => _error = localizations.authGenericError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _localizedAuthError(
    AuthException error,
    AppLocalizations localizations,
  ) {
    return switch (error.code) {
      'invalid_credentials' => localizations.invalidCredentials,
      'email_not_confirmed' => localizations.emailNotConfirmed,
      'user_already_exists' => localizations.accountExists,
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' =>
        localizations.rateLimited,
      _ => localizations.authGenericError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.crema, Color(0xFFE2C7B2)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showBrandPanel = constraints.maxWidth >= 900;
              final isNarrow = constraints.maxWidth < 360;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isNarrow ? 16 : 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: showBrandPanel
                        ? Row(
                            children: [
                              Expanded(
                                child: _BrandPanel(
                                  localizations: localizations,
                                ),
                              ),
                              const SizedBox(width: 64),
                              Expanded(child: _buildAuthCard()),
                            ],
                          )
                        : _buildAuthCard(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 470),
      child: _AuthCard(
        formKey: _formKey,
        mode: _mode,
        emailController: _emailController,
        passwordController: _passwordController,
        confirmationController: _confirmationController,
        isLoading: _isLoading,
        obscurePassword: _obscurePassword,
        confirmationSent: _confirmationSent,
        resetLinkSent: _resetLinkSent,
        error: _error,
        onTogglePassword: () => setState(
          () => _obscurePassword = !_obscurePassword,
        ),
        onSubmit: _submit,
        onSetMode: _setMode,
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.espresso,
              borderRadius: BorderRadius.circular(22),
            ),
            child:
                const Icon(Icons.coffee_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 32),
          Text(
            localizations.appTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.roast,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.authWelcomeTitle,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.espresso,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              localizations.authWelcomeSubtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.roast,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.formKey,
    required this.mode,
    required this.emailController,
    required this.passwordController,
    required this.confirmationController,
    required this.isLoading,
    required this.obscurePassword,
    required this.confirmationSent,
    required this.resetLinkSent,
    required this.error,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onSetMode,
  });

  final GlobalKey<FormState> formKey;
  final _AuthMode mode;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmationController;
  final bool isLoading;
  final bool obscurePassword;
  final bool confirmationSent;
  final bool resetLinkSent;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final ValueChanged<_AuthMode> onSetMode;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isSignUp = mode == _AuthMode.signUp;
    final isForgotPassword = mode == _AuthMode.forgotPassword;
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    final legalPrefix =
        Localizations.localeOf(context).languageCode == 'cs' ? '/cs' : '';
    final title = switch (mode) {
      _AuthMode.signIn => localizations.signIn,
      _AuthMode.signUp => localizations.signUp,
      _AuthMode.forgotPassword => localizations.resetPasswordTitle,
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 24 : 32),
        child: AutofillGroup(
          child: Form(
            key: formKey,
            child: FocusTraversalGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (MediaQuery.sizeOf(context).width < 900) ...[
                    Row(
                      children: [
                        const Icon(Icons.coffee_rounded,
                            color: AppColors.roast),
                        const SizedBox(width: 10),
                        Text(
                          localizations.appTitle,
                          style: const TextStyle(
                            color: AppColors.espresso,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isNarrow ? 20 : 28),
                  ],
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.espresso,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (isForgotPassword) ...[
                    const SizedBox(height: 8),
                    Text(localizations.resetPasswordBody),
                  ],
                  const SizedBox(height: 24),
                  if (confirmationSent || resetLinkSent) ...[
                    _SuccessMessage(
                      title: confirmationSent
                          ? localizations.confirmationSentTitle
                          : localizations.resetPasswordTitle,
                      body: confirmationSent
                          ? localizations.confirmationSentBody
                          : localizations.resetLinkSent,
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: isForgotPassword
                        ? TextInputAction.done
                        : TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: localizations.emailLabel,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (value) {
                      final input = value?.trim() ?? '';
                      if (input.isEmpty) return localizations.emailRequired;
                      if (!input.contains('@') || !input.contains('.')) {
                        return localizations.emailInvalid;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      if (isForgotPassword) onSubmit();
                    },
                  ),
                  if (!isForgotPassword) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: [
                        isSignUp
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: localizations.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: onTogglePassword,
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.passwordRequired;
                        }
                        if (isSignUp && value.length < 8) {
                          return localizations.passwordTooShort;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!isSignUp) onSubmit();
                      },
                    ),
                  ],
                  if (isSignUp) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: confirmationController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: localizations.confirmPasswordLabel,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) => value != passwordController.text
                          ? localizations.passwordsDoNotMatch
                          : null,
                      onFieldSubmitted: (_) => onSubmit(),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isForgotPassword
                                ? localizations.sendResetLink
                                : isSignUp
                                    ? localizations.signUp
                                    : localizations.signIn,
                          ),
                  ),
                  const SizedBox(height: 10),
                  if (mode == _AuthMode.signIn) ...[
                    TextButton(
                      onPressed: () => onSetMode(_AuthMode.forgotPassword),
                      child: Text(localizations.forgotPassword),
                    ),
                    TextButton(
                      onPressed: () => onSetMode(_AuthMode.signUp),
                      child: Text(localizations.switchToSignUp),
                    ),
                  ] else
                    TextButton(
                      onPressed: () => onSetMode(_AuthMode.signIn),
                      child: Text(
                        isSignUp
                            ? localizations.switchToSignIn
                            : localizations.backToSignIn,
                      ),
                    ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2,
                      runSpacing: 0,
                      children: [
                        _LegalLink(
                          label: localizations.privacyPolicy,
                          path: '$legalPrefix/privacy',
                        ),
                        _LegalLink(
                          label: localizations.termsOfUse,
                          path: '$legalPrefix/terms',
                        ),
                        _LegalLink(
                          label: localizations.deleteAccountWeb,
                          path: '$legalPrefix/delete-account',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.path});

  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => launchUrl(
        Uri.base.resolve(path),
        mode: LaunchMode.externalApplication,
      ),
      child: Text(label),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sage.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.mark_email_read_outlined, color: AppColors.sage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
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
