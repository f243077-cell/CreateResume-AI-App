import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/education.dart';
import '../../../../../domain/entities/project.dart';
import '../../../../../domain/entities/skill.dart';

// Editor dialogs. Each one owns and disposes its controllers and returns the
// edited value with Navigator.pop (null when cancelled).

/// Edits the resume title. Pops the new title.
class ResumeTitleDialog extends StatefulWidget {
  final String initialTitle;

  const ResumeTitleDialog({super.key, required this.initialTitle});

  @override
  State<ResumeTitleDialog> createState() => _ResumeTitleDialogState();
}

class _ResumeTitleDialogState extends State<ResumeTitleDialog> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.initialTitle);

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Resume Title'),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _titleController.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Adds or edits an education entry. Pops the [Education].
class EducationFormDialog extends StatefulWidget {
  final String resumeId;
  final Education? initialData;
  final int newOrderIndex;

  const EducationFormDialog({
    super.key,
    required this.resumeId,
    required this.newOrderIndex,
    this.initialData,
  });

  @override
  State<EducationFormDialog> createState() => _EducationFormDialogState();
}

class _EducationFormDialogState extends State<EducationFormDialog> {
  late final _degreeController =
      TextEditingController(text: widget.initialData?.degree ?? '');
  late final _institutionController =
      TextEditingController(text: widget.initialData?.institution ?? '');
  late final _fieldController =
      TextEditingController(text: widget.initialData?.field ?? '');
  late final _gpaController =
      TextEditingController(text: widget.initialData?.gpa?.toString() ?? '');

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _fieldController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  void _save() {
    final initialData = widget.initialData;
    Navigator.pop(
      context,
      Education(
        id: initialData?.id ?? const Uuid().v4(),
        resumeId: widget.resumeId,
        degree: _degreeController.text,
        institution: _institutionController.text,
        field: _fieldController.text,
        startDate: initialData?.startDate ?? DateTime.now(),
        endDate: initialData?.endDate,
        gpa: double.tryParse(_gpaController.text),
        orderIndex: initialData?.orderIndex ?? widget.newOrderIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Add Education' : 'Edit Education'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _degreeController,
              decoration: const InputDecoration(labelText: 'Degree'),
            ),
            TextField(
              controller: _institutionController,
              decoration: const InputDecoration(labelText: 'Institution'),
            ),
            TextField(
              controller: _fieldController,
              decoration: const InputDecoration(labelText: 'Field of Study'),
            ),
            TextField(
              controller: _gpaController,
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
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// Adds or edits a skill. Pops the [Skill].
class SkillFormDialog extends StatefulWidget {
  final String resumeId;
  final Skill? initialData;
  final int newOrderIndex;

  const SkillFormDialog({
    super.key,
    required this.resumeId,
    required this.newOrderIndex,
    this.initialData,
  });

  @override
  State<SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<SkillFormDialog> {
  late final _nameController =
      TextEditingController(text: widget.initialData?.name ?? '');
  late final _levelController =
      TextEditingController(text: widget.initialData?.level ?? 'intermediate');
  late final _categoryController =
      TextEditingController(text: widget.initialData?.category ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _save() {
    final initialData = widget.initialData;
    final category = _categoryController.text.trim();
    Navigator.pop(
      context,
      Skill(
        id: initialData?.id ?? const Uuid().v4(),
        resumeId: widget.resumeId,
        name: _nameController.text,
        level: _levelController.text,
        // Keep the category so PDF skill grouping survives an edit.
        category: category.isEmpty ? null : category,
        orderIndex: initialData?.orderIndex ?? widget.newOrderIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Add Skill' : 'Edit Skill'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Skill Name'),
          ),
          TextField(
            controller: _levelController,
            decoration: const InputDecoration(labelText: 'Level (beginner/intermediate/expert)'),
          ),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category (optional, e.g. Languages)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// Adds or edits a project. Pops the [Project].
class ProjectFormDialog extends StatefulWidget {
  final String resumeId;
  final Project? initialData;
  final int newOrderIndex;

  const ProjectFormDialog({
    super.key,
    required this.resumeId,
    required this.newOrderIndex,
    this.initialData,
  });

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  late final _nameController =
      TextEditingController(text: widget.initialData?.name ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.initialData?.description ?? '');
  late final _urlController =
      TextEditingController(text: widget.initialData?.url ?? '');
  late final _techStackController =
      TextEditingController(text: widget.initialData?.techStack.join(', ') ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _techStackController.dispose();
    super.dispose();
  }

  void _save() {
    final initialData = widget.initialData;
    Navigator.pop(
      context,
      Project(
        id: initialData?.id ?? const Uuid().v4(),
        resumeId: widget.resumeId,
        name: _nameController.text,
        description: _descriptionController.text,
        techStack: _techStackController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        url: _urlController.text.isEmpty ? null : _urlController.text,
        orderIndex: initialData?.orderIndex ?? widget.newOrderIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Add Project' : 'Edit Project'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: _techStackController,
              decoration: const InputDecoration(labelText: 'Tech Stack (comma-separated)'),
            ),
            TextField(
              controller: _urlController,
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
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
