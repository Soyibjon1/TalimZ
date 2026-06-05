"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const platform_ws_1 = require("@nestjs/platform-ws");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.enableCors({
        origin: process.env.ALLOWED_ORIGINS?.split(',') ?? '*',
        credentials: true,
    });
    app.useGlobalPipes(new common_1.ValidationPipe({ whitelist: true, transform: true }));
    app.useWebSocketAdapter(new platform_ws_1.WsAdapter(app));
    const swagger = new swagger_1.DocumentBuilder()
        .setTitle('TalimZ API')
        .setVersion('1.0')
        .addBearerAuth()
        .build();
    swagger_1.SwaggerModule.setup('docs', app, swagger_1.SwaggerModule.createDocument(app, swagger));
    const port = process.env.PORT ?? 8000;
    await app.listen(port);
    console.log(`🚀  TalimZ API  →  http://localhost:${port}`);
    console.log(`📖  Swagger      →  http://localhost:${port}/docs`);
}
bootstrap();
//# sourceMappingURL=main.js.map