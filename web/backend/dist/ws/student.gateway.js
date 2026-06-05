"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var StudentGateway_1;
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.StudentGateway = void 0;
const websockets_1 = require("@nestjs/websockets");
const common_1 = require("@nestjs/common");
const ws_1 = require("ws");
const llm_service_1 = require("../ai/llm.service");
let StudentGateway = StudentGateway_1 = class StudentGateway {
    constructor(llm) {
        this.llm = llm;
        this.logger = new common_1.Logger(StudentGateway_1.name);
        this.histories = new Map();
    }
    handleConnection(client, req) {
        this.histories.set(client, []);
        this.logger.log(`WS connected — ${req.socket.remoteAddress}`);
    }
    handleDisconnect(client) {
        this.histories.delete(client);
        this.logger.log('WS disconnected');
    }
    async handleMessage(client, raw) {
        let msg;
        try {
            msg = JSON.parse(raw);
        }
        catch {
            this.send(client, { type: 'xato', xabar: 'Invalid JSON' });
            return;
        }
        const { action, lang = 'uz' } = msg;
        if (action === 'savol') {
            try {
                const history = this.histories.get(client) ?? [];
                const reply = await this.llm.chat({
                    message: msg.matn,
                    subject: msg.subject,
                    history,
                    lang,
                });
                history.push({ role: 'user', content: msg.matn });
                history.push({ role: 'assistant', content: reply });
                if (history.length > 20)
                    history.splice(0, 2);
                this.send(client, { type: 'javob', matn: reply, daily_remaining: -1 });
            }
            catch (err) {
                this.logger.error('LLM error:', err.message);
                this.send(client, { type: 'xato', xabar: `LLM xatosi: ${err.message}` });
            }
        }
        else if (action === 'eshit') {
            this.send(client, { type: 'qisman', matn: '...' });
        }
        else if (action === 'gapir') {
            try {
                const { audio, rate } = await this.llm.tts(msg.matn, lang);
                this.send(client, { type: 'audio', audio, rate });
            }
            catch (err) {
                this.send(client, { type: 'xato', xabar: `TTS xatosi: ${err.message}` });
            }
        }
        else if (action === 'test_tuz') {
            try {
                const fileBuffer = Buffer.from(msg.fayl, 'base64');
                let text = '';
                if (msg.fayl_turi === 'pdf') {
                    text = 'PDF mazmuni (pdf-parse kutubxonasini ulang)';
                }
                else {
                    text = 'PPTX mazmuni (officeparser kutubxonasini ulang)';
                }
                const questions = await this.llm.generateTestFromText({
                    text,
                    count: msg.soni ?? 10,
                    lang,
                });
                this.send(client, { type: 'test', test: questions });
            }
            catch (err) {
                this.logger.error('Test generation error:', err.message);
                this.send(client, { type: 'xato', xabar: `Test yaratishda xato: ${err.message}` });
            }
        }
        else {
            this.send(client, { type: 'xato', xabar: `Noma'lum action: ${action}` });
        }
    }
    send(client, data) {
        if (client.readyState === ws_1.WebSocket.OPEN) {
            client.send(JSON.stringify(data));
        }
    }
};
exports.StudentGateway = StudentGateway;
__decorate([
    (0, websockets_1.WebSocketServer)(),
    __metadata("design:type", typeof (_a = typeof ws_1.Server !== "undefined" && ws_1.Server) === "function" ? _a : Object)
], StudentGateway.prototype, "server", void 0);
exports.StudentGateway = StudentGateway = StudentGateway_1 = __decorate([
    (0, websockets_1.WebSocketGateway)({ path: '/' }),
    __metadata("design:paramtypes", [llm_service_1.LlmService])
], StudentGateway);
//# sourceMappingURL=student.gateway.js.map