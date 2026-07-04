import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';

/// Navigates to the subscription upgrade screen.
void navigateToSubscription(BuildContext context) {
  context.pushNamed(AppRouteNames.subscription);
}

/// Shows a minimal upgrade dialog and routes to [SubscriptionScreen] on confirm.
void showUpgradeRequiredDialog(
  BuildContext context, {
  required String message,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Upgrade Required'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            navigateToSubscription(context);
          },
          child: const Text('View Plans'),
        ),
      ],
    ),
  );
}
