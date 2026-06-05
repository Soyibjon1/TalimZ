/// Ilova konfiguratsiya fayli
class AppConfig {
  // WebSocket konfiguratsiya
  static const bool enableWebSocket = true;
  static const bool debugMode = true;
  
  // AI konfiguratsiya
  static const String defaultAiService = 'gemini'; // 'websocket' yoki 'gemini'
  
  // Environment detection
  static bool get isDebug => debugMode;
  
  // URL validation
  static bool isValidWebSocketUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'ws' || uri.scheme == 'wss';
    } catch (e) {
      return false;
    }
  }
  
  // Ngrok URL detection
  static bool isNgrokUrl(String url) {
    return url.contains('ngrok') && url.contains('.app');
  }
  
  // Local development URLs
  static const List<String> localUrls = [
    'ws://localhost:8765',
    'ws://127.0.0.1:8765',
    'ws://10.0.2.2:8765',
  ];
}