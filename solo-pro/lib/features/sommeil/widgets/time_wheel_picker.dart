import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TimeWheelPicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onChanged;
  final Color accentColor;

  const TimeWheelPicker({
    super.key,
    required this.initialTime,
    required this.onChanged,
    this.accentColor = AppColors.primary,
  });

  @override
  State<TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<TimeWheelPicker> {
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;
  late int _hour;
  late int _minute;

  // Minutes par pas de 5
  static const List<int> _minuteSteps = [
    0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55
  ];

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    // Arrondi au pas le plus proche
    _minute = _minuteSteps.reduce((a, b) =>
        (b - widget.initialTime.minute).abs() <
                (a - widget.initialTime.minute).abs()
            ? b
            : a);

    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minCtrl = FixedExtentScrollController(
        initialItem: _minuteSteps.indexOf(_minute));
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _notify() =>
      widget.onChanged(TimeOfDay(hour: _hour, minute: _minute));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heures
          _Wheel(
            controller: _hourCtrl,
            itemCount: 24,
            label: (i) => i.toString().padLeft(2, '0'),
            onSelected: (i) {
              _hour = i;
              _notify();
            },
            accentColor: widget.accentColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(':',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: widget.accentColor)),
          ),
          // Minutes (par pas de 5)
          _Wheel(
            controller: _minCtrl,
            itemCount: _minuteSteps.length,
            label: (i) => _minuteSteps[i].toString().padLeft(2, '0'),
            onSelected: (i) {
              _minute = _minuteSteps[i];
              _notify();
            },
            accentColor: widget.accentColor,
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) label;
  final ValueChanged<int> onSelected;
  final Color accentColor;

  const _Wheel({
    required this.controller,
    required this.itemCount,
    required this.label,
    required this.onSelected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 44,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelected,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (ctx, i) {
            final isSelected = controller.selectedItem == i;
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: isSelected ? 26 : 18,
                  fontWeight: isSelected
                      ? FontWeight.w800
                      : FontWeight.w400,
                  color: isSelected ? accentColor : AppColors.textLight,
                ),
                child: Text(label(i)),
              ),
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}
