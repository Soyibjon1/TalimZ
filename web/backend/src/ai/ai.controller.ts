import {
  Controller, Post, Get, Body, Param,
  UseInterceptors, UploadedFile, BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { v4 as uuid } from 'uuid';
import { LlmService } from './llm.service';

class ChatDto {
  @IsString() message: string;
  @IsOptional() @IsString() subject?: string;
  @IsOptional() @IsString() conversation_id?: string;
  @IsOptional() history?: any[];
  @IsOptional() @IsString() lang?: string;
}

class GenerateTestDto {
  @IsString() topic: string;
  @IsString() subject: string;
  @IsOptional() @IsNumber() @Min(1) @Max(30) count?: number;
  @IsOptional() @IsString() difficulty?: string;
  @IsOptional() @IsString() lang?: string;
}

class LessonPlanDto {
  @IsString() subject: string;
  @IsString() topic: string;
  @IsString() class_name: string;
  @IsOptional() @IsNumber() duration_min?: number;
  @IsOptional() @IsString() lang?: string;
}

@ApiTags('AI')
@Controller('ai')
export class AiController {
  constructor(private readonly llm: LlmService) {}

  // ── REST chat (teacher dashboard) ─────────────────────────────────
  @Post('chat')
  @ApiOperation({ summary: 'AI chat via REST (teacher dashboard uses this)' })
  async chat(@Body() dto: ChatDto) {
    const reply = await this.llm.chat(dto);
    return {
      reply,
      conversation_id: dto.conversation_id ?? uuid(),
      lang: dto.lang ?? 'uz',
    };
  }

  // ── Test generation ────────────────────────────────────────────────
  @Post('test/generate')
  @ApiOperation({ summary: 'Generate MCQ test from topic (teacher dashboard)' })
  async generateTest(@Body() dto: GenerateTestDto) {
    const questions = await this.llm.generateTest(dto);
    const testId = uuid();
    // In production: store questions in DB keyed by testId so you can grade later
    return {
      test_id: testId,
      subject: dto.subject,
      topic: dto.topic,
      question_count: questions.length,
      questions,
      time_limit_min: questions.length * 2,
    };
  }

  // ── Test from file upload ──────────────────────────────────────────
  @Post('test/from-file')
  @UseInterceptors(FileInterceptor('file', { limits: { fileSize: 10 * 1024 * 1024 } }))
  @ApiOperation({ summary: 'Upload PDF/PPTX, generate test from its content' })
  async testFromFile(
    @UploadedFile() file: Express.Multer.File,
    @Body('count') count = '10',
    @Body('lang') lang = 'uz',
  ) {
    if (!file) throw new BadRequestException('PDF or PPTX file required');

    let text = '';
    if (file.mimetype === 'application/pdf') {
      // TODO: const pdfParse = require('pdf-parse'); text = (await pdfParse(file.buffer)).text;
      text = 'PDF text extraction not yet wired up';
    } else {
      // TODO: const officeparser = require('officeparser'); text = await officeparser.parseOfficeAsync(file.buffer);
      text = 'PPTX text extraction not yet wired up';
    }

    const questions = await this.llm.generateTestFromText({
      text,
      count: Number(count),
      lang,
    });
    return { test_id: uuid(), filename: file.originalname, questions };
  }

  // ── Lesson plan ────────────────────────────────────────────────────
  @Post('lesson-plan')
  @ApiOperation({ summary: 'Generate AI lesson plan' })
  async lessonPlan(@Body() dto: LessonPlanDto) {
    const plan = await this.llm.generateLessonPlan({
      subject: dto.subject,
      topic: dto.topic,
      className: dto.class_name,
      durationMin: dto.duration_min,
      lang: dto.lang,
    });
    return { lesson_id: uuid(), ...dto, ...plan };
  }
}
