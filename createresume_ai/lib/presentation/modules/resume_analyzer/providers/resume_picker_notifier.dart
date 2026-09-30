import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/resume_list_provider.dart';
import '../../../../domain/entities/resume.dart';

class ResumePickerNotifier extends AsyncNotifier<List<Resume>> {
  @override
  Future<List<Resume>> build() async {
    return ref.watch(resumeListProvider.future);
  }
}

final resumePickerProvider =
    AsyncNotifierProvider<ResumePickerNotifier, List<Resume>>(
  ResumePickerNotifier.new,
);
