import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/websocket/websocket_service.dart';
import '../../../domain/models/robot_commands.dart';
import '../../../main.dart';
import '../../../data/providers/personality_provider.dart';
import '../../../../core/services/ai_service.dart';
import 'widgets/custom_joystick.dart';
import 'widgets/robot_face.dart'; // 🤖 Importación de los nuevos ojitos animados

class ControllerScreen extends ConsumerStatefulWidget {
  const ControllerScreen({super.key});

  @override
  ConsumerState<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends ConsumerState<ControllerScreen> {
  double _speed = 50.0;
  bool _lightsOn = false;
  bool _isProcessingAI = false;
  final TextEditingController _ttsController = TextEditingController();
  RobotMood _currentMood = RobotMood.neutral;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(webSocketProvider.notifier).connect());
  }

  Future<void> _goBackToHome() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.remove('app_mode');
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _handleAIQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isProcessingAI = true;
      _currentMood = RobotMood.thinking; // 🧠 Cambia a modo pensando
    });

    final personality = ref.read(personalityProvider);

    // Obtener respuesta de Gemini
    final aiResponse = await AIService.generateResponse(query, personality);

    setState(() {
      _isProcessingAI = false;
      _currentMood = RobotMood.happy; // 😄 Cambia a feliz al responder
    });
    
    _ttsController.clear();

    // 🔊 Enviar texto al ESP32 por WebSocket. 
    // El ESP32 se encarga de enviárselo al celular que está funcionando como "Cara/Parlante"
    ref.read(webSocketProvider.notifier).sendCommand(SpeakCommand(aiResponse));

    // Regresar a neutral después de unos segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _currentMood = RobotMood.neutral);
    });
  }

  @override
  void dispose() {
    _ttsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wsState = ref.watch(webSocketProvider);
    final wsNotifier = ref.read(webSocketProvider.notifier);
    final currentPersonality = ref.watch(personalityProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.cyan),
          onPressed: _goBackToHome,
          tooltip: 'Cambiar modo',
        ),
        title: const Text('Dashboard IA & Control', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          DropdownButton<RobotPersonality>(
            value: currentPersonality,
            dropdownColor: Colors.grey[900],
            underline: const SizedBox(),
            icon: const Icon(Icons.psychology, color: Colors.cyan),
            items: const [
              DropdownMenuItem(
                value: RobotPersonality.respectful,
                child: Text('🤖 Respetuoso', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              DropdownMenuItem(
                value: RobotPersonality.slang,
                child: Text('😎 Jergas', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(personalityProvider.notifier).state = val;
              }
            },
          ),
          const SizedBox(width: 8),
          _ConnectionIndicator(status: wsState.status),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🤖 Minivisor con los nuevos ojitos animados en el controlador
              SizedBox(
                height: 90,
                child: Transform.scale(
                  scale: 0.8,
                  child: RobotFaceWidget(mood: _currentMood),
                ),
              ),
              const SizedBox(height: 15),

              _buildTelemetryGrid(wsState),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfessionalJoystick(
                    onDirectionChanged: (dir) => wsNotifier.sendCommand(MovementCommand(dir)),
                  ),
                  _buildControls(wsNotifier),
                ],
              ),
              const SizedBox(height: 25),
              _buildAIInputSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryGrid(WebSocketState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TelemetryItem(icon: Icons.speed, value: '${_speed.toInt()}%', label: 'Velocidad'),
          _TelemetryItem(icon: Icons.network_ping, value: '${state.latencyMs}ms', label: 'Latencia'),
          _TelemetryItem(icon: Icons.data_usage, value: '${state.messagesSent}', label: 'Msg Env'),
        ],
      ),
    );
  }

  Widget _buildControls(WebSocketNotifier wsNotifier) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: _speed,
              min: 0,
              max: 100,
              activeColor: Colors.cyan,
              onChanged: (val) {
                setState(() => _speed = val);
                wsNotifier.sendCommand(SpeedCommand(val.toInt()));
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            IconButton.filledTonal(
              icon: Icon(_lightsOn ? Icons.lightbulb : Icons.lightbulb_outline),
              color: _lightsOn ? Colors.yellow : Colors.white,
              onPressed: () {
                setState(() => _lightsOn = !_lightsOn);
                wsNotifier.sendCommand(LightsCommand(_lightsOn));
              },
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              icon: const Icon(Icons.campaign, color: Colors.redAccent),
              onPressed: () => wsNotifier.sendCommand(HornCommand()),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildAIInputSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habla o pregunta al robot (IA):',
            style: TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ttsController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ej: ¿Qué hora es? o Cuéntame un chiste...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) => _handleAIQuery(val),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                elevation: 0,
                backgroundColor: _isProcessingAI ? Colors.grey : Colors.cyan,
                foregroundColor: Colors.black,
                onPressed: _isProcessingAI ? null : () => _handleAIQuery(_ttsController.text),
                child: _isProcessingAI 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _TelemetryItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.cyan, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  final WebSocketStatus status;
  const _ConnectionIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case WebSocketStatus.connected: color = Colors.greenAccent; break;
      case WebSocketStatus.connecting: color = Colors.orangeAccent; break;
      default: color = Colors.redAccent;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]),
    );
  }
}