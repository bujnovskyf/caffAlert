import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_screen.dart';
import 'coffee_repository.dart';
import 'coffee_stats_provider.dart';
import 'main_shell.dart';
import 'password_update_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Session? _session;
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isPasswordRecovery = false;

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    _session = auth.currentSession;
    _authSubscription = auth.onAuthStateChange.listen((state) {
      if (!mounted) return;
      setState(() {
        _session = state.session;
        if (state.event == AuthChangeEvent.passwordRecovery) {
          _isPasswordRecovery = true;
        } else if (state.event == AuthChangeEvent.signedOut) {
          _isPasswordRecovery = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) return const AuthScreen();
    if (_isPasswordRecovery) {
      return PasswordUpdateScreen(
        onComplete: () => setState(() => _isPasswordRecovery = false),
      );
    }

    final user = session.user;
    return ChangeNotifierProvider(
      key: ValueKey(user.id),
      create: (_) => CoffeeStatsProvider(
        userId: user.id,
        repository: CoffeeRepository(Supabase.instance.client),
      ),
      child: MainShell(userEmail: user.email ?? ''),
    );
  }
}
