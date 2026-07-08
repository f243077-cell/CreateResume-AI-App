import 'package:equatable/equatable.dart';

/// A skill entry within a resume.
class Skill extends Equatable {
  final String id;
  final String resumeId;
  final String name;
  final String? level;
  final String? category;
  final int orderIndex;

  const Skill({
    required this.id,
    required this.resumeId,
    required this.name,
    this.level,
    this.category,
    this.orderIndex = 0,
  });

  Skill copyWith({
    String? id,
    String? resumeId,
    String? name,
    String? level,
    String? category,
    int? orderIndex,
  }) {
    return Skill(
      id: id ?? this.id,
      resumeId: resumeId ?? this.resumeId,
      name: name ?? this.name,
      level: level ?? this.level,
      category: category ?? this.category,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [id, resumeId, name, level, category, orderIndex];
}
