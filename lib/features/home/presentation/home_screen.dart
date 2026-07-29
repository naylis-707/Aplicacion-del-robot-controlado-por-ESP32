import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSavedMode();
    });
  }

  void _checkSavedMode() {
    final prefs = ref.read(sharedPrefsProvider);
    final mode = prefs.getString('app_mode');
    if (mode == 'robot') context.go('/robot');
    if (mode == 'controller') context.go('/controller');
  }

  Future<void> _selectMode(String mode) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString('app_mode', mode);
    if (!mounted) return;
    context.go('/$mode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy_outlined, size: 100, color: Colors.cyan)
                  .animate()
                  .fade(duration: 800.ms)
                  .scale(delay: 200.ms),
              const SizedBox(height: 40),
              Text(
                '¿CÓMO QUIERES USAR EL ROBOT?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 400.ms),
              const SizedBox(height: 40),
              _ModeCard(
                title: '🤖 ROBOT',
                subtitle: 'El teléfono actuará como la cara del robot.',
                onTap: () => _selectMode('robot'),
              ).animate().slideX(delay: 600.ms, begin: -1),
              const SizedBox(height: 20),
              _ModeCard(
                title: '🎮 CONTROLADOR',
                subtitle: 'El teléfono actuará como control remoto.',
                onTap: () => _selectMode('controller'),
              ).animate().slideX(delay: 800.ms, begin: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.05), // 👈 Compatible con todas las versiones de Flutter
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.cyan.withOpacity(0.2), // 👈 Compatible con todas las versiones de Flutter
                  foregroundColor: Colors.cyan,
                ),
                child: const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}