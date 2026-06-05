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
var LlmService_1;
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.LlmService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const axios_1 = require("axios");
let LlmService = LlmService_1 = class LlmService {
    constructor(cfg) {
        this.cfg = cfg;
        this.logger = new common_1.Logger(LlmService_1.name);
        const baseURL = cfg.get('LLM_BASE_URL') ?? 'http://localhost:11434';
        const apiKey = cfg.get('LLM_API_KEY') ?? '';
        this.model = cfg.get('LLM_MODEL') ?? 'llama3';
        this.http = axios_1.default.create({
            baseURL,
            timeout: 60_000,
            headers: {
                'Content-Type': 'application/json',
                ...(apiKey ? { Authorization: `Bearer ${apiKey}` } : {}),
            },
        });
    }
    async sendToLLM(messages, maxTokens = 1000, temperature = 0.7) {
        const response = await this.http.post('/v1/chat/completions', {
            model: this.model,
            messages,
            max_tokens: maxTokens,
            temperature,
            stream: false,
        });
        return response.data.choices?.[0]?.message?.content?.trim() ?? '';
    }
    systemPrompt(lang) {
        const prompts = {
            uz: `Sen TalimZ AI o'qituvchisi — Hilda. O'zbekiston maktab o'quvchilariga (10-17 yosh) yordam berasan.
Doim o'zbek tilida javob ber. Qisqa, aniq va qiziqarli tushuntir.
Matematika, fizika, kimyo, tarix, ingliz tili bo'yicha yordam ber.`,
            ru: `Ты ИИ-учитель TalimZ — Хильда. Помогаешь школьникам Узбекистана (10–17 лет).
Всегда отвечай по-русски. Объясняй кратко, точно и интересно.`,
            en: `You are TalimZ AI teacher — Hilda. You help school students in Uzbekistan (ages 10–17).
Always reply in English. Explain clearly, concisely and engagingly.`,
        };
        return prompts[lang] ?? prompts.uz;
    }
    async chat(params) {
        const { message, subject = '', history = [], lang = 'uz' } = params;
        const system = this.systemPrompt(lang) + (subject ? `\nFan/Subject: ${subject}` : '');
        return this.sendToLLM([
            { role: 'system', content: system },
            ...history.slice(-8),
            { role: 'user', content: message },
        ], 800);
    }
    async generateTest(params) {
        const { topic, subject, count = 10, difficulty = 'medium', lang = 'uz' } = params;
        const inLang = { uz: "O'zbek tilida", ru: 'На русском', en: 'In English' }[lang] ?? "O'zbek tilida";
        const prompt = `${inLang}: "${topic}" (${subject}) bo'yicha ${count} ta test savol yarat. Qiyinlik: ${difficulty}.

Faqat JSON massiv qaytargin, hech qanday izoh yoki markdown yo'q:
[
  {
    "savol": "savol matni",
    "variantlar": ["A. birinchi", "B. ikkinchi", "C. uchinchi", "D. to'rtinchi"],
    "togri": "A"
  }
]`;
        const raw = await this.sendToLLM([{ role: 'user', content: prompt }], 3000, 0.3);
        const cleaned = raw.replace(/```json|```/g, '').trim();
        const match = cleaned.match(/\[[\s\S]*\]/);
        if (!match)
            throw new Error('LLM did not return a valid JSON array');
        return JSON.parse(match[0]);
    }
    async generateTestFromText(params) {
        const { text, count = 10, lang = 'uz' } = params;
        const inLang = { uz: "O'zbek tilida", ru: 'На русском', en: 'In English' }[lang] ?? "O'zbek tilida";
        const prompt = `${inLang}: Quyidagi matn asosida ${count} ta test savol yarat.

MATN:
${text.slice(0, 5000)}

Faqat JSON massiv qaytargin:
[{"savol":"...","variantlar":["A. ...","B. ...","C. ...","D. ..."],"togri":"A"}]`;
        const raw = await this.sendToLLM([{ role: 'user', content: prompt }], 3000, 0.3);
        const cleaned = raw.replace(/```json|```/g, '').trim();
        const match = cleaned.match(/\[[\s\S]*\]/);
        if (!match)
            throw new Error('LLM did not return a valid JSON array');
        return JSON.parse(match[0]);
    }
    async generateLessonPlan(params) {
        const { subject, topic, className, durationMin = 45, lang = 'uz' } = params;
        const inLang = { uz: "O'zbek tilida", ru: 'На русском', en: 'In English' }[lang] ?? "O'zbek tilida";
        const prompt = `${inLang}: ${durationMin} daqiqalik dars rejasi yarat.
Fan: ${subject}, Mavzu: ${topic}, Sinf: ${className}.

Faqat JSON qaytargin:
{
  "maqsadlar": ["..."],
  "bosqichlar": [{"vaqt": "0-5 min", "faoliyat": "..."}],
  "uyga_vazifa": "...",
  "ai_maslahat": "..."
}`;
        const raw = await this.sendToLLM([{ role: 'user', content: prompt }], 1500, 0.5);
        const cleaned = raw.replace(/```json|```/g, '').trim();
        const match = cleaned.match(/\{[\s\S]*\}/);
        if (!match)
            throw new Error('LLM did not return valid JSON');
        return JSON.parse(match[0]);
    }
    async tts(text, lang = 'uz') {
        this.logger.warn('TTS not configured — returning empty audio');
        return { audio: '', rate: 22050 };
    }
};
exports.LlmService = LlmService;
exports.LlmService = LlmService = LlmService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [typeof (_a = typeof config_1.ConfigService !== "undefined" && config_1.ConfigService) === "function" ? _a : Object])
], LlmService);
//# sourceMappingURL=llm.service.js.map