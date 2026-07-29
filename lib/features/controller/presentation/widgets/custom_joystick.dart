import 'dart:math';
import 'package:flutter/material.dart';

class ProfessionalJoystick extends StatefulWidget {
  final void Function(String direction) onDirectionChanged;

  const ProfessionalJoystick({super.key, required this.onDirectionChanged});

  @override
  State<ProfessionalJoystick> createState() => _ProfessionalJoystickState();
}

class _ProfessionalJoystickState extends State<ProfessionalJoystick> {
  Offset _knobOffset = Offset.zero;
  final double _joystickSize = 200.0;
  final double _knobSize = 70.0;
  String _currentDirection = "stop";

  void _updatePosition(Offset localPosition) {
    final center = Offset(_joystickSize / 2, _joystickSize / 2);
    final offsetFromCenter = localPosition - center;
    final distance = offsetFromCenter.distance;
    final maxRadius = (_joystickSize - _knobSize) / 2;

    Offset newKnobOffset;
    if (distance <= maxRadius) {
      newKnobOffset = offsetFromCenter;
    } else {
      final ratio = maxRadius / distance;
      newKnobOffset = offsetFromCenter * ratio;
    }

    setState(() {
      _knobOffset = newKnobOffset;
    });

    _calculateDirection(offsetFromCenter, distance, maxRadius);
  }

  void _calculateDirection(Offset offset, double distance, double maxRadius) {
    if (distance < maxRadius * 0.3) {
      _emitDirection("stop");
      return;
    }

    final angle = atan2(offset.dy, offset.dx);
    final degrees = angle * 180 / pi;

    String newDir;
    if (degrees >= -45 && degrees <= 45) {
      newDir = "right";
    } else if (degrees > 45 && degrees < 135) {
      newDir = "backward";
    } else if (degrees >= 135 || degrees <= -135) {
      newDir = "left";
    } else {
      newDir = "forward";
    }

    _emitDirection(newDir);
  }

  void _emitDirection(String dir) {
    if (_currentDirection != dir) {
      _currentDirection = dir;
      widget.onDirectionChanged(dir);
    }
  }

  void _resetJoystick() {
    setState(() {
      _knobOffset = Offset.zero;
    });
    _emitDirection("stop");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updatePosition(details.localPosition),
      onPanUpdate: (details) => _updatePosition(details.localPosition),
      onPanEnd: (_) => _resetJoystick(),
      child: Container(
        width: _joystickSize,
        height: _joystickSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.1)],
          ),
          border: Border.all(color: Colors.white10, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 20),
          ],
        ),
        child: Center(
          child: Transform.translate(
            offset: _knobOffset,
            child: Container(
              width: _knobSize,
              height: _knobSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4DD0E1), Color(0xFF00B8D4)],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.cyan.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: const Icon(Icons.gamepad, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}