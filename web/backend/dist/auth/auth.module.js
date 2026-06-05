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
exports.AuthModule = exports.CurrentUser = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const passport_1 = require("@nestjs/passport");
const config_1 = require("@nestjs/config");
const common_2 = require("@nestjs/common");
const passport_2 = require("@nestjs/passport");
const passport_jwt_1 = require("passport-jwt");
const common_3 = require("@nestjs/common");
const passport_3 = require("@nestjs/passport");
const jwt_2 = require("@nestjs/jwt");
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
const bcrypt = require("bcryptjs");
const uuid_1 = require("uuid");
const common_4 = require("@nestjs/common");
class RegisterDto {
}
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], RegisterDto.prototype, "full_name", void 0);
__decorate([
    (0, class_validator_1.IsEmail)(),
    __metadata("design:type", String)
], RegisterDto.prototype, "email", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(6),
    __metadata("design:type", String)
], RegisterDto.prototype, "password", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], RegisterDto.prototype, "role", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], RegisterDto.prototype, "class_name", void 0);
class LoginDto {
}
__decorate([
    (0, class_validator_1.IsEmail)(),
    __metadata("design:type", String)
], LoginDto.prototype, "email", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LoginDto.prototype, "password", void 0);
exports.CurrentUser = (0, common_4.createParamDecorator)((_, ctx) => ctx.switchToHttp().getRequest().user);
let JwtStrategy = class JwtStrategy extends (0, passport_2.PassportStrategy)(passport_jwt_1.Strategy) {
    constructor(cfg) {
        super({
            jwtFromRequest: passport_jwt_1.ExtractJwt.fromAuthHeaderAsBearerToken(),
            secretOrKey: cfg.get('JWT_SECRET') ?? 'talimz-dev-secret',
        });
    }
    validate(payload) {
        return { id: payload.sub, email: payload.email, role: payload.role, plan: payload.plan };
    }
};
JwtStrategy = __decorate([
    (0, common_2.Injectable)(),
    __metadata("design:paramtypes", [typeof (_a = typeof config_1.ConfigService !== "undefined" && config_1.ConfigService) === "function" ? _a : Object])
], JwtStrategy);
let AuthService = class AuthService {
    constructor(jwt) {
        this.jwt = jwt;
    }
    async register(dto) {
        const hash = await bcrypt.hash(dto.password, 10);
        const user = {
            id: (0, uuid_1.v4)(),
            full_name: dto.full_name,
            email: dto.email,
            role: dto.role ?? 'student',
            plan: 'free',
            class_name: dto.class_name ?? null,
        };
        return { access_token: this.sign(user), user };
    }
    async login(dto) {
        const user = { id: (0, uuid_1.v4)(), email: dto.email, role: 'teacher', plan: 'pro', full_name: 'Demo User' };
        return { access_token: this.sign(user), user };
    }
    refresh(user) {
        return { access_token: this.sign(user) };
    }
    sign(user) {
        return this.jwt.sign({ sub: user.id, email: user.email, role: user.role, plan: user.plan });
    }
};
AuthService = __decorate([
    (0, common_2.Injectable)(),
    __metadata("design:paramtypes", [typeof (_b = typeof jwt_2.JwtService !== "undefined" && jwt_2.JwtService) === "function" ? _b : Object])
], AuthService);
let AuthController = class AuthController {
    constructor(svc) {
        this.svc = svc;
    }
    register(dto) { return this.svc.register(dto); }
    login(dto) { return this.svc.login(dto); }
    refresh(user) { return this.svc.refresh(user); }
    logout() { return { message: 'ok' }; }
};
__decorate([
    (0, common_3.Post)('register'),
    (0, swagger_1.ApiOperation)({ summary: 'Register student or teacher' }),
    __param(0, (0, common_3.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [RegisterDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "register", null);
__decorate([
    (0, common_3.Post)('login'),
    (0, swagger_1.ApiOperation)({ summary: 'Login — returns JWT' }),
    __param(0, (0, common_3.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [LoginDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "login", null);
__decorate([
    (0, common_3.Post)('refresh'),
    (0, common_3.UseGuards)((0, passport_3.AuthGuard)('jwt')),
    (0, swagger_1.ApiBearerAuth)(),
    __param(0, (0, exports.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "refresh", null);
__decorate([
    (0, common_3.Post)('logout'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "logout", null);
AuthController = __decorate([
    (0, swagger_1.ApiTags)('Auth'),
    (0, common_3.Controller)('auth'),
    __metadata("design:paramtypes", [AuthService])
], AuthController);
let AuthModule = class AuthModule {
};
exports.AuthModule = AuthModule;
exports.AuthModule = AuthModule = __decorate([
    (0, common_1.Module)({
        imports: [
            passport_1.PassportModule,
            jwt_1.JwtModule.registerAsync({
                imports: [config_1.ConfigModule],
                useFactory: (cfg) => ({
                    secret: cfg.get('JWT_SECRET') ?? 'talimz-dev-secret',
                    signOptions: { expiresIn: cfg.get('JWT_EXPIRES') ?? '30d' },
                }),
                inject: [config_1.ConfigService],
            }),
        ],
        controllers: [AuthController],
        providers: [AuthService, JwtStrategy],
        exports: [jwt_1.JwtModule],
    })
], AuthModule);
//# sourceMappingURL=auth.module.js.map