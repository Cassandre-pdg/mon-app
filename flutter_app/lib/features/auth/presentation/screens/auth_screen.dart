import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/widgets/aurora_background.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../../../shared/widgets/kolyb_loader.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authNotifierProvider.notifier);

    if (_isLogin) {
      await notifier.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      await notifier.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        fullName: _nameCtrl.text.trim(),
      );
    }

    final state = ref.read(authNotifierProvider);
    if (mounted && state is! AsyncError) {
      if (_isLogin) {
        final prefs = await SharedPreferences.getInstance();
        final onboardingDone = prefs.getBool('onboarding_done') ?? false;
        if (mounted) {
          context.go(onboardingDone ? AppRoutes.home : AppRoutes.onboarding);
        }
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  void _switchMode() {
    setState(() => _isLogin = !_isLogin);
    ref.read(authNotifierProvider.notifier).reset();
    _fadeCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    ref.listen(authNotifierProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.errorAuth),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AuroraBackgroundPaint(
        orb1Color: AppColors.auroraViolet,
        orb2Color: AppColors.auroraPink,
        orb3Color: AppColors.auroraTeal,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(height: 56),

                  // ── Logo + Brand ─────────────────────────────
                  _BrandHeader(),

                  const SizedBox(height: 48),

                  // ── Glass Form Card ──────────────────────────
                  _GlassFormCard(
                    isLogin: _isLogin,
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    nameCtrl: _nameCtrl,
                    obscurePassword: _obscurePassword,
                    isLoading: isLoading,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                    onSwitchMode: _switchMode,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── En-tête brand ─────────────────────────────────────────────
class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icône app — glassmorphism pill
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/kolyb_logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Nom de marque — gradient text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppColors.gradientMain,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            AppConstants.appName,
            style: AppTextStyles.brandName(),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Ton élan, au quotidien.',
          style: AppTextStyles.brandSlogan(
            color: AppColors.textDarkMuted,
          ),
        ),
      ],
    );
  }
}

// ── Carte formulaire glass ────────────────────────────────────
class _GlassFormCard extends StatelessWidget {
  const _GlassFormCard({
    required this.isLogin,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onSwitchMode,
  });

  final bool isLogin;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController nameCtrl;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.glassWhite8,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.glassBorderWhite,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne de lumière en haut
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 1,
                  width: 120,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.glassHighlight,
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              // Titre
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: isLogin ? 'Bon retour ' : 'Rejoins la tribu ',
                      style: AppTextStyles.headingLarge(color: AppColors.textDark),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        isLogin ? Icons.waving_hand_rounded : Icons.rocket_launch_rounded,
                        color: AppColors.primaryLight,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isLogin
                    ? 'Ton avenir se construit maintenant.'
                    : 'Crée ton compte, c\'est gratuit.',
                style: AppTextStyles.bodyMedium(color: AppColors.textDarkMuted),
              ),

              const SizedBox(height: 28),

              // Formulaire
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Prénom (inscription)
                    if (!isLogin) ...[
                      _GlassTextField(
                        controller: nameCtrl,
                        hint: 'Ton prénom',
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Indique ton prénom' : null,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Email
                    _GlassTextField(
                      controller: emailCtrl,
                      hint: 'Ton email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Indique ton email';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Mot de passe
                    _GlassTextField(
                      controller: passwordCtrl,
                      hint: 'Ton mot de passe',
                      icon: Icons.lock_outline_rounded,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.grey400,
                          size: 20,
                        ),
                        onPressed: onTogglePassword,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Indique ton mot de passe';
                        if (v.length < 6) return 'Minimum 6 caractères';
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // CTA principal — pleine largeur dans la carte
                    _SpringButton(
                      onPressed: isLoading ? null : onSubmit,
                      child: isLoading
                          ? const KolybLoader(size: 16, color: Colors.white)
                          : Text(
                              isLogin ? 'Se connecter' : 'Créer mon compte',
                              style: AppTextStyles.headingSmall(
                                color: Colors.white,
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Switch login / signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin
                              ? 'Pas encore de compte ? '
                              : 'Déjà un compte ? ',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textDarkMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: onSwitchMode,
                          child: Text(
                            isLogin ? 'Rejoins-nous' : 'Connecte-toi',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.primaryLight,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Champ de saisie glass ─────────────────────────────────────
class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: obscureText
          ? TextInputType.visiblePassword
          : keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: !obscureText,
      style: AppTextStyles.bodyMedium(color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.grey600),
        prefixIcon: Icon(icon, color: AppColors.grey400, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0x1A1A1836),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.glassBorderWhite,
            width: 0.8,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.glassBorderWhite,
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}

// ── Bouton avec spring bounce — micro-interaction iOS ─────────
class _SpringButton extends StatefulWidget {
  const _SpringButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<_SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<_SpringButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
