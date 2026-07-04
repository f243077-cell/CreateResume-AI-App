import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin singleton wrapper for the Supabase client.
///
/// ═══════════════════════════════════════════════════════════════════════
/// POSTGRES SCHEMA
/// ═══════════════════════════════════════════════════════════════════════
///
/// profiles (
///   id            UUID PRIMARY KEY REFERENCES auth.users(id),
///   email         TEXT NOT NULL,
///   full_name     TEXT NOT NULL,
///   photo_url     TEXT,
///   subscription_status TEXT NOT NULL DEFAULT 'free',   -- 'free' | 'premium'
///   credit_balance INTEGER NOT NULL DEFAULT 0,
///   ai_writing_style TEXT,
///   theme_preference TEXT
/// )
///
/// resumes (
///   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
///   title         TEXT NOT NULL,
///   template_id   UUID REFERENCES templates(id),
///   ats_score     INTEGER,
///   is_published  BOOLEAN NOT NULL DEFAULT false,
///   created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
///   updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
/// )
///
/// work_experiences (
///   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   resume_id     UUID NOT NULL REFERENCES resumes(id) ON DELETE CASCADE,
///   company       TEXT NOT NULL,
///   role          TEXT NOT NULL,
///   start_date    DATE NOT NULL,
///   end_date      DATE,
///   is_current    BOOLEAN NOT NULL DEFAULT false,
///   description   TEXT NOT NULL DEFAULT '',
///   order_index   INTEGER NOT NULL DEFAULT 0
/// )
///
/// educations (
///   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   resume_id     UUID NOT NULL REFERENCES resumes(id) ON DELETE CASCADE,
///   institution   TEXT NOT NULL,
///   degree        TEXT NOT NULL,
///   field         TEXT NOT NULL,
///   start_date    DATE NOT NULL,
///   end_date      DATE,
///   gpa           DOUBLE PRECISION,
///   order_index   INTEGER NOT NULL DEFAULT 0
/// )
///
/// skills (
///   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   resume_id     UUID NOT NULL REFERENCES resumes(id) ON DELETE CASCADE,
///   name          TEXT NOT NULL,
///   level         TEXT,
///   order_index   INTEGER NOT NULL DEFAULT 0
/// )
///
/// projects (
///   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   resume_id     UUID NOT NULL REFERENCES resumes(id) ON DELETE CASCADE,
///   name          TEXT NOT NULL,
///   description   TEXT NOT NULL DEFAULT '',
///   tech_stack    TEXT[] DEFAULT '{}',
///   url           TEXT,
///   order_index   INTEGER NOT NULL DEFAULT 0
/// )
///
/// applications (
///   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
///   resume_id     UUID NOT NULL REFERENCES resumes(id),
///   company_name  TEXT NOT NULL,
///   job_title     TEXT NOT NULL,
///   status        TEXT NOT NULL DEFAULT 'applied',  -- applied|interview|offer|archived
///   applied_date  TIMESTAMPTZ NOT NULL DEFAULT now(),
///   notes         TEXT
/// )
///
/// ai_logs (
///   id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
///   tool_used       TEXT NOT NULL,
///   credits_consumed INTEGER NOT NULL DEFAULT 1,
///   input_summary   TEXT,
///   created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
/// )
///
/// templates (
///   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   name          TEXT NOT NULL,
///   preview_url   TEXT,
///   category      TEXT,
///   is_premium    BOOLEAN NOT NULL DEFAULT false
/// )
/// ═══════════════════════════════════════════════════════════════════════
class SupabaseDatabaseService {
  SupabaseDatabaseService._();

  static final SupabaseDatabaseService _instance = SupabaseDatabaseService._();
  static SupabaseDatabaseService get instance => _instance;

  /// The Supabase client singleton.
  SupabaseClient get client => Supabase.instance.client;

  /// Shortcut to the Supabase auth module.
  GoTrueClient get auth => client.auth;

  /// Shortcut to query a table by name.
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Shortcut to invoke an Edge Function.
  FunctionsClient get functions => client.functions;

  /// Shortcut to the Supabase storage module.
  SupabaseStorageClient get storage => client.storage;
}
