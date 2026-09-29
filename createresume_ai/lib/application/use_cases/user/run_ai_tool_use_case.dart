import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';
import '../../../domain/services/i_ai_content_generator.dart';

/// Input for one AI Tool Library tool.
sealed class AiToolRequest {
  const AiToolRequest();
}

/// Bullet Rewriter: one resume bullet.
final class BulletRewriteRequest extends AiToolRequest {
  final String bullet;
  const BulletRewriteRequest(this.bullet);
}

/// Skill Gap Analyzer: the user's skills against a job posting.
final class SkillGapRequest extends AiToolRequest {
  final String skills;
  final String jobDescription;
  const SkillGapRequest({required this.skills, required this.jobDescription});
}

/// Cover Letter: company, job title and the candidate's background.
final class CoverLetterRequest extends AiToolRequest {
  final String companyName;
  final String jobTitle;
  final String background;
  const CoverLetterRequest({
    required this.companyName,
    required this.jobTitle,
    required this.background,
  });
}

/// Runs an AI tool and charges [creditCost] credit only after the AI
/// returned a result, so a failed call costs nothing.
class RunAiToolUseCase {
  static const creditCost = 1;

  final IUserProfileRepository _userProfileRepository;
  final IAIContentGenerator _aiContentGenerator;

  const RunAiToolUseCase(this._userProfileRepository, this._aiContentGenerator);

  Future<Either<Failure, ({User profile, String resultText})>> call({
    required String userId,
    required AiToolRequest request,
  }) async {
    final profileResult = await _userProfileRepository.getProfile(userId);

    return profileResult.fold(
      Left.new,
      (user) async {
        if (user.creditBalance < creditCost) {
          return Left(InsufficientCreditsFailure(
            requested: creditCost,
            available: user.creditBalance,
          ));
        }

        final aiResult = await _generate(request);

        return aiResult.fold(Left.new, (resultText) async {
          final deductResult = await _userProfileRepository.deductCredits(
            userId: userId,
            amount: creditCost,
          );
          return deductResult.fold(
            Left.new,
            (updatedProfile) => Right((
              profile: updatedProfile,
              resultText: resultText,
            )),
          );
        });
      },
    );
  }

  Future<Either<Failure, String>> _generate(AiToolRequest request) {
    return switch (request) {
      BulletRewriteRequest(:final bullet) =>
        _aiContentGenerator.rewriteBullet(bullet),
      SkillGapRequest(:final skills, :final jobDescription) =>
        _aiContentGenerator.analyzeSkillGap(
          skills: skills,
          jobDescription: jobDescription,
        ),
      CoverLetterRequest(:final companyName, :final jobTitle, :final background) =>
        _aiContentGenerator.generateCoverLetter(
          resumeSummary: background,
          companyName: companyName,
          jobTitle: jobTitle,
        ),
    };
  }
}
