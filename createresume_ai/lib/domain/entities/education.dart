import 'package:equatable/equatable.dart';

/// An education entry within a resume.
class Education extends Equatable {
  final String id;
  final String resumeId;
  final String institution;
  final String degree;
  final String field;
  final DateTime startDate;
  final DateTime? endDate;
  final double? gpa;
  final int orderIndex;

  const Education({
    required this.id,
    required this.resumeId,
    required this.institution,
    required this.degree,
    required this.field,
    required this.startDate,
    this.endDate,
    this.gpa,
    this.orderIndex = 0,
  });

  Education copyWith({
    String? id,
    String? resumeId,
    String? institution,
    String? degree,
    String? field,
    DateTime? startDate,
    DateTime? endDate,
    double? gpa,
    int? orderIndex,
  }) {
    return Education(
      id: id ?? this.id,
      resumeId: resumeId ?? this.resumeId,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      field: field ?? this.field,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      gpa: gpa ?? this.gpa,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        resumeId,
        institution,
        degree,
        field,
        startDate,
        endDate,
        gpa,
        orderIndex,
      ];
}
