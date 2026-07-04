import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/application.dart';
import '../../../widgets/shimmer_skeleton.dart';
import '../providers/application_tracker_notifier.dart';

class ApplicationTrackerScreen extends ConsumerWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsState = ref.watch(applicationTrackerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Application Tracker')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(applicationTrackerProvider),
        child: applicationsState.when(
          data: (apps) {
            if (apps.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No applications tracked yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking your job applications here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return RepaintBoundary(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      height: constraints.maxHeight - 48,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKanbanColumn(
                            context,
                            ref,
                            'Applied',
                            ApplicationStatus.applied,
                            apps,
                            AppColors.blue400,
                          ),
                          const SizedBox(width: 24),
                          _buildKanbanColumn(
                            context,
                            ref,
                            'Interviewing',
                            ApplicationStatus.interview,
                            apps,
                            AppColors.warning,
                          ),
                          const SizedBox(width: 24),
                          _buildKanbanColumn(
                            context,
                            ref,
                            'Offer Received',
                            ApplicationStatus.offer,
                            apps,
                            AppColors.success,
                          ),
                          const SizedBox(width: 24),
                          _buildKanbanColumn(
                            context,
                            ref,
                            'Archived',
                            ApplicationStatus.archived,
                            apps,
                            AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => _buildLoadingSkeleton(),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text('Failed to load applications: $e'),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Retry loading applications',
                  child: ElevatedButton(
                    onPressed: () => ref.invalidate(applicationTrackerProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Add new application',
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          child: FloatingActionButton(
            onPressed: () => _showAddApplicationSheet(context, ref),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(4, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < 3 ? 24 : 0),
            child: SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShimmerCard(height: 48),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: 3,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) => ShimmerCard(height: 80),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    WidgetRef ref,
    String title,
    ApplicationStatus status,
    List<Application> allApps,
    Color headerColor,
  ) {
    final columnApps = allApps.where((a) => a.status == status).toList();

    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: headerColor, width: 4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${columnApps.length}',
                    style: TextStyle(
                      color: headerColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Application>(
              onWillAcceptWithDetails: (details) =>
                  details.data.status != status,
              onAcceptWithDetails: (details) {
                ref
                    .read(applicationTrackerProvider.notifier)
                    .updateStatus(details.data.id, status);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? headerColor
                          : AppColors.border,
                      width: candidateData.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: columnApps.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = columnApps[index];
                      return Draggable<Application>(
                        data: app,
                        feedback: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 260,
                            child: _ApplicationCard(app: app),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _ApplicationCard(app: app),
                        ),
                        child: _ApplicationCard(app: app),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddApplicationSheet(BuildContext context, WidgetRef ref) {
    // Simplified bottom sheet form for creating applications
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddApplicationForm(
        onSave: (company, role) {
          ref
              .read(applicationTrackerProvider.notifier)
              .addApplication(
                companyName: company,
                jobTitle: role,
                status: ApplicationStatus.applied,
                appliedDate: DateTime.now(),
              );
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application app;

  const _ApplicationCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.jobTitle,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(app.companyName, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${app.appliedDate.month}/${app.appliedDate.day}/${app.appliedDate.year}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddApplicationForm extends StatefulWidget {
  final void Function(String company, String role) onSave;

  const _AddApplicationForm({required this.onSave});

  @override
  State<_AddApplicationForm> createState() => _AddApplicationFormState();
}

class _AddApplicationFormState extends State<_AddApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Track New Application',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyCtrl,
              decoration: const InputDecoration(labelText: 'Company Name'),
              validator: (val) => Validators.required(val, 'Company name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleCtrl,
              decoration: const InputDecoration(labelText: 'Job Title'),
              validator: (val) => Validators.required(val, 'Job title'),
            ),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: 'Add application to tracker',
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(_companyCtrl.text, _roleCtrl.text);
                  }
                },
                child: const Text('Add to Tracker'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
