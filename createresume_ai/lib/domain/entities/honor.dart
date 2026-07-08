import 'package:equatable/equatable.dart';

/// An honor, award, or recognition entry within a resume.
class Honor extends Equatable {
  final String id;
  final String resumeId;
  final String title;
  final String? description;
  final String? certificateUrl;
  final int orderIndex;

  const Honor({
    required this.id,
    required this.resumeId,
    required this.title,
    this.description,
    this.certificateUrl,
    this.orderIndex = 0,
  });

  Honor copyWith({
    String? id,
    String? resumeId,
    String? title,
    String? description,
    String? certificateUrl,
    int? orderIndex,
  }) {
    return Honor(
      id: id ?? this.id,
      resumeId: resumeId ?? this.resumeId,
      title: title ?? this.title,
      description: description ?? this.description,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [
    id,
    resumeId,
    title,
    description,
    certificateUrl,
    orderIndex,
  ];
}
