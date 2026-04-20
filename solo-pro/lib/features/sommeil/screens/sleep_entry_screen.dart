import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../models/sleep_model.dart';
import '../widgets/time_wheel_picker.dart';

class SleepEntryScreen extends StatefulWidget {
  const SleepEntryScreen({super.key});

  @override
  State<SleepEntryScreen> createState() => _SleepEntryScreenState();
}

class _SleepEntryScreenState extends State<SleepEntryScreen>
    with SingleTickerProviderStateMixin {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 0; // 0 = pas encore choisi
  final _noteCtrl = TextEditingController();

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ─── Calcul durée ─────────────────────────────────────────────────────────

  double get _durationHours {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    final diff = wakeMinutes < bedMinutes
        ? (24 * 60 - bedMinutes) + wakeMinutes
        : wakeMinutes - bedMinutes;
    return diff / 60.0;
  }

  String get _durationLabel {
    final h = _durationHours.floor();
    final m = ((_durationHours - h) * 60).round();
    return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
  }

  Color get _durationColor {
    if (_durationHours < 6) return AppColors.accent;
    if (_durationHours < 7) return AppColors.accentYellow;
    return AppColors.accentGreen;
  }

  String _timeFormat12(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  bool get _canSave => _quality > 0;

  void _save() {
    final entry = SleepEntry(
      date: DateTime.now(),
      bedtime: _bedtime,
      wakeTime: _wakeTime,
      quality: _quality,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    mockSleepHistory.add(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sommeil enregistré : $_durationLabel 😴'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // fond nuit
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildTimesTab(),
                          _buildQualityTab(),
                          _buildNoteTab(),
                        ],
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header (fond nuit) ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    color: Colors.white60, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Mon sommeil',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.sleepGraphs),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bar_chart,
                          color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text('Historique',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Résumé durée
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NightStat(
                label: 'Coucher',
                value: _timeFormat12(_bedtime),
                icon: '🌙',
              ),
              // Durée centrale
              Column(
                children: [
                  Text(
                    _durationLabel,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: _durationColor,
                    ),
                  ),
                  Text(
                    _durationHours < 6
                        ? 'Insuffisant'
                        : _durationHours < 7
                            ? 'Correct'
                            : 'Optimal',
                    style: TextStyle(
                        fontSize: 11, color: _durationColor),
                  ),
                ],
              ),
              _NightStat(
                label: 'Lever',
                value: _timeFormat12(_wakeTime),
                icon: '☀️',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4)
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: '🕐 Horaires'),
            Tab(text: '⭐ Qualité'),
            Tab(text: '📝 Note'),
          ],
        ),
      ),
    );
  }

  // ─── Tab 1 : Horaires ─────────────────────────────────────────────────────

  Widget _buildTimesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTimeSection(
            label: 'Heure de coucher',
            emoji: '🌙',
            color: const Color(0xFF3D35CC),
            time: _bedtime,
            onChanged: (t) => setState(() => _bedtime = t),
          ),
          const SizedBox(height: 28),
          _buildTimeSection(
            label: 'Heure de lever',
            emoji: '☀️',
            color: const Color(0xFFFF9F1C),
            time: _wakeTime,
            onChanged: (t) => setState(() => _wakeTime = t),
          ),
          const SizedBox(height: 20),
          // Conseil durée
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _durationColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _durationColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Text(
                  _durationHours < 6
                      ? '⚠️'
                      : _durationHours < 7
                          ? '💡'
                          : '✅',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _durationHours < 6
                        ? 'Moins de 6h de sommeil — ton cerveau n\'a pas assez récupéré.'
                        : _durationHours < 7
                            ? 'Sommeil correct. Idéalement, vise 7-8h.'
                            : 'Bonne durée ! $_durationLabel de sommeil, c\'est optimal.',
                    style: TextStyle(
                        fontSize: 12,
                        color: _durationColor,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection({
    required String label,
    required String emoji,
    required Color color,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: TimeWheelPicker(
            initialTime: time,
            onChanged: onChanged,
            accentColor: color,
          ),
        ),
      ],
    );
  }

  // ─── Tab 2 : Qualité ──────────────────────────────────────────────────────

  Widget _buildQualityTab() {
    const emojis = ['💀', '😩', '😐', '😌', '🌟'];
    const labels = [
      'Catastrophique',
      'Mauvais',
      'Correct',
      'Bon',
      'Excellent'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Comment as-tu dormi ?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Évalue la qualité de ta nuit',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 32),

          // Sélecteur qualité
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final val = i + 1;
              final isSelected = _quality == val;
              return GestureDetector(
                onTap: () => setState(() => _quality = val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isSelected ? 62 : 52,
                  height: isSelected ? 62 : 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3D35CC).withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? Border.all(
                            color: const Color(0xFF3D35CC), width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3D35CC)
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emojis[i],
                          style: TextStyle(
                              fontSize: isSelected ? 28 : 22)),
                      Text('$val',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF3D35CC)
                                : AppColors.textLight,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Label qualité sélectionnée
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _quality > 0
                ? Container(
                    key: ValueKey(_quality),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D35CC)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labels[_quality - 1],
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D35CC),
                          fontSize: 15),
                    ),
                  )
                : const Text('Sélectionne ta qualité de sommeil',
                    style: TextStyle(
                        color: AppColors.textLight, fontSize: 13)),
          ),

          const SizedBox(height: 32),

          // Facteurs (optionnel)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Facteurs (optionnel)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 10),
          _buildFactors(),
        ],
      ),
    );
  }

  final Set<String> _selectedFactors = {};

  Widget _buildFactors() {
    const factors = [
      '🍷 Alcool',
      '☕ Caféine',
      '📱 Écrans',
      '😰 Stress',
      '🏃 Sport tard',
      '🌡️ Température',
      '🔊 Bruit',
      '😌 Relaxation',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: factors.map((f) {
        final isSelected = _selectedFactors.contains(f);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedFactors.remove(f);
            } else {
              _selectedFactors.add(f);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3D35CC).withValues(alpha: 0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: const Color(0xFF3D35CC), width: 1.5)
                  : null,
            ),
            child: Text(f,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF3D35CC)
                        : AppColors.textSecondary)),
          ),
        );
      }).toList(),
    );
  }

  // ─── Tab 3 : Note ─────────────────────────────────────────────────────────

  Widget _buildNoteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Note sur ta nuit',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Rêves, réveils, ressenti… tout est bon à noter.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          TextField(
            controller: _noteCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              hintText:
                  'Ex : Réveillé à 3h, difficile à me rendormir...',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.textLight.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.textLight.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF3D35CC), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Conseils solo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Text('🤖',
                          style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Noter ton sommeil t\'aide à identifier les patterns. Après 2 semaines, tu verras ce qui impacte vraiment ta nuit.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barre du bas ─────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          if (_tabCtrl.index > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _tabCtrl.animateTo(_tabCtrl.index - 1),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Retour',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ),
          if (_tabCtrl.index > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _tabCtrl.index < 2
                  ? () => _tabCtrl.animateTo(_tabCtrl.index + 1)
                  : (_canSave ? _save : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _tabCtrl.index < 2 || _canSave
                    ? const Color(0xFF3D35CC)
                    : AppColors.surfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: ListenableBuilder(
                listenable: _tabCtrl,
                builder: (_, __) => Text(
                  _tabCtrl.index < 2
                      ? 'Suivant →'
                      : 'Enregistrer 😴',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _tabCtrl.index < 2 || _canSave
                        ? Colors.white
                        : AppColors.textLight,
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

class _NightStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _NightStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
