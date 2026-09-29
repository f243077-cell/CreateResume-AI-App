import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Editable professional summary with a character count and "AI Improve".
///
/// Owns its [TextEditingController]; edits are reported through [onChanged].
class SummaryEditorCard extends StatefulWidget {
  final String summary;
  final ValueChanged<String> onChanged;
  final Future<String?> Function(String)? onAiImprove;

  const SummaryEditorCard({
    super.key,
    required this.summary,
    required this.onChanged,
    this.onAiImprove,
  });

  @override
  State<SummaryEditorCard> createState() => _SummaryEditorCardState();
}

class _SummaryEditorCardState extends State<SummaryEditorCard> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.summary);
  }

  @override
  void didUpdateWidget(SummaryEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pick up outside changes (e.g. a reload) without fighting the user's typing.
    if (!_focusNode.hasFocus && widget.summary != _controller.text) {
      _controller.text = widget.summary;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAiImprove() async {
    final text = _controller.text.trim();
    if (widget.onAiImprove == null || text.isEmpty) return;

    setState(() => _isAiLoading = true);
    final improved = await widget.onAiImprove!(text);
    if (!mounted) return;
    setState(() => _isAiLoading = false);

    if (improved == null || improved.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not improve the summary. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    _controller.text = improved.trim();
    widget.onChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              const Icon(Icons.notes_rounded, color: AppColors.blue400, size: 20),
              const SizedBox(width: 12),
              // Flexible so the AI button still fits on narrow phones.
              Expanded(
                child: Text(
                  'Professional Summary',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
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
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'A few sentences on your experience and strengths...',
            ),
            onChanged: (value) {
              setState(() {}); // refresh the character count
              widget.onChanged(value);
            },
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_controller.text.length} characters',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
