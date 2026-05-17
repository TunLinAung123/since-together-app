# 💕 Together App

A couples app built with **Flutter** & **Supabase** — helping partners stay connected.

## Features

- 🔐 Authentication (Email & Password)
- 💑 Couple linking via invite code
- 💬 Real-time chat
- 📅 Anniversary countdown
- 📸 Photo sharing _(coming soon)_
- 🗓️ Shared calendar _(coming soon)_
- 🎯 Couple goals _(coming soon)_

## Tech Stack

| Layer            | Technology            |
| ---------------- | --------------------- |
| Frontend         | Flutter (Dart)        |
| Backend          | Supabase (PostgreSQL) |
| Auth             | Supabase Auth         |
| Realtime         | Supabase Realtime     |
| Storage          | Supabase Storage      |
| State Management | Riverpod              |
| Navigation       | Go Router             |

## Architecture

lib/
├── core/ # Constants, router, services
├── features/ # Feature-based modules
│ ├── auth/ # Login, register
│ ├── couple/ # Invite & linking
│ ├── chat/ # Real-time messaging
│ ├── countdown/ # Anniversary countdown
│ └── home/ # Dashboard
└── shared/ # Widgets, theme

## Getting Started

1. Clone the repo

```bash
git clone https://github.com/TunLinAung123/since-together-app.git
cd together-app
```

2. Install dependencies

```bash
flutter pub get
```

3. Setup Supabase

```bash
cp lib/core/constants/supabase_constants.example.dart \
   lib/core/constants/supabase_constants.dart
# Fill in your Supabase URL and anon key
```

4. Run the app

```bash
flutter run
```

## Screenshots

_Coming soon_

## License

MIT
