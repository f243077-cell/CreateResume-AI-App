# CreateResume AI

An AI-powered resume builder built with Flutter. Describe your experience in plain language, and CreateResume AI generates a complete, ATS-optimized resume — ready to export as a polished PDF in one of several professional templates.

## Features

- **AI-Generated Resumes** — Describe your background, skills, and career stage; the app uses AI (via OpenRouter) to draft a full resume, including summary, work experience, education, skills, and projects.
- **Multiple PDF Templates** — Choose from Classic, Modern, Minimal, Executive, and Executive 2 layouts, each with distinct styling.
- **Job-Targeted Optimization** — Optionally paste a job description to tailor the generated resume for a specific role.
- **Resume Management** — Create, edit, duplicate, and organize multiple resumes from a single dashboard.
- **Profile & Credits System** — Free and premium plans with an AI credit balance that governs resume generation.
- **Authentication** — Email/password and Google Sign-In, backed by Supabase Auth.
- **Dark Mode** — Full light/dark theme support.
- **Cross-Platform** — Built with Flutter for Android, iOS, and beyond.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter, Dart |
| State Management | Riverpod |
| Architecture | Clean Architecture (domain / infrastructure / presentation) |
| Backend | Supabase (Auth, Postgres Database, Storage, Edge Functions) |
| AI Provider | OpenRouter API |
| PDF Generation | `pdf` package (custom template engine) |
| Routing | go_router |

## Project Structure

```
lib/
├── domain/                # Entities, repository interfaces, value objects, services
│   ├── entities/
│   ├── repositories/
│   ├── services/
│   └── value_objects/
├── infrastructure/         # Concrete implementations (Supabase, AI, PDF, storage)
│   ├── repositories/
│   └── services/
│       └── templates/      # PDF resume templates
├── presentation/           # UI layer
│   ├── modules/            # Feature modules (resume_wizard, all_resumes, profile, etc.)
│   └── widgets/            # Shared widgets
├── core/                   # Theming, error handling, utilities
├── app_router.dart
└── main.dart

supabase/
└── functions/
    └── dynamic-api/         # Edge Function that calls OpenRouter to generate resumes
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (stable channel)
- A [Supabase](https://supabase.com) project
- An [OpenRouter](https://openrouter.ai) API key

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/f243077-cell/CreateResume-AI-App.git
   cd CreateResume-AI-App/createresume_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a `profiles` table with columns: `id`, `email`, `full_name`, `photo_url`, `subscription_status`, `credit_balance`, `ai_writing_style`, `theme_preference`.
   - Set up authentication (Email/Password and Google OAuth).
   - Add your Supabase URL and anon key to the app's Supabase initialization (typically in `main.dart`).

4. **Deploy the Edge Function**
   ```bash
   supabase functions deploy dynamic-api
   supabase secrets set OPENROUTER_API_KEY=your_openrouter_key_here
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Environment & Secrets

This project keeps sensitive configuration out of version control:

- Supabase credentials should be set via your platform's secure config (not committed).
- `OPENROUTER_API_KEY` is stored as a Supabase Edge Function secret, never in client code.
- The `supabase/` directory (including function source and local config) is excluded from Git — see `.gitignore`.

## Architecture Notes

The app follows Clean Architecture principles:

- **Domain layer** defines contracts (`IAuthRepository`, `IResumeRepository`, etc.) with no external dependencies.
- **Infrastructure layer** implements those contracts using Supabase, OpenRouter, and local services.
- **Presentation layer** consumes domain interfaces through Riverpod providers/notifiers, keeping UI decoupled from backend implementation details.

State is managed with Riverpod notifiers per feature module, and navigation is handled via `go_router` with a shell route providing persistent bottom navigation.

## Roadmap

- [ ] Cover letter generation
- [ ] Resume-to-job ATS scoring
- [ ] Additional export formats
- [ ] Team/collaboration features

## Author

**Tanzeel Hussain**
BS Software Engineering, FAST-NUCES Faisalabad
Flutter Developer 

## License

This project is currently private/unlicensed. All rights reserved.
