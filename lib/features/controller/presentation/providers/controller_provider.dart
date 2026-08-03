// features/controller/presentation/providers/controller_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/esp32_repository.dart';

// Proveedor del repositorio
final esp32RepositoryProvider = Provider((ref) => ESP32Repository());

// Proveedor de acciones para el robot
final robotControllerProvider = Provider((ref) {
  final repo = ref.watch(esp32RepositoryProvider);
  return RobotControllerNotifier(repo);
});

class RobotControllerNotifier {
  final ESP32Repository _repo;
  RobotControllerNotifier(this._repo);

  void mover(String direction) {
    switch (direction) {
      case 'forward':
        _repo.enviarComando('avanzar');
        break;
      case 'backward':
        _repo.enviarComando('retroceder');
        break;
      case 'left':
        _repo.enviarComando('izquierda');
        break;
      case 'right':
        _repo.enviarComando('derecha');
        break;
      case 'stop':
      default:
        _repo.enviarComando('detener');
        break;
    }
  }
}