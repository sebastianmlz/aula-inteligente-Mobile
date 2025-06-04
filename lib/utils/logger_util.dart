import 'package:logger/logger.dart';

class LoggerUtil {
  static final Logger _instance = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Número de métodos en la pila a mostrar
      errorMethodCount: 8, // Número de métodos para errores
      lineLength: 120, // Ancho de línea
      colors: true, // Colorear los mensajes
      printEmojis: true, // Mostrar emojis
      dateTimeFormat:
          DateTimeFormat.onlyTimeAndSinceStart, // Mostrar solo la hora
    ),
    // Nivel mínimo de logs que se mostrarán
    level: Level.debug,
  );

  static Logger get instance => _instance;
}
