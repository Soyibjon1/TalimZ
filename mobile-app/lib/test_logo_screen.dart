import 'package:flutter/material.dart';
import 'core/widgets/logo_widget.dart';
import 'core/theme/app_colors.dart';

/// Logo test sahifasi - barcha logo variantlarini ko'rish uchun
class TestLogoScreen extends StatelessWidget {
  const TestLogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const SmallLogoWidget(size: 32),
            const SizedBox(width: 12),
            const Text("Ta'limZ Logo Test"),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test ma'lumotlari
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📱 Ta\'limZ Logo Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Bu sahifada turli o\'lchamdagi logolarni test qilishingiz mumkin.'),
                    const SizedBox(height: 8),
                    Text(
                      '✅ Haqiqiy logo fayl: assets/images/logo.png',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Katta logo (Splash screen kabi)
              _buildSection(
                'Splash Screen Logo',
                'Ilovani ochishda ko\'rinadigan katta logo',
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFF90CAF9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: LogoWidget(
                      width: 150,
                      height: 150,
                      showText: true,
                      textColor: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Kichik logolar (AppBar)
              _buildSection(
                'AppBar Logolar',
                'Sahifa boshidagi kichik logolar',
                Row(
                  children: [
                    const SmallLogoWidget(size: 24),
                    const SizedBox(width: 8),
                    const SmallLogoWidget(size: 32),
                    const SizedBox(width: 8),
                    const SmallLogoWidget(size: 40),
                    const SizedBox(width: 8),
                    const SmallLogoWidget(size: 48),
                    const Spacer(),
                    Text(
                      "Ta'limZ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Oq fonli logolar (AI Chat)
              _buildSection(
                'AI Chat Logolar',
                'AI Chat sahifasidagi oq fonli logolar',
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SmallLogoWidget(
                        size: 36, 
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Ta'limZ AI",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Logo versiyalari
              _buildSection(
                'Logo Versiyalari',
                'Matn bilan va matnsiz',
                Column(
                  children: [
                    // Matn bilan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const LogoWidget(
                        width: 100,
                        height: 100,
                        showText: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Matnsiz
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const LogoWidget(
                        width: 100,
                        height: 100,
                        showText: false,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Test tugmalar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Logo test muvaffaqiyatli!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Logo Test OK'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Orqaga'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String description, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}