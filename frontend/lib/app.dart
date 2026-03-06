import 'dart:async';

import 'package:flutter/material.dart';

import 'navigation/main_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/design_system.dart';

class SayeApp extends StatefulWidget {
  const SayeApp({super.key});

  @override
  State<SayeApp> createState() => _SayeAppState();
}

class _SayeAppState extends State<SayeApp> {
  final AppState _appState = AppState();

  bool _showSplash = true;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_appState.checkAuthStatus());
    unawaited(_appState.loadEmergencyContacts());
    _splashTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SAYE'nde",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: AnimatedBuilder(
        animation: _appState,
        builder: (context, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _showSplash
                ? const SplashScreen(key: ValueKey('splash'))
                : _appState.isAuthenticated
                ? MainShell(key: const ValueKey('main'), appState: _appState)
                : AuthScreen(
                    key: const ValueKey('auth'),
                    onLogin: (email, password) =>
                        _appState.login(email: email, password: password),
                    onRegister:
                        ({
                          required String email,
                          required String username,
                          required String password,
                          required String phone,
                        }) => _appState.register(
                          email: email,
                          username: username,
                          password: password,
                          phone: phone,
                        ),
                    isLoading: _appState.isLoading,
                    onDemoLogin: _appState.demoLogin,
                  ),
          );
        },
      ),
    );
  }
}
