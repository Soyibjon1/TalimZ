# TalimZ

O'zbekiston o'quvchilari uchun AI-asosida shaxsiylashtirilgan ta'lim platformasi — interaktiv darslar, testlar, ovozli repetitor va o'qituvchi paneli.

## Loyiha tuzilmasi

```
TalimZ/
├── mobile-app/     # Flutter mobil ilova (Android / iOS)
├── web/
│   ├── backend/    # NestJS API va WebSocket server
│   └── frontend/   # React veb-interfeys
└── LLLM/           # Python AI server (STT, TTS, chat)
```

## Imkoniyatlar

- **AI repetitor** - lokal LLM orqali shaxsiylashtirilgan yordam
- **Ovozli muloqot** — o'zbek tilida nutqni tanish va sintez qilish
- **Testlar** — avtomatik savol yaratish va darhol baholash
- **O'quv yo'llari** — fanlar bo'yicha moslashuvchan marshrutlar
- **Gamifikatsiya** — XP, nishonlar va kundalik seriya
- **O'qituvchi paneli** — sinf va o'quvchi taraqqiyotini kuzatish

## Tezkor boshlash

### Talablar

- Flutter SDK 3.11+
- Node.js 20+
- Python 3.8+
- Ollama yoki boshqa OpenAI-mos LLM (ixtiyoriy)

### 1. Mobil ilova

```bash
cd mobile-app
cp .env.example .env   # GEMINI_API_KEY ni kiriting
flutter pub get
flutter run
```

### 2. Backend

```bash
cd web/backend
cp .env.example .env   # JWT_SECRET, LLM_BASE_URL ni sozlang
npm install
npm run start:dev
```

### 3. Python AI server (ixtiyoriy)

```bash
cd LLLM
pip install -r requirements.txt
python webs.py
```

### 4. Veb-interfeys

```bash
cd web/frontend
cp .env.example .env   # VITE_WS_URL va VITE_API_URL ni kiriting
npm install
npm run dev
```

## Texnologiyalar

| Qism     | Texnologiya                          |
| -------- | ------------------------------------ |
| Mobil    | Flutter, Provider, GoRouter          |
| Backend  | NestJS, WebSocket, JWT               |
| Frontend | React, Vite                          |
| AI       | Lokal LLM, Ollama, Vosk (o'zbek STT) |

## Muhit o'zgaruvchilari

Har bir modulda `.env.example` fayli mavjud. Uni `.env` ga nusxalab, API kalitlari va server manzillarini to'ldiring.
