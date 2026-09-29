// File: lib/presentation/modules/resume_editor/providers/resume_editor_notifier.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:printing/printing.dart';
import '../../../../application/providers/auth_state_provider.dart';
import '../../../../core/constants/template_ids.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/resume.dart';
import '../../../../infrastructure/services/local_pdf_generator_service.dart';

class ResumeEditorNotifier extends StateNotifier<AsyncValue<Resume>> {
  final Ref _ref;
  final String _resumeId;
  Timer? _debounceTimer;

  ResumeEditorNotifier(this._ref, this._resumeId)
    : super(const AsyncValue.loading()) {
    _loadResume();
  }

  Future<void> _loadResume() async {
    state = const AsyncValue.loading();
    try {
      final getResume = _ref.read(getResumeByIdUseCaseProvider);
      final result = await getResume(resumeId: _resumeId);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (resume) => state = AsyncValue.data(resume),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateResumeLocally(Resume updatedResume) {
    state = AsyncValue.data(updatedResume);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => saveToCloud(),
    );
  }

  /// Saves the current resume. Returns false when the save failed.
  Future<bool> saveToCloud() async {
    final currentResume = state.value;
    if (currentResume == null) return false;
    try {
      final updateResume = _ref.read(updateResumeUseCaseProvider);
      final result = await updateResume(resume: currentResume);
      return result.isRight();
    } catch (e) {
      return false;
    }
  }

  Future<String?> aiImproveText(String originalText) async {
    try {
      final improveSection = _ref.read(improveResumeSectionUseCaseProvider);
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
    final authUser = _ref.read(authStateProvider).value;
    if (authUser == null) return 'Please sign in again to export.';
    try {
      // The auth snapshot has no contact fields; use the full profile so
      // phone, location and links reach the PDF.
      final getProfile = _ref.read(getUserProfileUseCaseProvider);
      final profileResult = await getProfile(userId: authUser.id);
      final user = profileResult.fold((_) => authUser, (profile) => profile);

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

  void retry() => _loadResume();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final resumeEditorProvider = StateNotifierProvider.autoDispose
    .family<ResumeEditorNotifier, AsyncValue<Resume>, String>(
      (ref, resumeId) => ResumeEditorNotifier(ref, resumeId),
    );
