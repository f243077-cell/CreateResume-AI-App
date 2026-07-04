import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/education.dart';
import '../../../../domain/entities/project.dart';
import '../../../../domain/entities/resume.dart';
import '../../../../domain/entities/skill.dart';
import '../../../../domain/entities/work_experience.dart';
import '../../../../infrastructure/services/local_pdf_generator_service.dart';
import '../providers/resume_editor_notifier.dart';
import '../widgets/editor_section.dart';
import '../widgets/forms/work_experience_form.dart';

class ResumeEditorScreen extends ConsumerWidget {
  final String resumeId;

  const ResumeEditorScreen({super.key, required this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final editorState = ref.watch(resumeEditorProvider(resumeId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: 'Close editor',
          child: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              // Save on exit
              ref.read(resumeEditorProvider(resumeId).notifier).saveToCloud();
              context.pop();
            },
          ),
        ),
        title: const Text(
          'CRAFT RESUME AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Template selector
          Semantics(
            button: true,
            label: 'Change resume template',
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.style_rounded),
              tooltip: 'Change Template',
              onSelected: (templateId) {
                ref
                    .read(resumeEditorProvider(resumeId).notifier)
                    .changeTemplate(templateId);
              },
              itemBuilder: (context) => LocalPdfGeneratorService
                  .availableTemplates
                  .map(
                    (template) => PopupMenuItem(
                      value: template['id'],
                      child: Row(
                        children: [
                          Icon(_getTemplateIcon(template['id']!), size: 18),
                          const SizedBox(width: 8),
                          Text(template['name']!),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Export resume as PDF',
            child: OutlinedButton(
              onPressed: () {
                ref.read(resumeEditorProvider(resumeId).notifier).exportPdf();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('EXPORT'),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Save resume to cloud',
            child: ElevatedButton(
              onPressed: () {
                ref.read(resumeEditorProvider(resumeId).notifier).saveToCloud();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Saved to Cloud')));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('SAVE'),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: editorState.when(
        data: (resume) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'RESUME STRUCTURE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Professional Summary section
                  _buildSummarySection(context, ref, resume, theme),

                  const SizedBox(height: 16),

                  // Work Experience section
                  RepaintBoundary(
                    child: EditorSection<WorkExperience>(
                      title: 'Work Experience',
                      icon: Icons.business_center_rounded,
                      items: resume.workExperiences,
                      onAdd: () =>
                          _showWorkExperienceForm(context, ref, resume),
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final List<WorkExperience> updatedList = List.from(
                          resume.workExperiences,
                        );
                        final item = updatedList.removeAt(oldIndex);
                        updatedList.insert(newIndex, item);

                        for (int i = 0; i < updatedList.length; i++) {
                          updatedList[i] = updatedList[i].copyWith(
                            orderIndex: i,
                          );
                        }

                        ref
                            .read(resumeEditorProvider(resumeId).notifier)
                            .updateResumeLocally(
                              resume.copyWith(workExperiences: updatedList),
                            );
                      },
                      itemBuilder: (context, exp) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            exp.role,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(exp.company),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () => _showWorkExperienceForm(
                                  context,
                                  ref,
                                  resume,
                                  initialData: exp,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final updatedList = List<WorkExperience>.from(
                                    resume.workExperiences,
                                  );
                                  updatedList.removeWhere(
                                    (e) => e.id == exp.id,
                                  );
                                  ref
                                      .read(
                                        resumeEditorProvider(resumeId).notifier,
                                      )
                                      .updateResumeLocally(
                                        resume.copyWith(
                                          workExperiences: updatedList,
                                        ),
                                      );
                                },
                              ),
                              const Icon(
                                Icons.drag_indicator_rounded,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Education section
                  RepaintBoundary(
                    child: EditorSection<Education>(
                      title: 'Education',
                      icon: Icons.school_rounded,
                      items: resume.educations,
                      onAdd: () => _showEducationForm(context, ref, resume),
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final List<Education> updatedList = List.from(
                          resume.educations,
                        );
                        final item = updatedList.removeAt(oldIndex);
                        updatedList.insert(newIndex, item);

                        for (int i = 0; i < updatedList.length; i++) {
                          updatedList[i] = updatedList[i].copyWith(
                            orderIndex: i,
                          );
                        }

                        ref
                            .read(resumeEditorProvider(resumeId).notifier)
                            .updateResumeLocally(
                              resume.copyWith(educations: updatedList),
                            );
                      },
                      itemBuilder: (context, edu) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            edu.degree,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${edu.institution} • ${edu.field}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () => _showEducationForm(
                                  context,
                                  ref,
                                  resume,
                                  initialData: edu,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final updatedList = List<Education>.from(
                                    resume.educations,
                                  );
                                  updatedList.removeWhere(
                                    (e) => e.id == edu.id,
                                  );
                                  ref
                                      .read(
                                        resumeEditorProvider(resumeId).notifier,
                                      )
                                      .updateResumeLocally(
                                        resume.copyWith(
                                          educations: updatedList,
                                        ),
                                      );
                                },
                              ),
                              const Icon(
                                Icons.drag_indicator_rounded,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skills section
                  RepaintBoundary(
                    child: EditorSection<Skill>(
                      title: 'Skills',
                      icon: Icons.diamond_rounded,
                      items: resume.skills,
                      onAdd: () => _showSkillForm(context, ref, resume),
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final List<Skill> updatedList = List.from(
                          resume.skills,
                        );
                        final item = updatedList.removeAt(oldIndex);
                        updatedList.insert(newIndex, item);

                        for (int i = 0; i < updatedList.length; i++) {
                          updatedList[i] = updatedList[i].copyWith(
                            orderIndex: i,
                          );
                        }

                        ref
                            .read(resumeEditorProvider(resumeId).notifier)
                            .updateResumeLocally(
                              resume.copyWith(skills: updatedList),
                            );
                      },
                      itemBuilder: (context, skill) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            skill.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: skill.level != null
                              ? Text(skill.level!)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () => _showSkillForm(
                                  context,
                                  ref,
                                  resume,
                                  initialData: skill,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final updatedList = List<Skill>.from(
                                    resume.skills,
                                  );
                                  updatedList.removeWhere(
                                    (s) => s.id == skill.id,
                                  );
                                  ref
                                      .read(
                                        resumeEditorProvider(resumeId).notifier,
                                      )
                                      .updateResumeLocally(
                                        resume.copyWith(skills: updatedList),
                                      );
                                },
                              ),
                              const Icon(
                                Icons.drag_indicator_rounded,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Projects section
                  RepaintBoundary(
                    child: EditorSection<Project>(
                      title: 'Projects',
                      icon: Icons.work_rounded,
                      items: resume.projects,
                      onAdd: () => _showProjectForm(context, ref, resume),
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final List<Project> updatedList = List.from(
                          resume.projects,
                        );
                        final item = updatedList.removeAt(oldIndex);
                        updatedList.insert(newIndex, item);

                        for (int i = 0; i < updatedList.length; i++) {
                          updatedList[i] = updatedList[i].copyWith(
                            orderIndex: i,
                          );
                        }

                        ref
                            .read(resumeEditorProvider(resumeId).notifier)
                            .updateResumeLocally(
                              resume.copyWith(projects: updatedList),
                            );
                      },
                      itemBuilder: (context, proj) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            proj.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: proj.description.isNotEmpty
                              ? Text(
                                  proj.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () => _showProjectForm(
                                  context,
                                  ref,
                                  resume,
                                  initialData: proj,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final updatedList = List<Project>.from(
                                    resume.projects,
                                  );
                                  updatedList.removeWhere(
                                    (p) => p.id == proj.id,
                                  );
                                  ref
                                      .read(
                                        resumeEditorProvider(resumeId).notifier,
                                      )
                                      .updateResumeLocally(
                                        resume.copyWith(projects: updatedList),
                                      );
                                },
                              ),
                              const Icon(
                                Icons.drag_indicator_rounded,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text('Failed to load resume: $e'),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: 'Retry loading resume',
                child: ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(resumeEditorProvider(resumeId)),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkExperienceForm(
    BuildContext context,
    WidgetRef ref,
    resume, {
    WorkExperience? initialData,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return WorkExperienceForm(
          initialData: initialData,
          onAiImprove: (text) => ref
              .read(resumeEditorProvider(resumeId).notifier)
              .aiImproveText(text),
          onSave: (updatedExp) {
            final List<WorkExperience> updatedList = List.from(
              resume.workExperiences,
            );
            final index = updatedList.indexWhere((e) => e.id == updatedExp.id);
            if (index >= 0) {
              updatedList[index] = updatedExp;
            } else {
              updatedList.add(
                updatedExp.copyWith(orderIndex: updatedList.length),
              );
            }
            ref
                .read(resumeEditorProvider(resumeId).notifier)
                .updateResumeLocally(
                  resume.copyWith(workExperiences: updatedList),
                );
          },
        );
      },
    );
  }

  void _showEducationForm(
    BuildContext context,
    WidgetRef ref,
    resume, {
    Education? initialData,
  }) {
    final degreeController = TextEditingController(
      text: initialData?.degree ?? '',
    );
    final institutionController = TextEditingController(
      text: initialData?.institution ?? '',
    );
    final fieldController = TextEditingController(
      text: initialData?.field ?? '',
    );
    final gpaController = TextEditingController(
      text: initialData?.gpa?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialData == null ? 'Add Education' : 'Edit Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: degreeController,
                decoration: const InputDecoration(labelText: 'Degree'),
              ),
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(labelText: 'Institution'),
              ),
              TextField(
                controller: fieldController,
                decoration: const InputDecoration(labelText: 'Field of Study'),
              ),
              TextField(
                controller: gpaController,
                decoration: const InputDecoration(labelText: 'GPA (optional)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedEdu = Education(
                id: initialData?.id ?? const Uuid().v4(),
                resumeId: resume.id,
                degree: degreeController.text,
                institution: institutionController.text,
                field: fieldController.text,
                startDate: initialData?.startDate ?? DateTime.now(),
                endDate: initialData?.endDate,
                gpa: double.tryParse(gpaController.text),
                orderIndex: initialData?.orderIndex ?? resume.educations.length,
              );
              final updatedList = List<Education>.from(resume.educations);
              final index = updatedList.indexWhere(
                (e) => e.id == updatedEdu.id,
              );
              if (index >= 0) {
                updatedList[index] = updatedEdu;
              } else {
                updatedList.add(updatedEdu);
              }
              ref
                  .read(resumeEditorProvider(resumeId).notifier)
                  .updateResumeLocally(
                    resume.copyWith(educations: updatedList),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSkillForm(
    BuildContext context,
    WidgetRef ref,
    resume, {
    Skill? initialData,
  }) {
    final nameController = TextEditingController(text: initialData?.name ?? '');
    final levelController = TextEditingController(
      text: initialData?.level ?? 'intermediate',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialData == null ? 'Add Skill' : 'Edit Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Skill Name'),
            ),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(
                labelText: 'Level (beginner/intermediate/expert)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedSkill = Skill(
                id: initialData?.id ?? const Uuid().v4(),
                resumeId: resume.id,
                name: nameController.text,
                level: levelController.text,
                orderIndex: initialData?.orderIndex ?? resume.skills.length,
              );
              final updatedList = List<Skill>.from(resume.skills);
              final index = updatedList.indexWhere(
                (s) => s.id == updatedSkill.id,
              );
              if (index >= 0) {
                updatedList[index] = updatedSkill;
              } else {
                updatedList.add(updatedSkill);
              }
              ref
                  .read(resumeEditorProvider(resumeId).notifier)
                  .updateResumeLocally(resume.copyWith(skills: updatedList));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showProjectForm(
    BuildContext context,
    WidgetRef ref,
    resume, {
    Project? initialData,
  }) {
    final nameController = TextEditingController(text: initialData?.name ?? '');
    final descriptionController = TextEditingController(
      text: initialData?.description ?? '',
    );
    final urlController = TextEditingController(text: initialData?.url ?? '');
    final techStackController = TextEditingController(
      text: initialData?.techStack.join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialData == null ? 'Add Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: techStackController,
                decoration: const InputDecoration(
                  labelText: 'Tech Stack (comma-separated)',
                ),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProject = Project(
                id: initialData?.id ?? const Uuid().v4(),
                resumeId: resume.id,
                name: nameController.text,
                description: descriptionController.text,
                techStack: techStackController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList(),
                url: urlController.text.isEmpty ? null : urlController.text,
                orderIndex: initialData?.orderIndex ?? resume.projects.length,
              );
              final updatedList = List<Project>.from(resume.projects);
              final index = updatedList.indexWhere(
                (p) => p.id == updatedProject.id,
              );
              if (index >= 0) {
                updatedList[index] = updatedProject;
              } else {
                updatedList.add(updatedProject);
              }
              ref
                  .read(resumeEditorProvider(resumeId).notifier)
                  .updateResumeLocally(resume.copyWith(projects: updatedList));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    WidgetRef ref,
    Resume resume,
    ThemeData theme,
  ) {
    final summaryController = TextEditingController(text: resume.title);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_rounded,
                color: AppColors.blue400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Resume Title',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Edit Resume Title'),
                      content: TextField(
                        controller: summaryController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(resumeEditorProvider(resumeId).notifier)
                                .updateResumeLocally(
                                  resume.copyWith(
                                    title: summaryController.text,
                                  ),
                                );
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(resume.title, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  IconData _getTemplateIcon(String templateId) {
    switch (templateId) {
      case 'classic':
        return Icons.description_rounded;
      case 'modern':
        return Icons.view_column_rounded;
      case 'minimal':
        return Icons.minimize_rounded;
      case 'executive':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}
