import 'package:equatable/equatable.dart';

/// A project entry within a resume.
class Project extends Equatable {
  final String id;
  final String resumeId;
  final String name;
  final String description;
  final List<String> techStack;
  final String? url;
  final int orderIndex;

  const Project({
    required this.id,
    required this.resumeId,
    required this.name,
    this.description = '',
    this.techStack = const [],
    this.url,
    this.orderIndex = 0,
  });

  Project copyWith({
    String? id,
    String? resumeId,
    String? name,
    String? description,
    List<String>? techStack,
    String? url,
    int? orderIndex,
  }) {
    return Project(
      id: id ?? this.id,
      resumeId: resumeId ?? this.resumeId,
      name: name ?? this.name,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
      url: url ?? this.url,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props =>
      [id, resumeId, name, description, techStack, url, orderIndex];
}
