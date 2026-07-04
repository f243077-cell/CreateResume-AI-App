import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/resume.dart';

/// PDF generation service contract.
abstract class IPDFGeneratorService {
  /// Generates a PDF from a [Resume] entity and returns the file URL.
  Future<Either<Failure, String>> generatePdf(Resume resume);
}
