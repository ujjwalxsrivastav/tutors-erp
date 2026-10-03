import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/services/auth_service.dart';

class TutorNotificationsPage extends ConsumerWidget {
  const TutorNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationServiceProvider).markAllAsRead(user.uid),
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: ref.read(notificationServiceProvider).streamNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No notifications',
              subtitle: 'You\'re all caught up! New assignment & demo updates will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = notifications[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n.read ? AppTheme.surface : AppTheme.primaryGreen.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: n.read ? AppTheme.borderLight : AppTheme.primaryGreen.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: n.read ? Colors.transparent : AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: AppTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(n.body, style: AppTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text(
                            timeago.format(n.createdAt),
                            style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!n.read)
                      IconButton(
                        icon: const Icon(Icons.check, size: 18, color: AppTheme.primaryGreen),
                        tooltip: 'Mark as read',
                        onPressed: () => ref.read(notificationServiceProvider).markAsRead(n.id),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
