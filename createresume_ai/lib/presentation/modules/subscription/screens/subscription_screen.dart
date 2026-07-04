import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/user.dart';
import '../../user_profile_settings/providers/user_profile_notifier.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  void _showCheckoutUnavailable(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Checkout Not Configured'),
        content: const Text(
          'In-app billing is not connected yet. Configure a payment provider '
          '(Stripe, RevenueCat, or similar) and add SUBSCRIPTION_CHECKOUT_URL '
          'to your .env file to enable premium upgrades.',
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Close dialog',
            child: TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider.select((s) => s.profile));
    final credits = profile?.creditBalance ?? 0;
    final isPremium = profile?.subscriptionStatus == SubscriptionStatus.premium;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Upgrade Plan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose the plan that fits your job search',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You currently have $credits AI credits remaining.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _PlanCard(
                title: 'Free',
                price: '\$0',
                period: 'forever',
                features: const [
                  '3 starter AI credits',
                  'Basic resume builder',
                  'ATS score preview',
                ],
                isCurrent: !isPremium,
                isHighlighted: false,
                onSelect: null,
              ),
              const SizedBox(height: 16),
              _PlanCard(
                title: 'Premium',
                price: '\$9.99',
                period: 'per month',
                features: const [
                  '50 AI credits every month',
                  'Unlimited resume exports',
                  'Priority AI generation',
                  'Company apply tailoring',
                ],
                isCurrent: isPremium,
                isHighlighted: true,
                onSelect: isPremium
                    ? null
                    : () => _showCheckoutUnavailable(context),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.blue400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Premium unlocks more AI credits for resume generation, '
                        'analysis, and apply-hub tailoring.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isCurrent;
  final bool isHighlighted;
  final VoidCallback? onSelect;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isCurrent,
    required this.isHighlighted,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.navy800.withValues(alpha: 0.05)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.navy800 : AppColors.border,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge,
              children: [
                TextSpan(
                  text: price,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy800,
                  ),
                ),
                TextSpan(
                  text: ' / $period',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
          if (onSelect != null) ...[
            const SizedBox(height: 12),
            Semantics(
              button: true,
              label: 'Upgrade to premium plan',
              child: ElevatedButton(
                onPressed: onSelect,
                child: const Text('Upgrade to Premium'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
