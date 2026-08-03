abstract class RobotCommand {
  Map<String, dynamic> toJson();
}

class MovementCommand implements RobotCommand {
  final String direction;
  MovementCommand(this.direction);

  @override
  Map<String, dynamic> toJson() => {
    "type": "movement",
    "direction": direction,
  };
}

class SpeedCommand implements RobotCommand {
  final int value;
  SpeedCommand(this.value);

  @override
  Map<String, dynamic> toJson() => {
    "type": "speed",
    "value": value,
  };
}

class LightsCommand implements RobotCommand {
  final bool enabled;
  LightsCommand(this.enabled);

  @override
  Map<String, dynamic> toJson() => {
    "type": "lights",
    "state": enabled,
  };
}

class HornCommand implements RobotCommand {
  @override
  Map<String, dynamic> toJson() => {
    "type": "horn",
  };
}

class FaceCommand implements RobotCommand {
  final String expression;
  FaceCommand(this.expression);

  @override
  Map<String, dynamic> toJson() => {
    "type": "face",
    "expression": expression,
  };
}

class SpeakCommand implements RobotCommand {
  final String text;
  SpeakCommand(this.text);

  @override
  Map<String, dynamic> toJson() => {
    "type": "speak",
    "text": text,
  };
}

class AutoModeCommand implements RobotCommand {
  final bool enabled;
  AutoModeCommand(this.enabled);

  @override
  Map<String, dynamic> toJson() => {
    "type": "auto",
    "enabled": enabled,
  };
}

class ServoCommand implements RobotCommand {
  final int angle; // Ángulo al que quieres que gire (ej: 0, 90, 180)
  ServoCommand(this.angle);

  @override
  Map<String, dynamic> toJson() => {
    "type": "servo",
    "angle": angle,
  };
}