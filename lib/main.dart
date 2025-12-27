import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const LuminaApp());

class LuminaApp extends StatelessWidget {
  const LuminaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const FocusPulseScreen(),
    );
  }
}

class FocusPulseScreen extends StatefulWidget {
  const FocusPulseScreen({super.key});
  @override
  State<FocusPulseScreen> createState() => _FocusPulseScreenState();
}

class _FocusPulseScreenState extends State<FocusPulseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  Timer? _timer;
  int _secondsRemaining = 1500; // 25 minutes
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  void _toggleTimer() {
    if (_isActive) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) _secondsRemaining--;
          else _timer?.cancel();
        });
      });
    }
    setState(() => _isActive = !_isActive);
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
              ),
            ),
          ),
          // 2. The Focus Orb
          Center(
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Container(
                  width: 250 + (20 * _breathingController.value),
                  height: 250 + (20 * _breathingController.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.3 * _breathingController.value),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_secondsRemaining),
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w200, color: Colors.white),
                            ),
                            const Text("FOCUS", style: TextStyle(letterSpacing: 4, color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 3. Control Button
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleTimer,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Text(
                    _isActive ? "PAUSE" : "START SESSION",
                    style: const TextStyle(color: Colors.white, letterSpacing: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
