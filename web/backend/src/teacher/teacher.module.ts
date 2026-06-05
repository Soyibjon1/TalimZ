import { Module, Controller, Get, Post, Query, UseGuards, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { v4 as uuid } from 'uuid';
import { CurrentUser } from '../auth/auth.module';

// Mock data — replace with real DB queries
const MOCK_STUDENTS = [
  { id: '1', name: 'Asadbek Olimov',    class: '9-A',  attendance: 98, avg_score: 4.9, status: 'excellent',  xp: 5200 },
  { id: '2', name: 'Zilola Karimova',   class: '9-A',  attendance: 92, avg_score: 4.5, status: 'good',       xp: 3800 },
  { id: '3', name: 'Davron Sobirov',    class: '10-B', attendance: 76, avg_score: 3.2, status: 'needs-help', xp: 1200 },
  { id: '4', name: 'Ali Valiyev',       class: '10-A', attendance: 94, avg_score: 4.7, status: 'excellent',  xp: 4900 },
  { id: '5', name: 'Madina Akramova',   class: '9V',   attendance: 95, avg_score: 4.6, status: 'excellent',  xp: 4200 },
  { id: '6', name: 'Kamola Tursunova',  class: '9-A',  attendance: 62, avg_score: 3.5, status: 'needs-help', xp:  900 },
  { id: '7', name: 'Jasur Xoliqov',     class: '8-A',  attendance: 85, avg_score: 3.8, status: 'good',       xp: 2800 },
];

@ApiTags('Teacher')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('teacher')
class TeacherController {
  @Get('dashboard')
  dashboard(@CurrentUser() user: any) {
    // TODO: fetch from DB
    return {
      teacher: { full_name: 'Baxtiyor Ergashev', subject: 'Matematika' },
      stats: { total_students: 76, active_today: 61, avg_class_score: 4.3, attendance_rate: 92 },
      todays_lessons: [
        { class: '9-A', topic: 'Kvadrat tenglamalar', time: '09:00', status: 'completed' },
        { class: '10-B', topic: 'Trigonometriya', time: '11:30', status: 'upcoming' },
      ],
      alerts: [
        { type: 'low_score', student: 'Davron Sobirov', class: '10-B', message: '3 testda 60% dan past' },
        { type: 'absent',    student: 'Kamola Tursunova', class: '9-A', message: '5 kunlik qatnashmaslik' },
      ],
    };
  }

  @Get('students')
  students(
    @Query('class_name') className?: string,
    @Query('status') status?: string,
  ) {
    // TODO: DB query with filters
    let list = [...MOCK_STUDENTS];
    if (className) list = list.filter(s => s.class === className);
    if (status)    list = list.filter(s => s.status === status);
    return { students: list, total: list.length };
  }

  @Get('analytics')
  analytics() {
    return {
      score_trend: [
        { week: 'Sep W1', avg: 72 }, { week: 'Sep W2', avg: 75 },
        { week: 'Sep W3', avg: 78 }, { week: 'Sep W4', avg: 74 },
        { week: 'Oct W1', avg: 80 }, { week: 'Oct W2', avg: 83 },
      ],
      by_subject: { Matematika: 82, Fizika: 74, 'Ingliz tili': 88, Kimyo: 70, Tarix: 65 },
    };
  }

  @Post('upload-material')
  @UseInterceptors(FileInterceptor('file', { limits: { fileSize: 10 * 1024 * 1024 } }))
  uploadMaterial(@UploadedFile() file: Express.Multer.File) {
    if (!file) return { error: 'No file' };
    // TODO: store file, trigger AI processing
    return { material_id: uuid(), filename: file.originalname, status: 'processing' };
  }
}

@Module({ controllers: [TeacherController] })
export class TeacherModule {}
