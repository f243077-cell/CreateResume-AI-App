import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/template_ids.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/education.dart';
import '../../../../domain/entities/project.dart';
import '../../../../domain/entities/resume.dart';
import '../../../../domain/entities/skill.dart';
import '../../../../domain/entities/work_experience.dart';
import '../../../../infrastructure/services/local_pdf_generator_service.dart';
import '../providers/resume_editor_notifier.dart';
import '../widgets/editor_section.dart';
import '../widgets/forms/editor_dialogs.dart';
import '../widgets/forms/work_experience_form.dart';
import '../widgets/summary_editor_card.dart';

class ResumeEditorScreen extends ConsumerStatefulWidget {
  final String resumeId;
  final String? initialTemplateId;

  const ResumeEditorScreen({
    super.key,
    required this.resumeId,
    this.initialTemplateId,
  });

  @override
  ConsumerState<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends ConsumerState<ResumeEditorScreen> {
  bool _hasAppliedInitialTemplate = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editorState = ref.watch(resumeEditorProvider(widget.resumeId));

    // Apply the template chosen on the Template Selection screen exactly
    // once, right after the resume finishes loading — this is what the
    // navigation query parameter was for, but was previously never read.
    ref.listen(resumeEditorProvider(widget.resumeId), (previous, next) {
      if (_hasAppliedInitialTemplate || widget.initialTemplateId == null) return;
      final incomingTemplateId = TemplateIds.normalize(widget.initialTemplateId);

      next.whenData((resume) {
        if (resume.templateId != incomingTemplateId) {
          _hasAppliedInitialTemplate = true;
          ref
              .read(resumeEditorProvider(widget.resumeId).notifier)
              .changeTemplate(incomingTemplateId);
        } else {
          _hasAppliedInitialTemplate = true;
        }
      });
    });

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
              ref.read(resumeEditorProvider(widget.resumeId).notifier).saveToCloud();
              context.pop();
            },
          ),
        ),
        title: const Text(
          'CreateResume AI',
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
                ref.read(resumeEditorProvider(widget.resumeId).notifier).changeTemplate(templateId);
              },
              itemBuilder: (context) => LocalPdfGeneratorService.availableTemplates
                  .map((template) => PopupMenuItem(
                        value: template['id'],
                        child: Row(
                          children: [
                            Icon(
                              _getTemplateIcon(template['id']!),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(template['name']!),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Export resume as PDF',
            child: OutlinedButton(
              onPressed: () async {
                final error = await ref
                    .read(resumeEditorProvider(widget.resumeId).notifier)
                    .exportPdf();
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: AppColors.error),
                  );
                }
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
              onPressed: () async {
                final saved = await ref
                    .read(resumeEditorProvider(widget.resumeId).notifier)
                    .saveToCloud();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  saved
                      ? const SnackBar(content: Text('Saved to Cloud'))
                      : const SnackBar(
                          content: Text('Could not save. Check your connection and try again.'),
                          backgroundColor: AppColors.error,
                        ),
                );
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

                  // Resume title
                  _buildTitleSection(context, ref, resume, theme),

                  const SizedBox(height: 16),

                  // Professional Summary section
                  SummaryEditorCard(
                    summary: resume.summary ?? '',
                    onAiImprove: (text) => ref
                        .read(resumeEditorProvider(widget.resumeId).notifier)
                        .aiImproveText(text),
                    onChanged: (text) => ref
                        .read(resumeEditorProvider(widget.resumeId).notifier)
                        .updateResumeLocally(_current(resume).copyWith(summary: text)),
                  ),

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
                            .read(resumeEditorProvider(widget.resumeId).notifier)
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
                                icon: const Icon(Icons.delete_rounded, size: 20),
                                onPressed: () {
                                  final updatedList = List<WorkExperience>.from(
                                    resume.workExperiences,
                                  );
                                  updatedList.removeWhere((e) => e.id == exp.id);
                                  ref
                                      .read(resumeEditorProvider(widget.resumeId).notifier)
                                      .updateResumeLocally(
                                        resume.copyWith(workExperiences: updatedList),
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
                            .read(resumeEditorProvider(widget.resumeId).notifier)
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
                                icon: const Icon(Icons.delete_rounded, size: 20),
                                onPressed: () {
                                  final updatedList = List<Education>.from(
                                    resume.educations,
                                  );
                                  updatedList.removeWhere((e) => e.id == edu.id);
                                  ref
                                      .read(resumeEditorProvider(widget.resumeId).notifier)
                                      .updateResumeLocally(
                                        resume.copyWith(educations: updatedList),
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
                            .read(resumeEditorProvider(widget.resumeId).notifier)
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
                          subtitle: skill.level != null ? Text(skill.level!) : null,
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
                                icon: const Icon(Icons.delete_rounded, size: 20),
                                onPressed: () {
                                  final updatedList = List<Skill>.from(
                                    resume.skills,
                                  );
                                  updatedList.removeWhere((s) => s.id == skill.id);
                                  ref
                                      .read(resumeEditorProvider(widget.resumeId).notifier)
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
                            .read(resumeEditorProvider(widget.resumeId).notifier)
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
                                icon: const Icon(Icons.delete_rounded, size: 20),
                                onPressed: () {
                                  final updatedList = List<Project>.from(
                                    resume.projects,
                                  );
                                  updatedList.removeWhere((p) => p.id == proj.id);
                                  ref
                                      .read(resumeEditorProvider(widget.resumeId).notifier)
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
                  onPressed: () => ref.invalidate(resumeEditorProvider(widget.resumeId)),
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
              .read(resumeEditorProvider(widget.resumeId).notifier)
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
                .read(resumeEditorProvider(widget.resumeId).notifier)
                .updateResumeLocally(
                  resume.copyWith(workExperiences: updatedList),
                );
          },
        );
      },
    );
  }

  /// The latest resume in the editor, falling back to [resume].
  Resume _current(Resume resume) =>
      ref.read(resumeEditorProvider(widget.resumeId)).value ?? resume;

  Future<void> _showEducationForm(
    BuildContext context,
    WidgetRef ref,
    Resume resume, {
    Education? initialData,
  }) async {
    final updatedEdu = await showDialog<Education>(
      context: context,
      builder: (context) => EducationFormDialog(
        resumeId: resume.id,
        initialData: initialData,
        newOrderIndex: resume.educations.length,
      ),
    );
    if (updatedEdu == null || !mounted) return;
    final current = _current(resume);
    final updatedList = List<Education>.from(current.educations);
    final index = updatedList.indexWhere((e) => e.id == updatedEdu.id);
    if (index >= 0) {
      updatedList[index] = updatedEdu;
    } else {
      updatedList.add(updatedEdu);
    }
    ref
        .read(resumeEditorProvider(widget.resumeId).notifier)
        .updateResumeLocally(current.copyWith(educations: updatedList));
  }

  Future<void> _showSkillForm(
    BuildContext context,
    WidgetRef ref,
    Resume resume, {
    Skill? initialData,
  }) async {
    final updatedSkill = await showDialog<Skill>(
      context: context,
      builder: (context) => SkillFormDialog(
        resumeId: resume.id,
        initialData: initialData,
        newOrderIndex: resume.skills.length,
      ),
    );
    if (updatedSkill == null || !mounted) return;
    final current = _current(resume);
    final updatedList = List<Skill>.from(current.skills);
    final index = updatedList.indexWhere((s) => s.id == updatedSkill.id);
    if (index >= 0) {
      updatedList[index] = updatedSkill;
    } else {
      updatedList.add(updatedSkill);
    }
    ref
        .read(resumeEditorProvider(widget.resumeId).notifier)
        .updateResumeLocally(current.copyWith(skills: updatedList));
  }

  Future<void> _showProjectForm(
    BuildContext context,
    WidgetRef ref,
    Resume resume, {
    Project? initialData,
  }) async {
    final updatedProject = await showDialog<Project>(
      context: context,
      builder: (context) => ProjectFormDialog(
        resumeId: resume.id,
        initialData: initialData,
        newOrderIndex: resume.projects.length,
      ),
    );
    if (updatedProject == null || !mounted) return;
    final current = _current(resume);
    final updatedList = List<Project>.from(current.projects);
    final index = updatedList.indexWhere((p) => p.id == updatedProject.id);
    if (index >= 0) {
      updatedList[index] = updatedProject;
    } else {
      updatedList.add(updatedProject);
    }
    ref
        .read(resumeEditorProvider(widget.resumeId).notifier)
        .updateResumeLocally(current.copyWith(projects: updatedList));
  }

  Widget _buildTitleSection(
    BuildContext context,
    WidgetRef ref,
    Resume resume,
    ThemeData theme,
  ) {
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
              const Icon(Icons.description_rounded, color: AppColors.blue400, size: 20),
              const SizedBox(width: 12),
              Text(
                'Resume Title',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: () async {
                  final title = await showDialog<String>(
                    context: context,
                    builder: (context) =>
                        ResumeTitleDialog(initialTitle: resume.title),
                  );
                  if (title == null || !mounted) return;
                  ref
                      .read(resumeEditorProvider(widget.resumeId).notifier)
                      .updateResumeLocally(_current(resume).copyWith(title: title));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            resume.title,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  IconData _getTemplateIcon(String templateId) {
    switch (TemplateIds.normalize(templateId)) {
      case TemplateIds.classic:
        return Icons.description_rounded;
      case TemplateIds.modern:
        return Icons.view_column_rounded;
      case TemplateIds.minimal:
        return Icons.minimize_rounded;
      case TemplateIds.executive:
        return Icons.workspace_premium_rounded;
      case TemplateIds.executive2:
        return Icons.diamond_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}