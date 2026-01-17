import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path; 
import '../widgets/common_widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LatLng centerLocation = const LatLng(54.3716, 18.6193);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: centerLocation,
                      initialZoom: 16.0,
                    ),
                    children: [
                      // --- ZMIANA: Używamy mapy CartoDB (nie blokuje i jest ładniejsza) ---
                      TileLayer(
                        urlTemplate: 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        // CartoDB nie wymaga userAgentPackageName, wiec jest prosciej
                      ),
                      
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: centerLocation,
                            width: 80,
                            height: 80,
                            child: const UserLocationMarker(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'imie jest 200 m od domu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Na żywo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00C896),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CustomBottomNavBar(activeIndex: 2),
    );
  }
}

// ... (Reszta klas: UserLocationMarker i TrianglePainter bez zmian)
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: const Color(0xFF00C896).withOpacity(0.3), shape: BoxShape.circle),
        ),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFffffff), shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
          ),
          child: const Icon(Icons.person, color: Colors.black87, size: 24),
        ),
        Positioned(
          bottom: 10,
          child: CustomPaint(size: const Size(10, 10), painter: TrianglePainter()),
        )
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0); path.lineTo(size.width / 2, size.height); path.lineTo(size.width, 0); path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}