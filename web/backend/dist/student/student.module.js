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
Object.defineProperty(exports, "__esModule", { value: true });
exports.StudentModule = void 0;
const common_1 = require("@nestjs/common");
const passport_1 = require("@nestjs/passport");
const swagger_1 = require("@nestjs/swagger");
const auth_module_1 = require("../auth/auth.module");
let StudentController = class StudentController {
    profile(user) {
        return {
            id: user.id, email: user.email, plan: user.plan,
            full_name: 'Demo Student', class_name: '9-A',
            xp: 0, level: 1, streak_days: 0,
            subject_scores: {}, attendance_percent: 100,
        };
    }
    dashboard(user) {
        return {
            today: new Date().toISOString().slice(0, 10),
            daily_xp_earned: 0, daily_xp_goal: 200, streak_days: 0,
            tasks_today: [],
            leaderboard: { my_rank: 1, my_xp: 0, top_3: [] },
        };
    }
    subjects() {
        return { subjects: [
                { id: 'math', name: 'Matematika', icon: '🧮', progress: 0, last_score: null },
                { id: 'physics', name: 'Fizika', icon: '⚛️', progress: 0, last_score: null },
                { id: 'english', name: 'Ingliz tili', icon: '🌍', progress: 0, last_score: null },
            ] };
    }
    submitProgress(body, user) {
        const xp = Math.max(10, Math.floor((body.score ?? 0) / 2));
        return { status: 'saved', xp_earned: xp };
    }
};
__decorate([
    (0, common_1.Get)('profile'),
    __param(0, (0, auth_module_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentController.prototype, "profile", null);
__decorate([
    (0, common_1.Get)('dashboard'),
    __param(0, (0, auth_module_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], StudentController.prototype, "dashboard", null);
__decorate([
    (0, common_1.Get)('subjects'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], StudentController.prototype, "subjects", null);
__decorate([
    (0, common_1.Post)('progress'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, auth_module_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], StudentController.prototype, "submitProgress", null);
StudentController = __decorate([
    (0, swagger_1.ApiTags)('Student'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    (0, common_1.Controller)('student')
], StudentController);
let StudentModule = class StudentModule {
};
exports.StudentModule = StudentModule;
exports.StudentModule = StudentModule = __decorate([
    (0, common_1.Module)({ controllers: [StudentController] })
], StudentModule);
//# sourceMappingURL=student.module.js.map