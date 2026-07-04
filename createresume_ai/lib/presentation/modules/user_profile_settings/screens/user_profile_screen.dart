import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/app_theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/widgets/subscription_navigation.dart';
import '../providers/user_profile_notifier.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading =
        ref.watch(userProfileProvider.select((s) => s.isLoading));
    final profile =
        ref.watch(userProfileProvider.select((s) => s.profile));
    final themeMode = ref.watch(appThemeProvider);
    final selectedStyle = profile?.aiWritingStyle ?? 'Professional';

    ref.listen<UserProfileState>(userProfileProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        centerTitle: true,
      ),
      body: isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.blue400.withValues(alpha: 0.2),
                          backgroundImage: profile?.photoUrl != null
                              ? _cachedProfileImage(
                                  context,
                                  profile!.photoUrl!,
                                )
                              : null,
                          child: profile?.photoUrl == null
                              ? const Icon(Icons.person_rounded, size: 50, color: AppColors.blue400)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Semantics(
                            button: true,
                            label: 'Update profile photo',
                            child: GestureDetector(
                              onTap: () {
                                ref.read(userProfileProvider.notifier).updateProfilePhoto();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.navy800,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.fullName ?? 'User Name',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.email ?? 'email@example.com',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Subscription Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.navy800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Free Plan', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              Text('${profile?.creditBalance ?? 0} AI Credits', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Upgrade subscription plan',
                          child: OutlinedButton(
                            onPressed: () => navigateToSubscription(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text('Upgrade'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Edit Profile
                  Card(
                    child: Column(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Edit name and email',
                          child: ListTile(
                            leading: const Icon(Icons.edit_rounded),
                            title: const Text('Edit Name & Email'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _showEditProfileDialog(context, ref, profile),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Preferences
                  Text('Preferences', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          secondary: const Icon(Icons.dark_mode_rounded),
                          value: themeMode == ThemeMode.dark ||
                              (themeMode == ThemeMode.system &&
                                  MediaQuery.of(context).platformBrightness == Brightness.dark),
                          onChanged: (val) {
                            ref.read(appThemeProvider.notifier).toggleTheme();
                          },
                        ),
                        const Divider(height: 1),
                        Semantics(
                          button: true,
                          label: 'Change AI writing style',
                          child: ListTile(
                            leading: const Icon(Icons.language_rounded),
                            title: const Text('AI Writing Style'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(selectedStyle, style: const TextStyle(color: AppColors.textTertiary)),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                              ],
                            ),
                            onTap: () => _showWritingStyleDialog(context, ref),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Card(
                    child: Column(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Get help and support',
                          child: ListTile(
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
                            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                            title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                            onTap: isLoading ? null : () {
                              ref.read(userProfileProvider.notifier).signOut();
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
    return ResizeImage.resizeIfNeeded(
      cacheSize,
      cacheSize,
      NetworkImage(url),
    );
  }

  void _showWritingStyleDialog(BuildContext context, WidgetRef ref) {
    final styles = ['Professional', 'Creative', 'Formal', 'Casual', 'Technical'];
    final currentStyle = ref.read(userProfileProvider).profile?.aiWritingStyle ?? 'Professional';
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
                    ? const Icon(Icons.check, color: AppColors.navy800)
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
                ref.read(userProfileProvider.notifier).updateProfile(aiWritingStyle: selectedStyle);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Writing style set to $selectedStyle')),
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
              Text('Email: support@createresume.ai'),
              Text('Website: www.createresume.ai'),
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
                ref.read(userProfileProvider.notifier).updateProfile(
                  fullName: nameController.text,
                );
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
