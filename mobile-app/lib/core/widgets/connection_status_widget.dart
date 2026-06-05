import 'package:flutter/material.dart';
import '../services/websocket_ai_service.dart';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({super.key});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  final _webSocketService = WebSocketAiService();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 2)),
      builder: (context, snapshot) {
        final status = _webSocketService.connectionState;
        final message = _webSocketService.getStatusMessage();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getStatusColor(status), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                message,
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (status == WebSocketConnectionState.hostNotFound || status == WebSocketConnectionState.failed)
                GestureDetector(
                  onTap: () {
                    if (status == WebSocketConnectionState.hostNotFound) {
                      _webSocketService.clearHostNotFoundCooldown();
                    }
                    _webSocketService.reconnect();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getStatusColor(WebSocketConnectionState status) {
    switch (status) {
      case WebSocketConnectionState.connected:
        return Colors.green;
      case WebSocketConnectionState.connecting:
        return Colors.orange;
      case WebSocketConnectionState.disconnected:
        return Colors.grey;
      case WebSocketConnectionState.failed:
        return Colors.red;
      case WebSocketConnectionState.hostNotFound:
        return Colors.purple;
    }
  }
  
  IconData _getStatusIcon(WebSocketConnectionState status) {
    switch (status) {
      case WebSocketConnectionState.connected:
        return Icons.cloud_done;
      case WebSocketConnectionState.connecting:
        return Icons.cloud_sync;
      case WebSocketConnectionState.disconnected:
        return Icons.cloud_off;
      case WebSocketConnectionState.failed:
        return Icons.error;
      case WebSocketConnectionState.hostNotFound:
        return Icons.search_off;
    }
  }
}