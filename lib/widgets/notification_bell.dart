import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationBell extends StatelessWidget {
  final Color iconColor;
  final bool withBackground; 

  const NotificationBell({
    super.key, 
    this.iconColor = Colors.black54,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget bellIcon = Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_none, size: 24, color: iconColor),
        
        ValueListenableBuilder<int>(
          valueListenable: NotificationService().unreadCount,
          builder: (context, count, child) {
            if (count == 0) return const SizedBox(); 
            return Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );

    return GestureDetector(
      onTap: () => _showNotificationsDialog(context),
      child: withBackground 
        ? Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: bellIcon,
          )
        : bellIcon, 
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    NotificationService().markAllAsRead(); 

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Powiadomienia", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: NotificationService().unreadCount,
                  builder: (context, _, __) {
                    final list = NotificationService().notifications;
                    if (list.isEmpty) {
                      return const Center(child: Text("Brak nowych powiadomień", style: TextStyle(color: Colors.grey)));
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFFFFF0F5), shape: BoxShape.circle),
                            child: const Icon(Icons.access_time, color: Color(0xFFFF669D), size: 20),
                          ),
                          title: Text(list[i].title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text(list[i].time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Zamknij", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}