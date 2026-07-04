// File: lib/presentation/modules/resume_editor/providers/resume_editor_notifier.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../application/providers/auth_state_provider.dart';
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

  Future<void> saveToCloud() async {
    final currentResume = state.value;
    if (currentResume == null) return;
    try {
      final updateResume = _ref.read(updateResumeUseCaseProvider);
      await updateResume(resume: currentResume);
    } catch (e) {
      // silent fail — data already saved locally
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

  Future<void> exportPdf() async {
    final currentResume = state.value;
    if (currentResume == null) return;
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;
    try {
      final pdfService = LocalPdfGeneratorService();
      final pdfBytes = await pdfService.generatePdf(
        resume: currentResume,
        user: user,
        templateId: currentResume.templateId ?? 'modern',
      );
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${currentResume.title}.pdf');
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(file.path);
    } catch (e) {
      // handle export error
    }
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
