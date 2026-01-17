import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class HeartRateScreen extends StatelessWidget {
  const HeartRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const TitleSection(),
                    const SizedBox(height: 40),
                    const HeartIndicator(),
                    const SizedBox(height: 20),
                    const ResultValue(),
                    const SizedBox(height: 30),
                    const StatusCard(),
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CustomBottomNavBar(activeIndex: 1),
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
            fontWeight: FontWeight.w400, 
            color: Color(0xFF2D2D2D),
          ),
        ),
        Row(
          children: [
            _circleButton(Icons.bar_chart_rounded), 
            const SizedBox(width: 12),
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
        color: const Color(0xFFFFCDE2), 
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
            color: Color(0xFFFF8FA3), 
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.monitor_heart,
            size: 50,
            color: Colors.white,
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
      height: 30, 
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 24, 
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6DC6D8), 
                  Color(0xFFA5E68C), 
                  Color(0xFFF3E798), 
                  Color(0xFFEF837B), 
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          const Positioned(
            left: 80, 
            child: SizedBox(
              height: 30,
              width: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF1B8E3B), 
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