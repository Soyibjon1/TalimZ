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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var _a, _b;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const uuid_1 = require("uuid");
const llm_service_1 = require("./llm.service");
class ChatDto {
}
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ChatDto.prototype, "message", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ChatDto.prototype, "subject", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ChatDto.prototype, "conversation_id", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Array)
], ChatDto.prototype, "history", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ChatDto.prototype, "lang", void 0);
class GenerateTestDto {
}
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GenerateTestDto.prototype, "topic", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GenerateTestDto.prototype, "subject", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(30),
    __metadata("design:type", Number)
], GenerateTestDto.prototype, "count", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GenerateTestDto.prototype, "difficulty", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GenerateTestDto.prototype, "lang", void 0);
class LessonPlanDto {
}
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LessonPlanDto.prototype, "subject", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LessonPlanDto.prototype, "topic", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LessonPlanDto.prototype, "class_name", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], LessonPlanDto.prototype, "duration_min", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LessonPlanDto.prototype, "lang", void 0);
let AiController = class AiController {
    constructor(llm) {
        this.llm = llm;
    }
    async chat(dto) {
        const reply = await this.llm.chat(dto);
        return {
            reply,
            conversation_id: dto.conversation_id ?? (0, uuid_1.v4)(),
            lang: dto.lang ?? 'uz',
        };
    }
    async generateTest(dto) {
        const questions = await this.llm.generateTest(dto);
        const testId = (0, uuid_1.v4)();
        return {
            test_id: testId,
            subject: dto.subject,
            topic: dto.topic,
            question_count: questions.length,
            questions,
            time_limit_min: questions.length * 2,
        };
    }
    async testFromFile(file, count = '10', lang = 'uz') {
        if (!file)
            throw new common_1.BadRequestException('PDF or PPTX file required');
        let text = '';
        if (file.mimetype === 'application/pdf') {
            text = 'PDF text extraction not yet wired up';
        }
        else {
            text = 'PPTX text extraction not yet wired up';
        }
        const questions = await this.llm.generateTestFromText({
            text,
            count: Number(count),
            lang,
        });
        return { test_id: (0, uuid_1.v4)(), filename: file.originalname, questions };
    }
    async lessonPlan(dto) {
        const plan = await this.llm.generateLessonPlan({
            subject: dto.subject,
            topic: dto.topic,
            className: dto.class_name,
            durationMin: dto.duration_min,
            lang: dto.lang,
        });
        return { lesson_id: (0, uuid_1.v4)(), ...dto, ...plan };
    }
};
exports.AiController = AiController;
__decorate([
    (0, common_1.Post)('chat'),
    (0, swagger_1.ApiOperation)({ summary: 'AI chat via REST (teacher dashboard uses this)' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [ChatDto]),
    __metadata("design:returntype", Promise)
], AiController.prototype, "chat", null);
__decorate([
    (0, common_1.Post)('test/generate'),
    (0, swagger_1.ApiOperation)({ summary: 'Generate MCQ test from topic (teacher dashboard)' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [GenerateTestDto]),
    __metadata("design:returntype", Promise)
], AiController.prototype, "generateTest", null);
__decorate([
    (0, common_1.Post)('test/from-file'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('file', { limits: { fileSize: 10 * 1024 * 1024 } })),
    (0, swagger_1.ApiOperation)({ summary: 'Upload PDF/PPTX, generate test from its content' }),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Body)('count')),
    __param(2, (0, common_1.Body)('lang')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_b = typeof Express !== "undefined" && (_a = Express.Multer) !== void 0 && _a.File) === "function" ? _b : Object, Object, Object]),
    __metadata("design:returntype", Promise)
], AiController.prototype, "testFromFile", null);
__decorate([
    (0, common_1.Post)('lesson-plan'),
    (0, swagger_1.ApiOperation)({ summary: 'Generate AI lesson plan' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [LessonPlanDto]),
    __metadata("design:returntype", Promise)
], AiController.prototype, "lessonPlan", null);
exports.AiController = AiController = __decorate([
    (0, swagger_1.ApiTags)('AI'),
    (0, common_1.Controller)('ai'),
    __metadata("design:paramtypes", [llm_service_1.LlmService])
], AiController);
//# sourceMappingURL=ai.controller.js.map