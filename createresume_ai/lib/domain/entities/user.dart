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

  // Contact / profile fields used for resume rendering
  final String? phone;
  final String? location;
  final String? jobTitle;
  final String? linkedin;
  final String? github;
  final String? leetcode;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.creditBalance = 0,
    this.aiWritingStyle,
    this.themePreference,
    this.phone,
    this.location,
    this.jobTitle,
    this.linkedin,
    this.github,
    this.leetcode,
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
    String? phone,
    String? location,
    String? jobTitle,
    String? linkedin,
    String? github,
    String? leetcode,
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
      phone: phone ?? this.phone,
      location: location ?? this.location,
      jobTitle: jobTitle ?? this.jobTitle,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      leetcode: leetcode ?? this.leetcode,
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
    phone,
    location,
    jobTitle,
    linkedin,
    github,
    leetcode,
  ];
}
