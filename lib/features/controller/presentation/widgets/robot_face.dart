import 'dart:async';
import 'package:flutter/material.dart';

enum RobotMood { neutral, happy, thinking, alert }

class RobotFaceWidget extends StatefulWidget {
  final RobotMood mood;

  const RobotFaceWidget({super.key, this.mood = RobotMood.neutral});

  @override
  State<RobotFaceWidget> createState() => _RobotFaceWidgetState();
}

class _RobotFaceWidgetState extends State<RobotFaceWidget> {
  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    // Parpadeo automático aleatorio o periódico cada 3.5 segundos
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (mounted) {
        setState(() => _isBlinking = true);
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) setState(() => _isBlinking = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color eyeColor;
    double eyeHeightMultiplier = 1.0;
    double eyeWidth = 45.0;
    double eyeHeight = 55.0;

    // Definir colores y formas según el estado de ánimo (Animaciones de expresión)
    switch (widget.mood) {
      case RobotMood.happy:
        eyeColor = Colors.cyanAccent;
        eyeHeightMultiplier = 0.5; // Ojos más cerrados/felices (aros o líneas curvas simuladas)
        break;
      case RobotMood.thinking:
        eyeColor = Colors.orangeAccent; // Color de procesamiento
        break;
      case RobotMood.alert:
        eyeColor = Colors.redAccent; // Modo alerta/activo
        break;
      case RobotMood.neutral:
      default:
        eyeColor = Colors.cyan;
        break;
    }

    if (_isBlinking) {
      eyeHeight = 4.0; // Altura cuando parpadea
    } else {
      eyeHeight = eyeHeight * eyeHeightMultiplier;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 45),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: eyeColor.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(
            color: eyeColor.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEye(eyeWidth, eyeHeight, eyeColor),
          const SizedBox(width: 45), // Espacio entre los dos ojos
          _buildEye(eyeWidth, eyeHeight, eyeColor),
        ],
      ),
    );
  }

  Widget _buildEye(double width, double height, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_isBlinking ? 2 : 20),
        boxShadow: _isBlinking ? [] : [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
    );
  }
}