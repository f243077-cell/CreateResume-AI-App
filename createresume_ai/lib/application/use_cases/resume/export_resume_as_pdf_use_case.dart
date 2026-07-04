import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/services/i_pdf_generator_service.dart';

/// Exports a resume as a PDF document.
class ExportResumeAsPdfUseCase {
  final IPDFGeneratorService _pdfGeneratorService;

  const ExportResumeAsPdfUseCase(this._pdfGeneratorService);

  /// Generates a PDF from [resume] and returns the file URL or a [Failure].
  Future<Either<Failure, String>> call(Resume resume) {
    return _pdfGeneratorService.generatePdf(resume);
  }
}
