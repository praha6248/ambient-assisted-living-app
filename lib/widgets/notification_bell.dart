import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';

class NotificationBell extends StatelessWidget {
  final Color? iconColor; 
  final bool withBackground; 

  const NotificationBell({
    super.key, 
    this.iconColor,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isHighContrast,
      builder: (context, isHighContrast, child) {
        
        final finalIconColor = iconColor ?? (isHighContrast ? Colors.yellow : Colors.black54);
        final badgeBgColor = isHighContrast ? Colors.yellow : const Color(0xFFEB4755);
        final badgeTextColor = isHighContrast ? Colors.black : Colors.white;

        Widget bellIcon = Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none, size: 24, color: finalIconColor),
            
            ValueListenableBuilder<int>(
              valueListenable: NotificationService().unreadCount,
              builder: (context, count, child) {
                if (count == 0) return const SizedBox(); 
                return Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : count.toString(),
                        style: TextStyle(
                          color: badgeTextColor,
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
                  color: isHighContrast ? Colors.black : const Color(0xFFF4F1F2),
                  shape: BoxShape.circle,
                ),
                child: bellIcon,
              )
            : bellIcon, 
        );
      }
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    NotificationService().markAllAsRead(); 
    final bool isHighContrast = ThemeService().isHighContrast.value;

    final Color bgColor = isHighContrast ? Colors.black : Colors.white;
    final Color textColor = isHighContrast ? Colors.yellow : Colors.black;
    final Color subTextColor = isHighContrast ? Colors.yellow : Colors.grey;
    final Color iconBgColor = isHighContrast ? Colors.yellow : const Color(0xFFC0C8F2);
    final Color iconColor = isHighContrast ? Colors.black : const Color(0xFF5757DB);
    final Color btnBgColor = isHighContrast ? Colors.yellow : Colors.black;
    final Color btnTextColor = isHighContrast ? Colors.black : Colors.white;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgColor,
        surfaceTintColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isHighContrast ? const BorderSide(color: Colors.yellow) : BorderSide.none,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Powiadomienia", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: NotificationService().unreadCount,
                  builder: (context, _, __) {
                    final list = NotificationService().notifications;
                    if (list.isEmpty) {
                      return Center(
                        child: Text("Brak nowych powiadomień", style: TextStyle(color: subTextColor))
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (ctx, i) => Divider(height: 1, color: isHighContrast ? Colors.yellow : Colors.grey.shade300),
                      itemBuilder: (ctx, i) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                            child: Icon(Icons.access_time, color: iconColor, size: 20),
                          ),
                          title: Text(
                            list[i].title, 
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textColor)
                          ),
                          subtitle: Text(
                            list[i].time, 
                            style: TextStyle(fontSize: 12, color: subTextColor)
                          ),
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
                    backgroundColor: btnBgColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Zamknij", style: TextStyle(color: btnTextColor)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}