// lib/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart'; // We need this to navigate to our HomePage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      // This duration should be slightly longer than the animation
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        // --- THIS IS THE WIDGET WE ARE CHANGING ---
        child: TweenAnimationBuilder(
          // We will animate a value from 0.0 to 1.0
          tween: Tween<double>(begin: 0.0, end: 1.0),
          // The animation will take 2 seconds
          duration: const Duration(seconds: 2),
          // The builder function runs every time the animated value changes
          builder: (context, double value, child) {
            // We'll use the 'value' to control both opacity and scale
            return Opacity(
              opacity: value, // Fades from 0.0 to 1.0
              child: Transform.scale(
                scale: value, // Scales from 0% to 100% size
                child: child,
              ),
            );
          },
          // This is the child that will be animated
          child: Image.asset('assets/logo.png', width: 200),
        ),
      ),
    );
  }
}