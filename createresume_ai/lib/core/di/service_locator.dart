import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/use_cases/application/create_application_use_case.dart';
import '../../application/use_cases/application/get_applications_use_case.dart';
import '../../application/use_cases/application/track_application_status_use_case.dart';
import '../../application/use_cases/auth/send_password_reset_use_case.dart';
import '../../application/use_cases/auth/sign_in_use_case.dart';
import '../../application/use_cases/auth/sign_out_use_case.dart';
import '../../application/use_cases/auth/sign_up_use_case.dart';
import '../../application/use_cases/resume/analyze_ats_compatibility_use_case.dart';
import '../../application/use_cases/resume/create_resume_use_case.dart';
import '../../application/use_cases/resume/delete_resume_use_case.dart';
import '../../application/use_cases/resume/export_resume_as_pdf_use_case.dart';
import '../../application/use_cases/resume/generate_resume_with_ai_use_case.dart';
import '../../application/use_cases/resume/get_resume_by_id_use_case.dart';
import '../../application/use_cases/resume/get_resumes_use_case.dart';
import '../../application/use_cases/resume/improve_resume_section_use_case.dart';
import '../../application/use_cases/resume/update_resume_use_case.dart';
import '../../application/use_cases/user/get_user_profile_use_case.dart';
import '../../application/use_cases/user/run_ai_tool_use_case.dart';
import '../../application/use_cases/user/update_user_profile_use_case.dart';
import '../../application/use_cases/user/upload_profile_photo_use_case.dart';
import '../../domain/repositories/i_application_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_resume_repository.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../../domain/services/i_ai_content_generator.dart';
import '../../domain/services/i_ats_scoring_service.dart';
import '../../domain/services/i_pdf_generator_service.dart';
import '../../infrastructure/repositories/supabase_application_repository.dart';
import '../../infrastructure/repositories/supabase_auth_repository.dart';
import '../../infrastructure/repositories/supabase_resume_repository.dart';
import '../../infrastructure/repositories/supabase_user_profile_repository.dart';
import '../../infrastructure/services/ai_service.dart';
import '../../infrastructure/services/ats_scoring_service.dart';
import '../../infrastructure/services/local_storage_service.dart';
import '../../infrastructure/services/pdf_generator_service.dart';
import '../../infrastructure/services/supabase_database_service.dart';
import '../../infrastructure/services/supabase_storage_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// INFRASTRUCTURE SERVICES
// ═══════════════════════════════════════════════════════════════════════════

/// Supabase database singleton — available everywhere.
final supabaseDatabaseServiceProvider = Provider<SupabaseDatabaseService>(
  (ref) => SupabaseDatabaseService.instance,
);

/// Supabase storage helper.
final supabaseStorageServiceProvider = Provider<SupabaseStorageService>(
  (ref) => SupabaseStorageService(ref.watch(supabaseDatabaseServiceProvider)),
);

/// Hive local storage cache.
final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(),
);

// ═══════════════════════════════════════════════════════════════════════════
// DOMAIN REPOSITORY BINDINGS
// ═══════════════════════════════════════════════════════════════════════════

/// Auth repository binding.
final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseDatabaseServiceProvider)),
);

/// Resume repository binding.
final resumeRepositoryProvider = Provider<IResumeRepository>(
  (ref) => SupabaseResumeRepository(ref.watch(supabaseDatabaseServiceProvider)),
);

/// Application repository binding.
final applicationRepositoryProvider = Provider<IApplicationRepository>(
  (ref) => SupabaseApplicationRepository(
      ref.watch(supabaseDatabaseServiceProvider)),
);

/// User profile repository binding.
final userProfileRepositoryProvider = Provider<IUserProfileRepository>(
  (ref) => SupabaseUserProfileRepository(
    ref.watch(supabaseDatabaseServiceProvider),
    ref.watch(supabaseStorageServiceProvider),
  ),
);

// ═══════════════════════════════════════════════════════════════════════════
// DOMAIN SERVICE BINDINGS
// ═══════════════════════════════════════════════════════════════════════════

/// AI content generator binding.
final aiContentGeneratorProvider = Provider<IAIContentGenerator>(
  (ref) => AiService(ref.watch(supabaseDatabaseServiceProvider)),
);

/// ATS scoring service binding.
final atsScoringServiceProvider = Provider<IATSScoringService>(
  (ref) => AtsScoringService(ref.watch(supabaseDatabaseServiceProvider)),
);

/// PDF generator service binding.
final pdfGeneratorServiceProvider = Provider<IPDFGeneratorService>(
  (ref) => PdfGeneratorService(ref.watch(supabaseDatabaseServiceProvider)),
);

// ═══════════════════════════════════════════════════════════════════════════
// USE CASE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>(
  (ref) => SendPasswordResetUseCase(ref.watch(authRepositoryProvider)),
);

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>(
  (ref) => GetUserProfileUseCase(ref.watch(userProfileRepositoryProvider)),
);

final uploadProfilePhotoUseCaseProvider = Provider<UploadProfilePhotoUseCase>(
  (ref) => UploadProfilePhotoUseCase(ref.watch(userProfileRepositoryProvider)),
);

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>(
  (ref) => UpdateUserProfileUseCase(ref.watch(userProfileRepositoryProvider)),
);

final runAiToolUseCaseProvider = Provider<RunAiToolUseCase>(
  (ref) => RunAiToolUseCase(ref.watch(userProfileRepositoryProvider)),
);

final getResumesUseCaseProvider = Provider<GetResumesUseCase>(
  (ref) => GetResumesUseCase(ref.watch(resumeRepositoryProvider)),
);

final getResumeByIdUseCaseProvider = Provider<GetResumeByIdUseCase>(
  (ref) => GetResumeByIdUseCase(ref.watch(resumeRepositoryProvider)),
);

final createResumeUseCaseProvider = Provider<CreateResumeUseCase>(
  (ref) => CreateResumeUseCase(ref.watch(resumeRepositoryProvider)),
);

final updateResumeUseCaseProvider = Provider<UpdateResumeUseCase>(
  (ref) => UpdateResumeUseCase(ref.watch(resumeRepositoryProvider)),
);

final deleteResumeUseCaseProvider = Provider<DeleteResumeUseCase>(
  (ref) => DeleteResumeUseCase(ref.watch(resumeRepositoryProvider)),
);

final improveResumeSectionUseCaseProvider =
    Provider<ImproveResumeSectionUseCase>(
  (ref) => ImproveResumeSectionUseCase(ref.watch(aiContentGeneratorProvider)),
);

final getApplicationsUseCaseProvider = Provider<GetApplicationsUseCase>(
  (ref) => GetApplicationsUseCase(ref.watch(applicationRepositoryProvider)),
);

final createApplicationUseCaseProvider = Provider<CreateApplicationUseCase>(
  (ref) => CreateApplicationUseCase(ref.watch(applicationRepositoryProvider)),
);

final generateResumeWithAIUseCaseProvider =
    Provider<GenerateResumeWithAIUseCase>(
  (ref) => GenerateResumeWithAIUseCase(
    aiService: ref.watch(aiContentGeneratorProvider) as AiService,
    resumeRepository: ref.watch(resumeRepositoryProvider),
    userProfileRepository: ref.watch(userProfileRepositoryProvider),
  ),
);

final analyzeAtsCompatibilityUseCaseProvider =
    Provider<AnalyzeAtsCompatibilityUseCase>(
  (ref) => AnalyzeAtsCompatibilityUseCase(
      ref.watch(atsScoringServiceProvider)),
);

final exportResumeAsPdfUseCaseProvider = Provider<ExportResumeAsPdfUseCase>(
  (ref) => ExportResumeAsPdfUseCase(ref.watch(pdfGeneratorServiceProvider)),
);

final trackApplicationStatusUseCaseProvider =
    Provider<TrackApplicationStatusUseCase>(
  (ref) => TrackApplicationStatusUseCase(
      ref.watch(applicationRepositoryProvider)),
);
