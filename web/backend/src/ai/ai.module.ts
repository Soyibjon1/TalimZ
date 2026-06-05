import { Module } from '@nestjs/common';
import { AiController } from './ai.controller';
import { LlmService } from './llm.service';

@Module({
  controllers: [AiController],
  providers: [LlmService],
  exports: [LlmService],
})
export class AiModule {}
