

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class UnderConstruction extends StatelessWidget {
  const UnderConstruction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Stack(

      children: [
        // Background image / white color
        Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
        ),
        // Message in the middle
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Lottie.asset(
                'assets/Lotties/rocket.json',
                height: 400,
                width:400,
                frameRate: FrameRate(60),
              ),
            ),
             Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SOON TO BE LAUNCHED',
                    style: TextStyle(
                      // fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
                      fontFamily: GoogleFonts.novaMono().fontFamily,
                      fontSize: 44,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      shadows: const [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black12,
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),

                  ),
                  const SizedBox(width: 10,),
                  const RotatingIcon(),

                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}



class RotatingIcon extends StatefulWidget {
  const RotatingIcon({super.key});

  @override
  _RotatingIconState createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(); // Repeats the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(CupertinoIcons.gear_alt_fill,
        color: Color(0xFF25283D),
        size: 54,shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black12,
            offset: Offset(5.0, 5.0),
          ),
        ],)
    );
  }
}