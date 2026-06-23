import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/kolyb_loader.dart';
import '../providers/capture_provider.dart';

/// Ouvre le bottom sheet de capture rapide (brain dump).
void showCaptureSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CaptureSheet(),
  );
}

class _CaptureSheet extends ConsumerStatefulWidget {
  const _CaptureSheet();

  @override
  ConsumerState<_CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<_CaptureSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  bool _saved  = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ref.read(captureProvider.notifier).add(_ctrl.text);
    setState(() {
      _saving = false;
      _saved  = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.97)
                  : AppColors.backgroundLight.withValues(alpha: 0.97),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey400.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Capture rapide',
                            style: AppTextStyles.headingSmall(
                              color: isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                            )),
                        Text(
                          'Vide ta tête, sans pression',
                          style: AppTextStyles.caption(
                              color: AppColors.grey400),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Champ texte
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _saved
                      ? _SavedConfirmation(isDark: isDark)
                      : _InputField(
                          ctrl: _ctrl,
                          isDark: isDark,
                          onSubmit: _save,
                        ),
                ),

                const SizedBox(height: 20),

                // Hint contextuel
                if (!_saved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: AppColors.primaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Retrouve-les en bas de Mon Espace, et trie-les lors de ta revue de semaine.',
                            style: AppTextStyles.caption(
                                color: AppColors.primaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!_saved) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const KolybLoader(
                              size: 6, color: Colors.white)
                          : Text('Capturer',
                              style: AppTextStyles.labelMedium(
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.ctrl,
    required this.isDark,
    required this.onSubmit,
  });
  final TextEditingController ctrl;
  final bool isDark;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      autofocus: true,
      maxLines: 4,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
      style: AppTextStyles.bodyMedium(
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
      decoration: InputDecoration(
        hintText:
            'Une idée, une tâche, une inquiétude... capture tout ici.',
        hintStyle:
            AppTextStyles.bodyMedium(color: AppColors.grey400)
                .copyWith(fontSize: 13),
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceElevatedDark
            : AppColors.grey200.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _SavedConfirmation extends StatelessWidget {
  const _SavedConfirmation({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 28),
          ),
          const SizedBox(height: 12),
          Text('Capturé !',
              style: AppTextStyles.headingSmall(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              )),
          const SizedBox(height: 4),
          Text(
            'On s\'en occupera lors de ta revue de semaine.',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Bouton flottant Brain Dump — à placer dans le shell de navigation.
class CaptureFab extends ConsumerWidget {
  const CaptureFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingCapturesCountProvider);

    return GestureDetector(
      onTap: () => showCaptureSheet(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded,
                color: Colors.white, size: 24),
          ),
          // Badge nombre de captures en attente
          if (pendingCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    pendingCount > 9 ? '9+' : '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
