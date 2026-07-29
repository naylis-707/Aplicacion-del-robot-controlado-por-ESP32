import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../main.dart';
import '../../../core/websocket/websocket_service.dart';
import 'widgets/robot_face.dart';

class RobotScreen extends ConsumerStatefulWidget {
  const RobotScreen({super.key});

  @override
  ConsumerState<RobotScreen> createState() => _RobotScreenState();
}

class _RobotScreenState extends ConsumerState<RobotScreen> {
  late FlutterTts _flutterTts;
  RobotMood _currentMood = RobotMood.neutral;

  @override
  void initState() {
    super.initState();
    // Conectarse al WebSocket del ESP32 al iniciar la pantalla del robot
    Future.microtask(() => ref.read(webSocketProvider.notifier).connect());
    _initTts();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.75);
  }

  Future<void> _goBackToHome() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.remove('app_mode');
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Aquí puedes escuchar los mensajes que llegan del WebSocket (si el ESP32 te manda texto a hablar)
    // Por ejemplo, si el estado del WebSocket trae un comando de voz:
    // ref.listen(webSocketProvider, (previous, next) {
    //   if (next.lastSpokenText != null && next.lastSpokenText != previous?.lastSpokenText) {
    //     _flutterTts.speak(next.lastSpokenText!);
    //     setState(() => _currentMood = RobotMood.happy);
    //   }
    // });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Pantalla del Robot con sus dos ojitos animados en grande
          GestureDetector(
            onDoubleTap: () {
              // Cambio de prueba al hacer doble toque
              setState(() {
                _currentMood = _currentMood == RobotMood.neutral 
                    ? RobotMood.happy 
                    : RobotMood.neutral;
              });
            },
            child: Center(
              child: Transform.scale(
                scale: 2.5, // Amplía los ojos para que luzcan como pantalla de robot
                child: RobotFaceWidget(mood: _currentMood),
              ),
            ),
          ),
          
          // Botón discreto para regresar al menú
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: 0.4,
              child: FloatingActionButton.small(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                onPressed: _goBackToHome,
                tooltip: 'Regresar al menú',
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
    );
  }
}