import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/services/auth_service.dart';

class AdminNotificationsPage extends ConsumerWidget {
  const AdminNotificationsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Notifications'), actions: [
        TextButton(onPressed: () => ref.read(notificationServiceProvider).markAllAsRead(user.uid), child: const Text('Mark all read')),
        const SizedBox(width: 8),
      ]),
      body: StreamBuilder(
        stream: ref.read(notificationServiceProvider).streamNotifications(user.uid),
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) return const EmptyState(icon: Icons.notifications_off_outlined, title: 'No notifications', subtitle: 'You\'re all caught up!');
          return ListView.separated(padding: const EdgeInsets.all(16), itemCount: notifications.length, separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final n = notifications[i];
              return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
                color: n.read ? AppTheme.surface : AppTheme.primaryGreen.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm), border: Border.all(color: n.read ? AppTheme.borderLight : AppTheme.primaryGreen.withValues(alpha: 0.2))),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: n.read ? Colors.transparent : AppTheme.primaryGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title, style: AppTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(n.body, style: AppTheme.bodySmall, maxLines: 2),
                    const SizedBox(height: 4),
                    Text(timeago.format(n.createdAt), style: AppTheme.labelSmall),
                  ])),
                  if (!n.read) IconButton(icon: const Icon(Icons.done, size: 18), onPressed: () => ref.read(notificationServiceProvider).markAsRead(n.id)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
