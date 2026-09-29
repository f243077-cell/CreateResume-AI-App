import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/user.dart';

/// Contact details shown on exported resumes.
class ContactDetails {
  final String jobTitle;
  final String phone;
  final String location;
  final String linkedin;
  final String github;
  final String leetcode;

  const ContactDetails({
    required this.jobTitle,
    required this.phone,
    required this.location,
    required this.linkedin,
    required this.github,
    required this.leetcode,
  });
}

/// Edits job title, phone, location and profile links.
/// Pops a [ContactDetails] on save, or null when cancelled.
class ContactDetailsDialog extends StatefulWidget {
  final User? profile;

  const ContactDetailsDialog({super.key, required this.profile});

  @override
  State<ContactDetailsDialog> createState() => _ContactDetailsDialogState();
}

class _ContactDetailsDialogState extends State<ContactDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _jobTitleController =
      TextEditingController(text: widget.profile?.jobTitle ?? '');
  late final _phoneController =
      TextEditingController(text: widget.profile?.phone ?? '');
  late final _locationController =
      TextEditingController(text: widget.profile?.location ?? '');
  late final _linkedinController =
      TextEditingController(text: widget.profile?.linkedin ?? '');
  late final _githubController =
      TextEditingController(text: widget.profile?.github ?? '');
  late final _leetcodeController =
      TextEditingController(text: widget.profile?.leetcode ?? '');

  @override
  void dispose() {
    _jobTitleController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _leetcodeController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ContactDetails(
        jobTitle: _jobTitleController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        linkedin: _linkedinController.text.trim(),
        github: _githubController.text.trim(),
        leetcode: _leetcodeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Contact Details'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: Validators.optionalPhone,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn URL'),
                keyboardType: TextInputType.url,
                validator: Validators.optionalUrl,
              ),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(labelText: 'GitHub URL'),
                keyboardType: TextInputType.url,
                validator: Validators.optionalUrl,
              ),
              TextFormField(
                controller: _leetcodeController,
                decoration: const InputDecoration(labelText: 'LeetCode URL'),
                keyboardType: TextInputType.url,
                validator: Validators.optionalUrl,
              ),
            ],
          ),
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
