# CreateResume AI

An AI-powered Flutter mobile application that helps job seekers build, analyze, and optimize professional resumes. Features include a multi-step Resume Wizard with AI content generation, an ATS Compatibility Analyzer with keyword matching, a Company Apply Hub for tailored applications, a Kanban-style Application Tracker, and a suite of AI tools (Bullet Rewriter, Skill Gap Analyzer, Cover Letter GPT).

## Architecture

The project follows **Clean Architecture** with four layers:

- **Domain** — Pure Dart entities, repository contracts, value objects, and service interfaces. No Flutter, Supabase, or Hive imports.
- **Application** — Use cases orchestrating domain logic and Riverpod state providers (auth, connectivity, theme).
- **Infrastructure** — Supabase implementations of repository contracts, Edge Function wrappers with 10 s timeout + exponential backoff, Hive-based local caching, and PDF generation.
- **Presentation** — Flutter widgets organized into feature modules (Onboarding, Auth, Home Dashboard, Resume Wizard/Editor, Analyzer, Company Apply Hub, Application Tracker, AI Tool Library, Profile/Settings). State is managed exclusively via Riverpod 2.x (`ConsumerWidget`, `AsyncNotifier`). Navigation uses `go_router` with `StatefulShellRoute`.

Dependency direction: **Presentation → Application → Domain ← Infrastructure**.

## Required Environment Variables

Create a `.env` file in the project root with the following keys:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> **Never commit real keys.** The `.env` file is listed in `.gitignore`.

## Getting Started

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (Freezed, JSON serializable, Riverpod codegen)
dart run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

## Tech Stack

| Layer          | Technology                              |
| -------------- | --------------------------------------- |
| UI Framework   | Flutter + Material 3                    |
| State Mgmt     | Riverpod 2.x                            |
| Navigation     | go_router                               |
| Backend        | Supabase (Auth, PostgreSQL, Storage, Edge Functions) |
| Offline Cache  | Hive                                    |
| AI/ML          | Supabase Edge Functions (OpenAI)        |
| PDF Export     | pdf + printing                          |
| Charts         | fl_chart, percent_indicator             |

## License

Proprietary — All rights reserved.
