import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/application.dart';
import '../../domain/repositories/i_application_repository.dart';
import '../services/supabase_database_service.dart';

/// Supabase implementation of [IApplicationRepository].
class SupabaseApplicationRepository implements IApplicationRepository {
  final SupabaseDatabaseService _db;

  const SupabaseApplicationRepository(this._db);

  @override
  Future<Either<Failure, List<Application>>> getApplications(
      String userId) async {
    try {
      final data = await _db
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('applied_date', ascending: false);

      final applications = (data as List<dynamic>)
          .map((e) => _mapApplication(e as Map<String, dynamic>))
          .toList();

      return Right(applications);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch applications: $e'));
    }
  }

  @override
  Future<Either<Failure, Application>> createApplication(
      Application application) async {
    try {
      final data = await _db.from('applications').insert({
        'id': application.id,
        'user_id': application.userId,
        'resume_id': application.resumeId,
        'company_name': application.companyName,
        'job_title': application.jobTitle,
        'status': application.status.name,
        'applied_date': application.appliedDate.toUtc().toIso8601String(),
        'notes': application.notes,
      }).select().single();

      return Right(_mapApplication(data));
    } catch (e) {
      return Left(ServerFailure('Failed to create application: $e'));
    }
  }

  @override
  Future<Either<Failure, Application>> updateApplicationStatus({
    required String id,
    required ApplicationStatus status,
  }) async {
    try {
      final data = await _db
          .from('applications')
          .update({'status': status.name})
          .eq('id', id)
          .select()
          .single();

      return Right(_mapApplication(data));
    } catch (e) {
      return Left(ServerFailure('Failed to update application status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteApplication(String id) async {
    try {
      await _db.from('applications').delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete application: $e'));
    }
  }

  // ── Mapping ───────────────────────────────────────────────────────

  Application _mapApplication(Map<String, dynamic> data) {
    return Application(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      resumeId: data['resume_id'] as String,
      companyName: data['company_name'] as String,
      jobTitle: data['job_title'] as String,
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ApplicationStatus.applied,
      ),
      appliedDate: DateTime.parse(data['applied_date'] as String),
      notes: data['notes'] as String?,
    );
  }
}
