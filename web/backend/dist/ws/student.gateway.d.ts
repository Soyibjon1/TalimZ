import { OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import { LlmService } from '../ai/llm.service';
export declare class StudentGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly llm;
    server: Server;
    private readonly logger;
    private readonly histories;
    constructor(llm: LlmService);
    handleConnection(client: WebSocket, req: IncomingMessage): void;
    handleDisconnect(client: WebSocket): void;
    handleMessage(client: WebSocket, raw: string): any;
    private send;
}
