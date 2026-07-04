import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/services/i_ai_content_generator.dart';

/// Improves the wording of a resume section using AI.
class ImproveResumeSectionUseCase {
  final IAIContentGenerator _aiContentGenerator;

  const ImproveResumeSectionUseCase(this._aiContentGenerator);

  Future<Either<Failure, String>> call({required String text}) {
    return _aiContentGenerator.improveSection(text);
  }
}
