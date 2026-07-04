import 'package:equatable/equatable.dart';

/// Subscription tier for a user account.
enum SubscriptionStatus { free, premium }

/// Represents an authenticated user in the system.
///
/// Immutable entity with [copyWith] for state transitions.
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? photoUrl;
  final SubscriptionStatus subscriptionStatus;
  final int creditBalance;
  final String? aiWritingStyle;
  final String? themePreference;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.creditBalance = 0,
    this.aiWritingStyle,
    this.themePreference,
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? photoUrl,
    SubscriptionStatus? subscriptionStatus,
    int? creditBalance,
    String? aiWritingStyle,
    String? themePreference,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      creditBalance: creditBalance ?? this.creditBalance,
      aiWritingStyle: aiWritingStyle ?? this.aiWritingStyle,
      themePreference: themePreference ?? this.themePreference,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        photoUrl,
        subscriptionStatus,
        creditBalance,
        aiWritingStyle,
        themePreference,
      ];
}
