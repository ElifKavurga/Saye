import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_system.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onDemoLogin,
    required this.isLoading,
  });

  final Future<void> Function(String email, String password) onLogin;
  final Future<void> Function({
    required String email,
    required String username,
    required String password,
    required String phone,
  })
  onRegister;
  final VoidCallback onDemoLogin;
  final bool isLoading;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _registerEmail = TextEditingController();
  final _registerUsername = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerPhone = TextEditingController();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerEmail.dispose();
    _registerUsername.dispose();
    _registerPassword.dispose();
    _registerPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.mainBackground,
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight - (AppSpacing.lg * 2),
                            maxWidth: 520,
                          ),
                          child: _AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: AppSpacing.md),
                                const _LogoHeader(),
                                const SizedBox(height: AppSpacing.lg),
                                TabBar(
                                  indicatorColor: Colors.white,
                                  indicatorWeight: 2,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: const Color(0xFFB6D4CD),
                                  labelStyle: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  unselectedLabelStyle:
                                      GoogleFonts.spaceGrotesk(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  tabs: const [
                                    Tab(text: 'Giri\u015f Yap'),
                                    Tab(text: 'Kay\u0131t Ol'),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                SizedBox(
                                  height: constraints.maxWidth < 380
                                      ? 540
                                      : 470,
                                  child: TabBarView(
                                    children: [
                                      _buildLoginTab(),
                                      _buildRegisterTab(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: widget.isLoading
                                        ? null
                                        : widget.onDemoLogin,
                                    child: const Text('Demo Giris'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (widget.isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x55000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _LabeledInput(
            label: 'E-Mail',
            controller: _loginEmail,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledInput(
            label: '\u015eifre',
            controller: _loginPassword,
            obscureText: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () async {
                      if (_loginFormKey.currentState?.validate() ?? false) {
                        await _submitAuthAction(() {
                          return widget.onLogin(
                            _loginEmail.text.trim(),
                            _loginPassword.text,
                          );
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2D55),
                foregroundColor: Colors.white,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Giri\u015f Yap'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _LabeledInput(
            label: 'E-Mail',
            controller: _registerEmail,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledInput(
            label: 'Kullan\u0131c\u0131 Ad\u0131',
            controller: _registerUsername,
            validator: _validateRequired,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledInput(
            label: '\u015eifre',
            controller: _registerPassword,
            obscureText: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledInput(
            label: 'Telefon',
            controller: _registerPhone,
            keyboardType: TextInputType.phone,
            validator: _validateRequired,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 240,
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () async {
                      if (_registerFormKey.currentState?.validate() ?? false) {
                        await _submitAuthAction(() {
                          return widget.onRegister(
                            email: _registerEmail.text.trim(),
                            username: _registerUsername.text.trim(),
                            password: _registerPassword.text,
                            phone: _registerPhone.text.trim(),
                          );
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2D55),
                foregroundColor: Colors.white,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kayit Ol & Giris Yap!'),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Bu alan bo\u015f ge\u00e7ilemez';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'E-mail bo\u015f ge\u00e7ilemez';
    }
    if (!_emailRegex.hasMatch(text)) {
      return 'Ge\u00e7erli bir e-mail girin';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.trim().isEmpty) {
      return '\u015eifre bo\u015f ge\u00e7ilemez';
    }
    if (text.length < 6) {
      return '\u015eifre en az 6 karakter olmal\u0131';
    }
    return null;
  }

  Future<void> _submitAuthAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Islem basarisiz: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF123763), Color(0xFF5A8D5E)],
        ),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: child,
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'SAYE',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 60,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
            TextSpan(
              text: "'nde",
              style: GoogleFonts.allura(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.body.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: AppTextStyles.body.copyWith(color: const Color(0xFF2A3640)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            errorStyle: AppTextStyles.caption.copyWith(
              color: const Color(0xFFFFE0E0),
            ),
          ),
        ),
      ],
    );
  }
}
