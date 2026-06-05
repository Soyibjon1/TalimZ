import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import { LlmService } from '../ai/llm.service';

/**
 * Handles the exact WebSocket protocol your frontend already uses.
 *
 * Client sends JSON:
 *   { action: 'savol',    matn: '...', lang?: 'uz'|'ru'|'en', subject?: '...' }
 *   { action: 'eshit',    audio: '<base64 PCM int16>' }
 *   { action: 'gapir',    matn: '...',  lang?: '...' }
 *   { action: 'test_tuz', fayl: '<base64>', fayl_turi: 'pdf'|'pptx', soni: 10 }
 *
 * Server sends JSON:
 *   { type: 'javob',  matn: '...',  daily_remaining: N }
 *   { type: 'qisman', matn: '...' }
 *   { type: 'audio',  audio: '...', rate: 22050 }
 *   { type: 'test',   test: [...] }
 *   { type: 'xato',   xabar: '...' }
 */
@WebSocketGateway({ path: '/' })
export class StudentGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;
  private readonly logger = new Logger(StudentGateway.name);

  // Per-client conversation history (in-memory; swap for Redis in production)
  private readonly histories = new Map<WebSocket, { role: string; content: string }[]>();

  constructor(private readonly llm: LlmService) {}

  handleConnection(client: WebSocket, req: IncomingMessage) {
    this.histories.set(client, []);
    this.logger.log(`WS connected — ${req.socket.remoteAddress}`);
  }

  handleDisconnect(client: WebSocket) {
    this.histories.delete(client);
    this.logger.log('WS disconnected');
  }

  // Called by WsModule which wires raw messages here
  async handleMessage(client: WebSocket, raw: string) {
    let msg: any;
    try {
      msg = JSON.parse(raw);
    } catch {
      this.send(client, { type: 'xato', xabar: 'Invalid JSON' });
      return;
    }

    const { action, lang = 'uz' } = msg;

    // ── AI chat ────────────────────────────────────────────────────────
    if (action === 'savol') {
      try {
        const history = this.histories.get(client) ?? [];
        const reply = await this.llm.chat({
          message: msg.matn,
          subject: msg.subject,
          history,
          lang,
        });

        // Append turn to history
        history.push({ role: 'user', content: msg.matn });
        history.push({ role: 'assistant', content: reply });
        if (history.length > 20) history.splice(0, 2); // keep last 10 turns

        this.send(client, { type: 'javob', matn: reply, daily_remaining: -1 });
      } catch (err) {
        this.logger.error('LLM error:', err.message);
        this.send(client, { type: 'xato', xabar: `LLM xatosi: ${err.message}` });
      }
    }

    // ── STT — stream audio chunks to your STT service ─────────────────
    else if (action === 'eshit') {
      // TODO: accumulate audio chunks and forward to Whisper / Vosk
      // For now we echo back a placeholder partial transcript
      // Example with local Whisper:
      //   const audioBuffer = Buffer.from(msg.audio, 'base64')
      //   const text = await whisperService.transcribe(audioBuffer)
      //   this.send(client, { type: 'matn', matn: text })
      this.send(client, { type: 'qisman', matn: '...' });
    }

    // ── TTS ────────────────────────────────────────────────────────────
    else if (action === 'gapir') {
      try {
        const { audio, rate } = await this.llm.tts(msg.matn, lang);
        this.send(client, { type: 'audio', audio, rate });
      } catch (err) {
        this.send(client, { type: 'xato', xabar: `TTS xatosi: ${err.message}` });
      }
    }

    // ── Test generation from uploaded file ─────────────────────────────
    else if (action === 'test_tuz') {
      try {
        // Decode base64 file
        const fileBuffer = Buffer.from(msg.fayl, 'base64');
        let text = '';

        if (msg.fayl_turi === 'pdf') {
          // TODO: npm install pdf-parse, then:
          // const pdfParse = require('pdf-parse');
          // const result = await pdfParse(fileBuffer);
          // text = result.text;
          text = 'PDF mazmuni (pdf-parse kutubxonasini ulang)';
        } else {
          // TODO: npm install pptx2json or officeparser, then extract text
          text = 'PPTX mazmuni (officeparser kutubxonasini ulang)';
        }

        const questions = await this.llm.generateTestFromText({
          text,
          count: msg.soni ?? 10,
          lang,
        });

        this.send(client, { type: 'test', test: questions });
      } catch (err) {
        this.logger.error('Test generation error:', err.message);
        this.send(client, { type: 'xato', xabar: `Test yaratishda xato: ${err.message}` });
      }
    }

    else {
      this.send(client, { type: 'xato', xabar: `Noma'lum action: ${action}` });
    }
  }

  private send(client: WebSocket, data: object) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  }
}
