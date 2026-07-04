import 'package:equatable/equatable.dart';

/// A cover letter generated for a specific company, optionally
/// linked to a resume.
class CoverLetter extends Equatable {
  final String id;
  final String userId;
  final String? resumeId;
  final String companyName;
  final String content;
  final DateTime createdAt;

  const CoverLetter({
    required this.id,
    required this.userId,
    this.resumeId,
    required this.companyName,
    required this.content,
    required this.createdAt,
  });

  CoverLetter copyWith({
    String? id,
    String? userId,
    String? resumeId,
    String? companyName,
    String? content,
    DateTime? createdAt,
  }) {
    return CoverLetter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      resumeId: resumeId ?? this.resumeId,
      companyName: companyName ?? this.companyName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, resumeId, companyName, content, createdAt];
}
