import 'package:flutter/material.dart';

import '../../../../../core/utils/validators.dart';
import '../../../../../domain/entities/work_experience.dart';
import '../../../../../presentation/widgets/subscription_navigation.dart';

class WorkExperienceForm extends StatefulWidget {
  final WorkExperience? initialData;
  final ValueChanged<WorkExperience> onSave;
  final Future<String?> Function(String)? onAiImprove;

  const WorkExperienceForm({
    super.key,
    this.initialData,
    required this.onSave,
    this.onAiImprove,
  });

  @override
  State<WorkExperienceForm> createState() => _WorkExperienceFormState();
}

class _WorkExperienceFormState extends State<WorkExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _descriptionCtrl;
  late bool _isCurrent;

  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _companyCtrl = TextEditingController(
      text: widget.initialData?.company ?? '',
    );
    _roleCtrl = TextEditingController(text: widget.initialData?.role ?? '');
    _descriptionCtrl = TextEditingController(
      text: widget.initialData?.description ?? '',
    );
    _isCurrent = widget.initialData?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updated = WorkExperience(
        id: widget.initialData?.id ?? DateTime.now().toIso8601String(),
        resumeId: widget.initialData?.resumeId ?? '',
        company: _companyCtrl.text,
        role: _roleCtrl.text,
        startDate:
            widget.initialData?.startDate ??
            DateTime.now(), // Real app would use a date picker
        endDate: _isCurrent
            ? null
            : (widget.initialData?.endDate ?? DateTime.now()),
        isCurrent: _isCurrent,
        description: _descriptionCtrl.text,
        orderIndex: widget.initialData?.orderIndex ?? 0,
      );
      widget.onSave(updated);
      Navigator.pop(context);
    }
  }

  Future<void> _handleAiImprove() async {
    if (widget.onAiImprove == null) return;

    setState(() => _isAiLoading = true);
    final improvedText = await widget.onAiImprove!(_descriptionCtrl.text);
    setState(() => _isAiLoading = false);

    if (improvedText == null && mounted) {
      // AI improvement failed, likely due to insufficient credits
      showUpgradeRequiredDialog(
        context,
        message:
            'You need more AI credits to improve this section. Please upgrade your plan.',
      );
    } else if (improvedText != null && mounted) {
      _descriptionCtrl.text = improvedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initialData == null
                    ? 'Add Work Experience'
                    : 'Edit Work Experience',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _companyCtrl,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: (val) => Validators.required(val, 'Company'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (val) => Validators.required(val, 'Role'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I currently work here'),
                value: _isCurrent,
                onChanged: (val) => setState(() => _isCurrent = val ?? false),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Description (Achievements)'),
                  if (widget.onAiImprove != null)
                    TextButton.icon(
                      onPressed: _isAiLoading ? null : _handleAiImprove,
                      icon: _isAiLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text('AI Improve'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe your key achievements...',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Experience'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
