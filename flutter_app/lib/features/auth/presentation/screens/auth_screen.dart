import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/navigation/app_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
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
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    // Affiche l'erreur si elle existe
    ref.listen(authNotifierProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.errorAuth),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
        );
        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.spacing48),

              // Logo + tagline
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.displayLarge(color: AppColors.primary),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      'Avance à ton rythme, jamais seul.',
                      style: AppTextStyles.bodyMedium(color: AppColors.grey400),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacing48),

              // Titre formulaire
              Text(
                _isLogin ? 'Bon retour 👋' : 'Rejoins la tribu 🚀',
                style: AppTextStyles.headingLarge(color: textColor),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                _isLogin
                    ? 'Connecte-toi pour reprendre où tu t\'es arrêté.'
                    : 'Crée ton compte — c\'est gratuit.',
                style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              ),

              const SizedBox(height: AppConstants.spacing32),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Prénom (inscription seulement)
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Ton prénom',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Indique ton prénom' : null,
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                    ],

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Ton email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Indique ton email';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacing16),

                    // Mot de passe
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Ton mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Indique ton mot de passe';
                        if (v.length < 6) return 'Minimum 6 caractères';
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacing32),

                    // Bouton principal
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isLogin ? 'Se connecter' : 'Créer mon compte'),
                    ),

                    const SizedBox(height: AppConstants.spacing24),

                    // Switcher login / signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? 'Pas encore de compte ? '
                              : 'Déjà un compte ? ',
                          style: AppTextStyles.bodyMedium(color: AppColors.grey400),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isLogin = !_isLogin);
                            ref.read(authNotifierProvider.notifier).reset();
                          },
                          child: Text(
                            _isLogin ? 'Rejoins-nous' : 'Connecte-toi',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacing32),

              // Disclaimer RGPD
              Center(
                child: Text(
                  AppStrings.rgpdDisclaimer,
                  style: AppTextStyles.caption(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
