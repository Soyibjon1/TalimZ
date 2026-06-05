import { Module } from '@nestjs/common';
import { StudentGateway } from './student.gateway';
import { AiModule } from '../ai/ai.module';

/**
 * NestJS @SubscribeMessage decorators only work with Socket.IO adapter.
 * We use the raw WS adapter, so we wire messages manually in the module.
 */
@Module({
  imports: [AiModule],
  providers: [
    StudentGateway,
    {
      // Wire raw WebSocket messages to gateway.handleMessage()
      provide: 'WS_SETUP',
      useFactory: (gateway: StudentGateway) => {
        // The gateway's @WebSocketServer() is populated after the module is ready.
        // We hook into the 'connection' event to attach per-socket message handlers.
        // NestJS calls handleConnection() automatically; we just also need onmessage.
        const originalConnect = gateway.handleConnection.bind(gateway);
        gateway.handleConnection = (client, req) => {
          originalConnect(client, req);
          client.on('message', (raw) => gateway.handleMessage(client, raw.toString()));
        };
        return gateway;
      },
      inject: [StudentGateway],
    },
  ],
})
export class WsModule {}
