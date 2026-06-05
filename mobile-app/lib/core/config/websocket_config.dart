/// WebSocket konfiguratsiya fayli
class WebSocketConfig {
  // WebSocket URL-lari prioritet tartibida
  static const List<String> urls = [
    'ws://localhost:8765',              // Lokal development server
    'ws://10.0.2.2:8765',             // Android emulator
    'ws://192.168.1.100:8765',        // LAN IP (bu yerga o'z IP ni qo'ying)
    // NGrok URL-ni bu yerga qo'shing:
    // 'wss://YOUR-NEW-NGROK-URL.ngrok-free.app',
  ];
  
  // Retry konfiguratsiya
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration responseTimeout = Duration(seconds: 15);
  
  // Host not found xatoligi uchun maxsus sozlamalar
  static const Duration hostNotFoundCooldown = Duration(minutes: 5);
  static const int maxHostNotFoundRetries = 1;
}