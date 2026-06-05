import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { Controller, Post, Body, UseGuards, Get } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { JwtService } from '@nestjs/jwt';
import { IsEmail, IsString, MinLength, IsOptional } from 'class-validator';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import * as bcrypt from 'bcryptjs';
import { v4 as uuid } from 'uuid';
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

// ── DTOs ─────────────────────────────────────────────────────────────────
class RegisterDto {
  @IsString() full_name: string;
  @IsEmail() email: string;
  @IsString() @MinLength(6) password: string;
  @IsOptional() @IsString() role?: string;
  @IsOptional() @IsString() class_name?: string;
}

class LoginDto {
  @IsEmail() email: string;
  @IsString() password: string;
}

// ── Current user decorator ────────────────────────────────────────────────
export const CurrentUser = createParamDecorator(
  (_: unknown, ctx: ExecutionContext) => ctx.switchToHttp().getRequest().user,
);

// ── JWT strategy ──────────────────────────────────────────────────────────
@Injectable()
class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(cfg: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: cfg.get('JWT_SECRET') ?? 'talimz-dev-secret',
    });
  }
  validate(payload: any) {
    return { id: payload.sub, email: payload.email, role: payload.role, plan: payload.plan };
  }
}

// ── Auth service ──────────────────────────────────────────────────────────
@Injectable()
class AuthService {
  constructor(private jwt: JwtService) {}

  async register(dto: RegisterDto) {
    // TODO: check email uniqueness in DB, then save
    const hash = await bcrypt.hash(dto.password, 10);
    const user = {
      id: uuid(),
      full_name: dto.full_name,
      email: dto.email,
      role: dto.role ?? 'student',
      plan: 'free',
      class_name: dto.class_name ?? null,
    };
    // TODO: await db.users.create({ ...user, password_hash: hash })
    return { access_token: this.sign(user), user };
  }

  async login(dto: LoginDto) {
    // TODO: fetch from DB, compare hash
    // const user = await db.users.findOne({ email: dto.email })
    // if (!user || !await bcrypt.compare(dto.password, user.password_hash))
    //   throw new UnauthorizedException('Invalid credentials')
    const user = { id: uuid(), email: dto.email, role: 'teacher', plan: 'pro', full_name: 'Demo User' };
    return { access_token: this.sign(user), user };
  }

  refresh(user: any) {
    return { access_token: this.sign(user) };
  }

  private sign(user: any) {
    return this.jwt.sign({ sub: user.id, email: user.email, role: user.role, plan: user.plan });
  }
}

// ── Auth controller ───────────────────────────────────────────────────────
@ApiTags('Auth')
@Controller('auth')
class AuthController {
  constructor(private svc: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register student or teacher' })
  register(@Body() dto: RegisterDto) { return this.svc.register(dto); }

  @Post('login')
  @ApiOperation({ summary: 'Login — returns JWT' })
  login(@Body() dto: LoginDto) { return this.svc.login(dto); }

  @Post('refresh')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  refresh(@CurrentUser() user: any) { return this.svc.refresh(user); }

  @Post('logout')
  logout() { return { message: 'ok' }; }
}

// ── Auth module ───────────────────────────────────────────────────────────
@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (cfg: ConfigService) => ({
        secret: cfg.get('JWT_SECRET') ?? 'talimz-dev-secret',
        signOptions: { expiresIn: cfg.get('JWT_EXPIRES') ?? '30d' },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [JwtModule],
})
export class AuthModule {}
