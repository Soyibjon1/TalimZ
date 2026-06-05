import { Module, Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CurrentUser } from '../auth/auth.module';

@ApiTags('Student')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('student')
class StudentController {
  @Get('profile')
  profile(@CurrentUser() user: any) {
    // TODO: fetch real profile from DB by user.id
    return {
      id: user.id, email: user.email, plan: user.plan,
      full_name: 'Demo Student', class_name: '9-A',
      xp: 0, level: 1, streak_days: 0,
      subject_scores: {}, attendance_percent: 100,
    };
  }

  @Get('dashboard')
  dashboard(@CurrentUser() user: any) {
    // TODO: fetch real tasks, leaderboard from DB
    return {
      today: new Date().toISOString().slice(0, 10),
      daily_xp_earned: 0, daily_xp_goal: 200, streak_days: 0,
      tasks_today: [],
      leaderboard: { my_rank: 1, my_xp: 0, top_3: [] },
    };
  }

  @Get('subjects')
  subjects() {
    return { subjects: [
      { id: 'math',    name: 'Matematika',  icon: '🧮', progress: 0, last_score: null },
      { id: 'physics', name: 'Fizika',      icon: '⚛️', progress: 0, last_score: null },
      { id: 'english', name: 'Ingliz tili', icon: '🌍', progress: 0, last_score: null },
    ]};
  }

  @Post('progress')
  submitProgress(@Body() body: any, @CurrentUser() user: any) {
    const xp = Math.max(10, Math.floor((body.score ?? 0) / 2));
    // TODO: update DB
    return { status: 'saved', xp_earned: xp };
  }
}

@Module({ controllers: [StudentController] })
export class StudentModule {}
