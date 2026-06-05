# TalimZ 📚

AI yordamida o'zbek o'quvchilar uchun shaxsiylashtirilgan ta'lim, interaktiv testlar va aqlli repetitorlik xizmatlarini taqdim etuvchi zamonaviy ta'lim platformasi.

## 🚀 Imkoniyatlar

### 🧠 AI-Powered Ta'lim
- **Aqlli Chat Yordamchi** — Gemini API va WebSocket AI asosida shaxsiylashtirilgan AI repetitor
- **Ovozli Muloqot** — O'zbek tilida nutqni matnga va matni nutqqa aylantirish
- **Moslashuvchan O'quv Yo'llari** — AI tavsiya etgan, natijaga asoslangan o'quv marshrutlari
- **Real Vaqt Tahlili** — AI yordamida o'quv taraqqiyotini kuzatish va tahlil qilish

### 📖 Asosiy O'quv Imkoniyatlari
- **Interaktiv Fanlar** — Matematika, Fizika, Kimyo, Biologiya va boshqa fanlar
- **Dinamik Testlar** — Avtomatik yaratilgan savollar va darhol natija
- **Taraqqiyotni Kuzatish** — XP tizimi, nishonlar va yutuq darajalari
- **O'quv Seriyasi** — Kundalik o'qishni gamifikatsiya orqali rag'batlantirish

### 👨‍🏫 O'qituvchi Paneli
- **Sinf Tahlili** — O'quvchilar ko'rsatkichlari va umumiy holat
- **AI Baholash** — O'quvchilarning kuchli va zaif tomonlarini avtomatik tahlil qilish
- **Taraqqiyotni Monitoring** — Har bir o'quvchi va sinf bo'yicha real vaqt kuzatuvi

### 🎯 Zamonaviy UX/UI
- **Material Design 3** — Qulay va tartibli interfeys
- **Silliq Animatsiyalar** — Flutter Animate bilan jozibali interaktivlik
- **Moslashuvchan Qoʻllanma** — Barcha ekran o'lchamlariga moslashtirilgan
- **Qorong'u/Yorug' Mavzu** — Avtomatik tematik tizim

### Ma'lumotlar va Saqlash
- **Lokal Saqlash:** SharedPreferences
- **Ma'lumot Modellari:** Keng qamrovli ta'lim ma'lumot tuzilmalari
- **API Integratsiya:** RESTful va WebSocket API

## 📱 O'rnatish

### Talablar
- Flutter SDK 3.11.0 yoki undan yuqori
- Android Studio / VS Code
- Python 3.8+ (AI server uchun)

### O'rnatish Ko'rsatmalari

1. **Repozitoriyani klonlash**
```bash
git clone https://github.com/Soyibjon1/TalimZ.git
cd Maktab
```

3. **Ilovani Ishga Tushirish**
```bash
flutter run
```

### Ixtiyoriy: AI Server Sozlash

Kengaytirilgan AI funksiyalari uchun Python WebSocket serverini sozlang:

```bash
# Python kutubxonalarini o'rnatish
pip install websockets asyncio

# AI serverni ishga tushirish
python python_ai_server_example.py
```

## 🏗 Loyiha Tuzilmasi

```
lib/
├── core/
│   ├── models/          # Ma'lumot modellari
│   ├── services/        # AI, ovoz va API xizmatlari
│   ├── providers/       # Holat boshqaruvi
│   ├── theme/           # UI mavzu va uslublar
│   ├── widgets/         # Qayta ishlatiladigan UI komponentlar
│   └── router/          # Navigatsiya konfiguratsiyasi
├── features/
│   ├── ai_chat/         # AI repetitor interfeysi
│   ├── learn/           # O'quv modullari va yo'llari
│   ├── quiz/            # Interaktiv test tizimi
│   ├── profile/         # Foydalanuvchi profili va statistika
│   ├── teacher/         # O'qituvchi paneli va tahlil
│   └── splash/          # Kirish ekranlari
└── shared/              # Umumiy widgetlar va yordamchi funksiyalar
```

## 🎮 Asosiy Funksiyalar

### AI Chat Tizimi
- Ko'p modellli AI integratsiya (Gemini + Maxsus WebSocket)
- Kontekstga mos ta'lim javoblari
- O'zbek tilida ovozli kirish/chiqish
- Fanga yo'naltirilgan repetitorlik

### Test Mexanizmi
- Dinamik savol generatsiyasi
- Ko'p turdagi savollar (test, to'g'ri/noto'g'ri)
- Real vaqt baholash va fikr-mulohaza
- Ko'rsatkich tahlili

### O'quv Tahlili
- XP va daraja o'sish tizimi
- Yutuq nishonlari va mukofotlar
- Kundalik o'quv seriyasini kuzatish
- Shaxsiylashtirilgan o'quv tavsiyalari

### O'qituvchi Vositalari
- Sinf ko'rsatkichlari umumiy ko'rinishi
- Har bir o'quvchi tahlili
- AI yordamida tushuncha va tavsiyalar
- Taraqqiyot kuzatuv panellari

## 🔧 Sozlash

### Muhit O'zgaruvchilari
`.env` faylini yarating:
```

### Moslashtiruv Imkoniyatlari
- Fanlarni `lib/core/data/mock_data.dart` da o'zgartiring
- AI promptlarini xizmat fayllarida sozlang
- Mavzularni `lib/core/theme/` da moslang

## 🚀 Nashr Qilish

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Hissa Qo'shish

Hissalaringizni mamnuniyat bilan qabul qilamiz! PR yuborishdan oldin [Hissa Qo'shish Qoidalari](CONTRIBUTING.md) ni o'qing.

### Ishlab Chiqish Jarayoni
1. Repozitoriyani fork qiling
2. Feature branch yarating: `git checkout -b feature/ajoyib-funksiya`
3. O'zgarishlarni saqlang: `git commit -m 'Ajoyib funksiya qoshildi'`
4. Branch ga push qiling: `git push origin feature/ajoyib-funksiya`
5. Pull Request oching

## 📄 Litsenziya

Ushbu loyiha MIT Litsenziyasi ostida tarqatiladi — batafsil [LICENSE](LICENSE) faylida.



**TalimZ** — O'zbek o'quvchilarini AI-asosida ta'lim bilan kuchaytirish
