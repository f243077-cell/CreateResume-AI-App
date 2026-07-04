import 'package:equatable/equatable.dart';

/// Status of a job application.
enum ApplicationStatus { applied, interview, offer, archived }

/// Tracks a job application linked to a specific resume.
class Application extends Equatable {
  final String id;
  final String userId;
  final String resumeId;
  final String companyName;
  final String jobTitle;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final String? notes;

  const Application({
    required this.id,
    required this.userId,
    required this.resumeId,
    required this.companyName,
    required this.jobTitle,
    this.status = ApplicationStatus.applied,
    required this.appliedDate,
    this.notes,
  });

  Application copyWith({
    String? id,
    String? userId,
    String? resumeId,
    String? companyName,
    String? jobTitle,
    ApplicationStatus? status,
    DateTime? appliedDate,
    String? notes,
  }) {
    return Application(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      resumeId: resumeId ?? this.resumeId,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        resumeId,
        companyName,
        jobTitle,
        status,
        appliedDate,
        notes,
      ];
}
