import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';

/**
 * Calls your friend's LLM via OpenAI-compatible API.
 *
 * Set in .env:
 *   LLM_BASE_URL  — base URL, e.g. http://192.168.1.5:11434
 *   LLM_API_KEY   — Bearer token (leave empty if no auth needed)
 *   LLM_MODEL     — model name, e.g. llama3 / mistral / etc.
 *
 * If the format is NOT OpenAI-compatible, edit sendToLLM() below.
 * The only thing to change is how `body` is built and how the
 * reply text is extracted from `response.data`.
 */
@Injectable()
export class LlmService {
  private readonly logger = new Logger(LlmService.name);
  private readonly http: AxiosInstance;
  private readonly model: string;

  constructor(private cfg: ConfigService) {
    const baseURL = cfg.get<string>('LLM_BASE_URL') ?? 'http://localhost:11434';
    const apiKey  = cfg.get<string>('LLM_API_KEY')  ?? '';
    this.model    = cfg.get<string>('LLM_MODEL')    ?? 'llama3';

    this.http = axios.create({
      baseURL,
      timeout: 60_000,
      headers: {
        'Content-Type': 'application/json',
        ...(apiKey ? { Authorization: `Bearer ${apiKey}` } : {}),
      },
    });
  }

  // ─────────────────────────────────────────────────────────────────────
  // CORE CALL — adjust here if your friend uses a non-standard format
  // ─────────────────────────────────────────────────────────────────────
  async sendToLLM(
    messages: { role: string; content: string }[],
    maxTokens = 1000,
    temperature = 0.7,
  ): Promise<string> {
    const response = await this.http.post('/v1/chat/completions', {
      model: this.model,
      messages,
      max_tokens: maxTokens,
      temperature,
      stream: false,
    });

    // Standard OpenAI response shape
    return response.data.choices?.[0]?.message?.content?.trim() ?? '';
  }

  // ─────────────────────────────────────────────────────────────────────
  // STUDENT CHAT
  // ─────────────────────────────────────────────────────────────────────
  private systemPrompt(lang: string): string {
    const prompts: Record<string, string> = {
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

  async chat(params: {
    message: string;
    subject?: string;
    history?: { role: string; content: string }[];
    lang?: string;
  }): Promise<string> {
    const { message, subject = '', history = [], lang = 'uz' } = params;
    const system = this.systemPrompt(lang) + (subject ? `\nFan/Subject: ${subject}` : '');

    return this.sendToLLM(
      [
        { role: 'system', content: system },
        ...history.slice(-8),           // last 4 turns
        { role: 'user', content: message },
      ],
      800,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // TEST GENERATION
  // Returns array of { savol, variantlar: ['A. ...', ...], togri: 'A' }
  // ─────────────────────────────────────────────────────────────────────
  async generateTest(params: {
    topic: string;
    subject: string;
    count?: number;
    difficulty?: string;
    lang?: string;
  }): Promise<any[]> {
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
    // Strip possible markdown fences
    const cleaned = raw.replace(/```json|```/g, '').trim();
    // Find the JSON array in the response
    const match = cleaned.match(/\[[\s\S]*\]/);
    if (!match) throw new Error('LLM did not return a valid JSON array');
    return JSON.parse(match[0]);
  }

  // ─────────────────────────────────────────────────────────────────────
  // TEST FROM FILE TEXT
  // ─────────────────────────────────────────────────────────────────────
  async generateTestFromText(params: {
    text: string;
    count?: number;
    lang?: string;
  }): Promise<any[]> {
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
    if (!match) throw new Error('LLM did not return a valid JSON array');
    return JSON.parse(match[0]);
  }

  // ─────────────────────────────────────────────────────────────────────
  // LESSON PLAN
  // ─────────────────────────────────────────────────────────────────────
  async generateLessonPlan(params: {
    subject: string;
    topic: string;
    className: string;
    durationMin?: number;
    lang?: string;
  }): Promise<any> {
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
    if (!match) throw new Error('LLM did not return valid JSON');
    return JSON.parse(match[0]);
  }

  // ─────────────────────────────────────────────────────────────────────
  // TTS — forward text to your TTS service if you have one,
  //        or return empty and wire up later
  // ─────────────────────────────────────────────────────────────────────
  async tts(text: string, lang = 'uz'): Promise<{ audio: string; rate: number }> {
    // TODO: call your TTS endpoint and return base64 PCM audio
    // Example with a Coqui TTS server:
    //   const res = await this.http.post('http://tts-server/api/tts', { text, language: lang }, { responseType: 'arraybuffer' })
    //   return { audio: Buffer.from(res.data).toString('base64'), rate: 22050 }
    this.logger.warn('TTS not configured — returning empty audio');
    return { audio: '', rate: 22050 };
  }
}
