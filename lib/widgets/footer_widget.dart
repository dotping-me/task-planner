import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FooterScene extends StatelessWidget {
  const FooterScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: MediaQuery.of(context).size.width, // Take the full width

      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [

          // Ground
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // flush to bottom
            child: Container(
              height: 40, // ground thickness
              color: const Color.fromARGB(255, 30, 117, 216),
            ),
          ),

          // Candle
          Positioned(
            right: 50,
            bottom: 32,
            child: SvgPicture.asset(
              'assets/candle.svg',
              height: 60,
            ),
          ),

          // Bird
          Positioned(
            right: 100,
            bottom: 32,
            child: SvgPicture.asset(
              'assets/bird.svg',
              height: 60,
            ),
          ),
        ],
      ),
    );
  }
}