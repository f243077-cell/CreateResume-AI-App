// File: lib/presentation/modules/resume_editor/providers/resume_editor_notifier.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../../application/providers/current_profile_provider.dart';
import '../../../../core/constants/template_ids.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/resume.dart';
import '../../../../infrastructure/services/local_pdf_generator_service.dart';

/// Autosave state shown in the editor's app bar.
enum SaveStatus { idle, saving, saved, error }

class EditorSaveStatusNotifier extends Notifier<SaveStatus> {
  EditorSaveStatusNotifier(this.resumeId);

  final String resumeId;

  @override
  SaveStatus build() => SaveStatus.idle;

  void set(SaveStatus value) => state = value;
}

/// Save status per resume ID.
final editorSaveStatusProvider = NotifierProvider.autoDispose
    .family<EditorSaveStatusNotifier, SaveStatus, String>(EditorSaveStatusNotifier.new);

/// Loads one resume for editing and autosaves changes.
///
/// Edits are saved [saveDebounce] after the last change, immediately on
/// [flush] (leaving the screen, app pause) and, as a last resort, when the
/// provider is disposed with unsaved edits. Failures are reported through
/// [editorSaveStatusProvider], never swallowed.
class ResumeEditorNotifier extends AsyncNotifier<Resume> {
  ResumeEditorNotifier(this.resumeId);

  final String resumeId;

  static const saveDebounce = Duration(milliseconds: 1500);

  Timer? _debounceTimer;

  /// Latest local version not yet saved successfully.
  Resume? _unsaved;

  @override
  Future<Resume> build() async {
    final updateResume = ref.read(updateResumeUseCaseProvider);
    ref.onDispose(() {
      _debounceTimer?.cancel();
      // Leaving within the debounce window must not lose the last edit.
      final pending = _unsaved;
      if (pending != null) unawaited(updateResume(resume: pending));
    });

    // Keep the shared profile active for PDF export without rebuilding the
    // editor (and losing unsaved edits) when the profile changes.
    ref.listen(currentProfileProvider, (_, _) {});

    final getResume = ref.read(getResumeByIdUseCaseProvider);
    final result = await getResume(resumeId: resumeId);
    return result.fold((failure) => throw failure, (resume) => resume);
  }

  void _setStatus(SaveStatus status) {
    if (!ref.mounted) return;
    ref.read(editorSaveStatusProvider(resumeId).notifier).set(status);
  }

  void updateResumeLocally(Resume updatedResume) {
    state = AsyncValue.data(updatedResume);
    _unsaved = updatedResume;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(saveDebounce, () => saveToCloud());
  }

  /// Saves right away if there are unsaved edits. Returns false if a save
  /// was needed and failed.
  Future<bool> flush() async {
    if (_unsaved == null) return true;
    return saveToCloud();
  }

  /// Saves the current resume. Returns false when the save failed.
  Future<bool> saveToCloud() async {
    _debounceTimer?.cancel();
    final currentResume = state.value;
    if (currentResume == null) return false;

    _setStatus(SaveStatus.saving);
    try {
      final updateResume = ref.read(updateResumeUseCaseProvider);
      final result = await updateResume(resume: currentResume);
      final saved = result.isRight();
      // Edits made while saving stay unsaved and get their own save.
      if (saved && identical(_unsaved, currentResume)) _unsaved = null;
      _setStatus(saved ? SaveStatus.saved : SaveStatus.error);
      return saved;
    } catch (e) {
      _setStatus(SaveStatus.error);
      return false;
    }
  }

  Future<String?> aiImproveText(String originalText) async {
    try {
      final improveSection = ref.read(improveResumeSectionUseCaseProvider);
      final result = await improveSection(text: originalText);
      return result.fold((failure) => null, (r) => r);
    } catch (e) {
      return null;
    }
  }

  /// Builds the PDF and opens the platform share sheet.
  /// Returns an error message to show, or null on success.
  Future<String?> exportPdf() async {
    final currentResume = state.value;
    if (currentResume == null) return 'The resume has not loaded yet.';
    try {
      // The full shared profile (not the auth snapshot) so phone, location
      // and links reach the PDF.
      final user = await ref.read(currentProfileProvider.future);
      if (user == null) return 'Please sign in again to export.';

      final pdfService = LocalPdfGeneratorService();
      final pdfBytes = await pdfService.generatePdf(
        resume: currentResume,
        user: user,
        templateId: TemplateIds.normalize(currentResume.templateId),
      );
      await Printing.sharePdf(
        bytes: Uint8List.fromList(pdfBytes),
        filename: pdfFileName(currentResume.title),
      );
      return null;
    } catch (e) {
      return 'Could not export the PDF. Please try again.';
    }
  }

  /// A file-system-safe PDF file name derived from the resume [title].
  static String pdfFileName(String title) {
    var name = title
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // Drop leading/trailing dots and underscores left by replacements.
    name = name.replaceAll(RegExp(r'^[._ ]+|[._ ]+$'), '');
    if (name.isEmpty) name = 'resume';
    if (name.length > 80) name = name.substring(0, 80).trim();
    return '$name.pdf';
  }

  void changeTemplate(String templateId) {
    final currentResume = state.value;
    if (currentResume == null) return;
    updateResumeLocally(currentResume.copyWith(templateId: templateId));
  }

  void retry() => ref.invalidateSelf();
}

final resumeEditorProvider = AsyncNotifierProvider.autoDispose
    .family<ResumeEditorNotifier, Resume, String>(ResumeEditorNotifier.new);
