import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // WebSocket AI xizmatini asinxron ishga tushirish (crash qilmasligi uchun)
  _initializeAI();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const TalimZApp(),
    ),
  );
}

// AI serverni asinxron ishga tushirish (hozircha o'chirib qo'yilgan)
void _initializeAI() {
  // WebSocket AI server ulanishini hozircha o'chirib qo'yamiz
  // Chunki ngrok tunnel ishlamayapti
  debugPrint('AI server initialization o\'chirib qo\'yilgan (ngrok muammo)');
  
  /* 
  Future.delayed(const Duration(seconds: 2), () {
    try {
      final wsService = WebSocketAiService();
      wsService.connect();
      debugPrint('AI server ulanish jarayoni boshlandi');
    } catch (e) {
      debugPrint('AI server ulanmadi: $e');
    }
  });
  */
}

class TalimZApp extends StatelessWidget {
  const TalimZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TalimZ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
