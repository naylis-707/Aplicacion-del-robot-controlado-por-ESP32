import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RobotPersonality { respectful, slang }

final personalityProvider = StateProvider<RobotPersonality>((ref) => RobotPersonality.respectful);