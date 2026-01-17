import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartHelp Heart Rate',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Jasnoszare tło
        fontFamily: 'Roboto', // Możesz zmienić na np. Poppins w pubspec.yaml
        useMaterial3: true,
      ),
      home: const HeartRateScreen(),
    );
  }
}

class HeartRateScreen extends StatelessWidget {
  const HeartRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Górny pasek (Header)
            const HeaderSection(),
            
            // 2. Główna zawartość (scrollowalna)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Tytuł i przyciski akcji
                    const TitleSection(),
                    
                    const SizedBox(height: 40),
                    
                    // Różowe koło z sercem
                    const HeartIndicator(),
                    
                    const SizedBox(height: 20),
                    
                    // Wynik (82 BPM)
                    const ResultValue(),
                    
                    const SizedBox(height: 30),
                    
                    // Karta "w normie" i pasek gradientu
                    const StatusCard(),
                    
                    const SizedBox(height: 100), // Miejsce na dolny pasek
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 3. Dolny pasek nawigacji (Floating)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CustomBottomNavBar(),
    );
  }
}

// --- WIDGETY SKŁADOWE ---

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'SmartHelp',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Row(
            children: [
              _textButton('A'),
              const SizedBox(width: 8),
              _textButton('A+'),
              const SizedBox(width: 8),
              _textButton('A++'),
              const SizedBox(width: 12),
              // Przycisk kontrastu (czarne tło, żółte A)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.yellow, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textButton(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey, fontSize: 16),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pomiar tętna',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400, // Light/Regular style
            color: Color(0xFF2D2D2D),
          ),
        ),
        Row(
          children: [
            // IKONA: Wykres
            _circleButton(Icons.bar_chart_rounded), 
            const SizedBox(width: 12),
            // IKONA: Udostępnij
            _circleButton(Icons.share_outlined),
          ],
        )
      ],
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black54, size: 24),
    );
  }
}

class HeartIndicator extends StatelessWidget {
  const HeartIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDE2), // Jasny róż tła
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCDE2).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Color(0xFFFF8FA3), // Ciemniejszy róż w środku
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.monitor_heart, // TU WGRAJ SWOJĄ IKONĘ SERCA
            size: 50,
            color: Colors.white, // Lub lekko różowy
          ),
        ),
      ),
    );
  }
}

class ResultValue extends StatelessWidget {
  const ResultValue({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '82',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                  height: 1.0,
                ),
              ),
              TextSpan(
                text: ' BPM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.access_time, size: 16, color: Colors.pinkAccent),
            SizedBox(width: 4),
            Text(
              '5 minut temu',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'twoje tętno jest',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Text(
                'w normie',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.favorite, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          
          // --- Pasek gradientu ---
          const GradientGauge(),
          
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('20', style: TextStyle(color: Colors.grey)),
              Text('140', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'W ciągu ostatnich 7 dni Twoje serce biło średnio z prędkością 85 uderzeń na minutę.',
            style: TextStyle(
              color: Color(0xFF666666),
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientGauge extends StatelessWidget {
  const GradientGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Wysokość paska + znacznika
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Tło gradientowe
          Container(
            height: 24, // Trochę niższe niż całość, żeby znacznik wystawał
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6DC6D8), // Niebieski
                  Color(0xFFA5E68C), // Jasny zielony
                  Color(0xFFF3E798), // Żółtawy
                  Color(0xFFEF837B), // Czerwony
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          // Znacznik (zielona kreska)
          // Używamy Align lub Positioned. W realnej apce obliczylibyśmy pozycję
          // na podstawie wartości (82 w zakresie 20-140).
          // Tutaj ustawiam "na oko" jak na obrazku.
          const Positioned(
            left: 80, // Pozycja suwaka
            child: SizedBox(
              height: 30,
              width: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF1B8E3B), // Ciemna zieleń znacznika
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
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
          // IKONY DOLNEGO PASKA - Tu podmienisz na swoje
          _navItem(Icons.home_outlined, false),
          // Aktywny element (ciemne tło)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF333333), // Ciemnoszary
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border, color: Colors.white),
          ),
          _navItem(Icons.location_on_outlined, false),
          _navItem(Icons.calendar_today_outlined, false),
          _navItem(Icons.history, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isActive) {
    return Icon(
      icon,
      size: 26,
      color: isActive ? Colors.black : Colors.black54,
    );
  }
}