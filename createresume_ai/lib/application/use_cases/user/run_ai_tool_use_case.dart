import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';

/// Runs an AI tool, deducting one credit and returning generated text.
class RunAiToolUseCase {
  final IUserProfileRepository _userProfileRepository;

  const RunAiToolUseCase(this._userProfileRepository);

  Future<Either<Failure, ({User profile, String resultText})>> call({
    required String userId,
    required String toolName,
    required String input,
  }) async {
    final profileResult = await _userProfileRepository.getProfile(userId);

    return profileResult.fold(
      Left.new,
      (user) async {
        if (user.creditBalance <= 0) {
          return Left(InsufficientCreditsFailure(
            requested: 1,
            available: user.creditBalance,
          ));
        }

        final deductResult = await _userProfileRepository.deductCredits(
          userId: userId,
          amount: 1,
        );

        return deductResult.fold(
          Left.new,
          (updatedProfile) => Right((
            profile: updatedProfile,
            resultText: _mockResult(toolName),
          )),
        );
      },
    );
  }

  String _mockResult(String toolName) {
    switch (toolName) {
      case 'Bullet Rewriter':
        return 'Optimized bullet point: Successfully led a cross-functional team of 10 to deliver a 25% increase in core metrics.';
      case 'Skill Gap Analyzer':
        return 'Based on your input, you should consider learning React, Node.js, and CI/CD pipelines.';
      default:
        return 'Dear Hiring Manager,\n\nI am thrilled to apply for the position... [Cover Letter generated]';
    }
  }
}
