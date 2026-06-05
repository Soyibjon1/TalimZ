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
exports.TeacherModule = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const passport_1 = require("@nestjs/passport");
const swagger_1 = require("@nestjs/swagger");
const uuid_1 = require("uuid");
const auth_module_1 = require("../auth/auth.module");
const MOCK_STUDENTS = [
    { id: '1', name: 'Asadbek Olimov', class: '9-A', attendance: 98, avg_score: 4.9, status: 'excellent', xp: 5200 },
    { id: '2', name: 'Zilola Karimova', class: '9-A', attendance: 92, avg_score: 4.5, status: 'good', xp: 3800 },
    { id: '3', name: 'Davron Sobirov', class: '10-B', attendance: 76, avg_score: 3.2, status: 'needs-help', xp: 1200 },
    { id: '4', name: 'Ali Valiyev', class: '10-A', attendance: 94, avg_score: 4.7, status: 'excellent', xp: 4900 },
    { id: '5', name: 'Madina Akramova', class: '9V', attendance: 95, avg_score: 4.6, status: 'excellent', xp: 4200 },
    { id: '6', name: 'Kamola Tursunova', class: '9-A', attendance: 62, avg_score: 3.5, status: 'needs-help', xp: 900 },
    { id: '7', name: 'Jasur Xoliqov', class: '8-A', attendance: 85, avg_score: 3.8, status: 'good', xp: 2800 },
];
let TeacherController = class TeacherController {
    dashboard(user) {
        return {
            teacher: { full_name: 'Baxtiyor Ergashev', subject: 'Matematika' },
            stats: { total_students: 76, active_today: 61, avg_class_score: 4.3, attendance_rate: 92 },
            todays_lessons: [
                { class: '9-A', topic: 'Kvadrat tenglamalar', time: '09:00', status: 'completed' },
                { class: '10-B', topic: 'Trigonometriya', time: '11:30', status: 'upcoming' },
            ],
            alerts: [
                { type: 'low_score', student: 'Davron Sobirov', class: '10-B', message: '3 testda 60% dan past' },
                { type: 'absent', student: 'Kamola Tursunova', class: '9-A', message: '5 kunlik qatnashmaslik' },
            ],
        };
    }
    students(className, status) {
        let list = [...MOCK_STUDENTS];
        if (className)
            list = list.filter(s => s.class === className);
        if (status)
            list = list.filter(s => s.status === status);
        return { students: list, total: list.length };
    }
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
    uploadMaterial(file) {
        if (!file)
            return { error: 'No file' };
        return { material_id: (0, uuid_1.v4)(), filename: file.originalname, status: 'processing' };
    }
};
__decorate([
    (0, common_1.Get)('dashboard'),
    __param(0, (0, auth_module_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], TeacherController.prototype, "dashboard", null);
__decorate([
    (0, common_1.Get)('students'),
    __param(0, (0, common_1.Query)('class_name')),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], TeacherController.prototype, "students", null);
__decorate([
    (0, common_1.Get)('analytics'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], TeacherController.prototype, "analytics", null);
__decorate([
    (0, common_1.Post)('upload-material'),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('file', { limits: { fileSize: 10 * 1024 * 1024 } })),
    __param(0, (0, common_1.UploadedFile)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_b = typeof Express !== "undefined" && (_a = Express.Multer) !== void 0 && _a.File) === "function" ? _b : Object]),
    __metadata("design:returntype", void 0)
], TeacherController.prototype, "uploadMaterial", null);
TeacherController = __decorate([
    (0, swagger_1.ApiTags)('Teacher'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    (0, common_1.Controller)('teacher')
], TeacherController);
let TeacherModule = class TeacherModule {
};
exports.TeacherModule = TeacherModule;
exports.TeacherModule = TeacherModule = __decorate([
    (0, common_1.Module)({ controllers: [TeacherController] })
], TeacherModule);
//# sourceMappingURL=teacher.module.js.map