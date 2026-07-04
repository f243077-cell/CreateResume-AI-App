import 'package:equatable/equatable.dart';

/// A single work experience entry within a resume.
class WorkExperience extends Equatable {
  final String id;
  final String resumeId;
  final String company;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;
  final int orderIndex;

  const WorkExperience({
    required this.id,
    required this.resumeId,
    required this.company,
    required this.role,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description = '',
    this.orderIndex = 0,
  });

  WorkExperience copyWith({
    String? id,
    String? resumeId,
    String? company,
    String? role,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
    int? orderIndex,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      resumeId: resumeId ?? this.resumeId,
      company: company ?? this.company,
      role: role ?? this.role,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        resumeId,
        company,
        role,
        startDate,
        endDate,
        isCurrent,
        description,
        orderIndex,
      ];
}
