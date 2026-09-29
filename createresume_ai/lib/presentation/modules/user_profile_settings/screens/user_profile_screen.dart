import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/widgets/subscription_navigation.dart';
import '../providers/user_profile_notifier.dart';
import '../widgets/contact_details_dialog.dart';

/// Same deep warm background used on Home Dashboard and All Resumes,
/// for visual consistency across the main tabs.
const Color _screenBg = Color(0xFF3D2418);

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  dynamic _cachedProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(userProfileProvider.select((s) => s.isLoading));
    final profile = ref.watch(userProfileProvider.select((s) => s.profile));
    if (profile != null) {
      _cachedProfile = profile;
    }
    final displayProfile = profile ?? _cachedProfile;
    final selectedStyle = displayProfile?.aiWritingStyle ?? 'Professional';

    ref.listen<UserProfileState>(userProfileProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        foregroundColor: Colors.white,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading && displayProfile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.burntOrange),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.burntOrange,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.burntOrange.withValues(
                              alpha: 0.2,
                            ),
                            backgroundImage: displayProfile?.photoUrl != null
                                ? _cachedProfileImage(
                                    context,
                                    displayProfile!.photoUrl!,
                                  )
                                : null,
                            child: displayProfile?.photoUrl == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 50,
                                    color: AppColors.burntOrange,
                                  )
                                : null,
                          ),
                        ),
                        if (isLoading && displayProfile != null)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Semantics(
                            button: true,
                            label: 'Update profile photo',
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(userProfileProvider.notifier)
                                    .updateProfilePhoto();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.burntOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayProfile?.fullName ?? 'User Name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayProfile?.email ?? 'email@example.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Subscription Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.vanilla,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.burntOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Free Plan',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${displayProfile?.creditBalance ?? 0} AI Credits',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Upgrade subscription plan',
                          child: OutlinedButton(
                            onPressed: () => navigateToSubscription(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              minimumSize: const Size(0, 36),
                              foregroundColor: AppColors.burntOrangeDark,
                              side: const BorderSide(
                                color: AppColors.burntOrange,
                              ),
                            ),
                            child: const Text('Upgrade'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Edit Profile
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Semantics(
                      button: true,
                      label: 'Edit name and email',
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: const Icon(Icons.edit_rounded),
                        title: const Text('Edit Name & Email'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showEditProfileDialog(
                          context,
                          ref,
                          displayProfile,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact details (shown on exported resumes)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Semantics(
                      button: true,
                      label: 'Edit contact details',
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: const Icon(Icons.contact_phone_rounded),
                        title: const Text('Contact Details'),
                        subtitle: const Text('Phone, location, job title and links'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showContactDetailsDialog(
                          context,
                          ref,
                          displayProfile,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Preferences
                  Text(
                    'Preferences',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Semantics(
                      button: true,
                      label: 'Change AI writing style',
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: const Icon(Icons.language_rounded),
                        title: const Text('AI Writing Style'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedStyle,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                        onTap: () => _showWritingStyleDialog(context, ref),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Get help and support',
                          child: ListTile(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            leading: const Icon(Icons.help_outline_rounded),
                            title: const Text('Help & Support'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _showHelpDialog(context),
                          ),
                        ),
                        const Divider(height: 1),
                        Semantics(
                          button: true,
                          label: 'Sign out of account',
                          child: ListTile(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            leading: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                            ),
                            title: const Text(
                              'Sign Out',
                              style: TextStyle(color: AppColors.error),
                            ),
                            onTap: isLoading
                                ? null
                                : () {
                                    ref
                                        .read(userProfileProvider.notifier)
                                        .signOut();
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  ImageProvider _cachedProfileImage(BuildContext context, String url) {
    final cacheSize = (100 * MediaQuery.devicePixelRatioOf(context)).round();
    return ResizeImage.resizeIfNeeded(cacheSize, cacheSize, NetworkImage(url));
  }

  void _showWritingStyleDialog(BuildContext context, WidgetRef ref) {
    final styles = [
      'Professional',
      'Creative',
      'Formal',
      'Casual',
      'Technical',
    ];
    final currentStyle =
        ref.read(userProfileProvider).profile?.aiWritingStyle ?? 'Professional';
    String selectedStyle = currentStyle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('AI Writing Style'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: styles.map((style) {
              return ListTile(
                title: Text(style),
                trailing: selectedStyle == style
                    ? const Icon(Icons.check, color: AppColors.burntOrange)
                    : null,
                onTap: () {
                  setState(() {
                    selectedStyle = style;
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(userProfileProvider.notifier)
                    .updateProfile(aiWritingStyle: selectedStyle);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Writing style set to $selectedStyle'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use CreateResume AI:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Build your resume using the Resume Wizard'),
              Text('2. Analyze your resume with AI to get an ATS score'),
              Text('3. Track your job applications'),
              Text('4. Use AI tools to improve your content'),
              SizedBox(height: 16),
              Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Email: tanzeelhussain346@gmail.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showContactDetailsDialog(
    BuildContext context,
    WidgetRef ref,
    profile,
  ) async {
    final details = await showDialog<ContactDetails>(
      context: context,
      builder: (context) => ContactDetailsDialog(profile: profile),
    );
    if (details == null || !mounted) return;
    await ref.read(userProfileProvider.notifier).updateProfile(
          jobTitle: details.jobTitle,
          phone: details.phone,
          location: details.location,
          linkedin: details.linkedin,
          github: details.github,
          leetcode: details.leetcode,
        );
    if (!context.mounted) return;
    final error = ref.read(userProfileProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error == null ? 'Contact details saved' : 'Could not save: $error'),
        backgroundColor: error == null ? null : AppColors.error,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, profile) {
    final nameController = TextEditingController(text: profile?.fullName ?? '');
    final emailController = TextEditingController(text: profile?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: false, // Email typically managed by auth provider
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref
                    .read(userProfileProvider.notifier)
                    .updateProfile(fullName: nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
