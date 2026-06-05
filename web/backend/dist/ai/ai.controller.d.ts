import { LlmService } from './llm.service';
declare class ChatDto {
    message: string;
    subject?: string;
    conversation_id?: string;
    history?: any[];
    lang?: string;
}
declare class GenerateTestDto {
    topic: string;
    subject: string;
    count?: number;
    difficulty?: string;
    lang?: string;
}
declare class LessonPlanDto {
    subject: string;
    topic: string;
    class_name: string;
    duration_min?: number;
    lang?: string;
}
export declare class AiController {
    private readonly llm;
    constructor(llm: LlmService);
    chat(dto: ChatDto): unknown;
    generateTest(dto: GenerateTestDto): unknown;
    testFromFile(file: Express.Multer.File, count?: string, lang?: string): unknown;
    lessonPlan(dto: LessonPlanDto): unknown;
}
export {};
