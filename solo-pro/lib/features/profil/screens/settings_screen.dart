import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../models/profile_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // États des paramètres
  bool _notifMatin = true;
  bool _notifSoir = true;
  bool _notifStreak = true;
  bool _notifBadge = true;
  bool _darkMode = false;
  bool _soundFeedback = true;
  TimeOfDay _reminderMatin = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _reminderSoir = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    final p = mockProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // ─── Profil rapide ───────────────────────────────────────────────
          _buildProfileTile(p),

          const SizedBox(height: 8),
          _buildSection('Notifications', [
            _buildToggleTile(
              icon: '☀️',
              title: 'Check-in du matin',
              subtitle: 'Rappel à ${_formatTime(_reminderMatin)}',
              value: _notifMatin,
              onChanged: (v) => setState(() => _notifMatin = v),
              onSubtitleTap: () => _pickTime(true),
            ),
            _buildToggleTile(
              icon: '🌙',
              title: 'Check-in du soir',
              subtitle: 'Rappel à ${_formatTime(_reminderSoir)}',
              value: _notifSoir,
              onChanged: (v) => setState(() => _notifSoir = v),
              onSubtitleTap: () => _pickTime(false),
            ),
            _buildToggleTile(
              icon: '🔥',
              title: 'Streak en danger',
              subtitle: 'Si pas de check-in en fin de journée',
              value: _notifStreak,
              onChanged: (v) => setState(() => _notifStreak = v),
            ),
            _buildToggleTile(
              icon: '🏅',
              title: 'Nouveaux badges',
              subtitle: 'Quand tu débloqués un badge',
              value: _notifBadge,
              onChanged: (v) => setState(() => _notifBadge = v),
            ),
          ]),

          const SizedBox(height: 8),
          _buildSection('Apparence', [
            _buildToggleTile(
              icon: '🌙',
              title: 'Mode sombre',
              subtitle: 'Thème adapté à la nuit',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            _buildToggleTile(
              icon: '🔊',
              title: 'Sons & vibrations',
              subtitle: 'Feedback haptique et sonore',
              value: _soundFeedback,
              onChanged: (v) => setState(() => _soundFeedback = v),
            ),
          ]),

          const SizedBox(height: 8),
          _buildSection('Compte', [
            _buildNavTile(
              icon: '✏️',
              title: 'Modifier mon profil',
              subtitle: '${p.prenom} · ${p.metier}',
              onTap: () {},
            ),
            _buildNavTile(
              icon: '🔒',
              title: 'Changer de mot de passe',
              onTap: () {},
            ),
            _buildNavTile(
              icon: '📤',
              title: 'Exporter mes données',
              subtitle: 'Télécharger en CSV',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 8),
          _buildSection('À propos', [
            _buildNavTile(
              icon: '📄',
              title: 'Conditions d\'utilisation',
              onTap: () {},
            ),
            _buildNavTile(
              icon: '🔐',
              title: 'Politique de confidentialité',
              onTap: () {},
            ),
            _buildInfoTile(icon: '📱', title: 'Version', value: '1.0.0'),
          ]),

          const SizedBox(height: 16),

          // Déconnexion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout,
                  color: AppColors.accent, size: 18),
              label: const Text('Se déconnecter',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Supprimer le compte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: _confirmDelete,
              child: const Text(
                'Supprimer mon compte',
                style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Profil tile ──────────────────────────────────────────────────────────

  Widget _buildProfileTile(UserProfile p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D35CC), Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
                child: Text(p.emoji,
                    style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.prenom,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text(p.metier,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Voir profil',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers sections ─────────────────────────────────────────────────────

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 52,
                      color: AppColors.textLight.withValues(alpha: 0.2),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required String icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onSubtitleTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  GestureDetector(
                    onTap: onSubtitleTap,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: onSubtitleTap != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        decoration: onSubtitleTap != null
                            ? TextDecoration.underline
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required String icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 13, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ─── Helpers temps + modales ──────────────────────────────────────────────

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(bool isMatin) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isMatin ? _reminderMatin : _reminderSoir,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isMatin) {
          _reminderMatin = picked;
        } else {
          _reminderSoir = picked;
        }
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Se déconnecter ?'),
        content: const Text(
            'Tu devras te reconnecter pour accéder à ton compte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.auth, (_) => false);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le compte ?'),
        content: const Text(
            'Cette action est irréversible. Toutes tes données seront perdues définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.auth, (_) => false);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accent),
            ),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
