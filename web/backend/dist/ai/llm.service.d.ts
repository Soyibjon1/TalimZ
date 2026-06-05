import { ConfigService } from '@nestjs/config';
export declare class LlmService {
    private cfg;
    private readonly logger;
    private readonly http;
    private readonly model;
    constructor(cfg: ConfigService);
    sendToLLM(messages: {
        role: string;
        content: string;
    }[], maxTokens?: number, temperature?: number): Promise<string>;
    private systemPrompt;
    chat(params: {
        message: string;
        subject?: string;
        history?: {
            role: string;
            content: string;
        }[];
        lang?: string;
    }): Promise<string>;
    generateTest(params: {
        topic: string;
        subject: string;
        count?: number;
        difficulty?: string;
        lang?: string;
    }): Promise<any[]>;
    generateTestFromText(params: {
        text: string;
        count?: number;
        lang?: string;
    }): Promise<any[]>;
    generateLessonPlan(params: {
        subject: string;
        topic: string;
        className: string;
        durationMin?: number;
        lang?: string;
    }): Promise<any>;
    tts(text: string, lang?: string): Promise<{
        audio: string;
        rate: number;
    }>;
}
