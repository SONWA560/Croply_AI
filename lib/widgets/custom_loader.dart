import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class CustomLoader extends StatefulWidget {
  final double size;
  
  const CustomLoader({
    this.size = 100.0,
    super.key,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1700),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer gradient ring with blur effect
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFBA42FF), // rgb(186, 66, 255)
                        Color(0xFF00E1FF), // rgb(0, 225, 255)
                      ],
                      stops: [0.35, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBA42FF).withOpacity(0.6),
                        offset: const Offset(0, -5),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: const Color(0xFF00E1FF).withOpacity(0.6),
                        offset: const Offset(0, 5),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                // Inner dark circle with blur
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: widget.size * 0.92,
                      height: widget.size * 0.92,
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424), // rgb(36, 36, 36)
                        borderRadius: BorderRadius.circular(widget.size / 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
