import 'package:flutter/material.dart';
import '../screens/heart_screen.dart';
import '../screens/blood_saturation_screen.dart';
import '../screens/map_screen.dart';
import '../screens/history_screen.dart';
import '../screens/calendar_screen.dart';
import '../services/theme_service.dart';
import '../widgets/notification_bell.dart';

class HeaderSection extends StatelessWidget {
  final String title;
  final bool showChartIcon;
  final VoidCallback? onHistoryTap;

  const HeaderSection({
    super.key,
    this.title = 'SmartHelp',
    this.showChartIcon = false,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isHighContrast,
      builder: (context, isHighContrast, child) {
        final textColor = isHighContrast
            ? Colors.yellow
            : const Color(0xFF2D2D2D);
        final iconBgColor = isHighContrast
            ? Colors.black
            : const Color(0xFFF1F1F4); // Jasne tło dla ikon
        final iconColor = isHighContrast ? Colors.yellow : Colors.black54;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  if (showChartIcon) ...[
                    GestureDetector(
                      onTap: onHistoryTap,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bar_chart_rounded,
                          size: 24,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  NotificationBell(iconColor: iconColor, withBackground: true),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () {
                      ThemeService().toggle();
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.yellow, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'A',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int activeIndex;
  const CustomBottomNavBar({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isHighContrast,
      builder: (context, isHighContrast, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          height: 65,
          decoration: BoxDecoration(
            color: isHighContrast ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: isHighContrast
                ? Border.all(color: Colors.yellow, width: 2)
                : null,
            boxShadow: [
              if (!isHighContrast)
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(
                context,
                Icons.invert_colors,
                isActive: activeIndex == 0,
                targetPage: const BloodSaturationScreen(),
                isHighContrast: isHighContrast,
              ),
              _navItem(
                context,
                Icons.favorite_border,
                isActive: activeIndex == 1,
                targetPage: const HeartRateScreen(),
                isHighContrast: isHighContrast,
              ),
              _navItem(
                context,
                Icons.location_on_outlined,
                isActive: activeIndex == 2,
                targetPage: const MapScreen(),
                isHighContrast: isHighContrast,
              ),
              _navItem(
                context,
                Icons.calendar_today_outlined,
                isActive: activeIndex == 3,
                targetPage: const CalendarScreen(),
                isHighContrast: isHighContrast,
              ),
              _navItem(
                context,
                Icons.history,
                isActive: activeIndex == 4,
                targetPage: const HistoryScreen(),
                isHighContrast: isHighContrast,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon, {
    required bool isActive,
    Widget? targetPage,
    required bool isHighContrast,
  }) {
    return GestureDetector(
      onTap: () {
        if (targetPage != null && !isActive) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, anim1, anim2) => targetPage,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isActive
            ? BoxDecoration(
                color: isHighContrast ? Colors.yellow : const Color(0xFF333333),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          size: 26,
          color: isActive
              ? (isHighContrast ? Colors.black : Colors.white)
              : (isHighContrast ? Colors.yellow : Colors.black54),
        ),
      ),
    );
  }
}
