import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() =>
      _StopwatchPageState();
}

class _StopwatchPageState
    extends State<StopwatchPage> {
  Timer? timer;

  int seconds = 0;
  bool berjalan = false;

  String get waktu {
    final jam =
        (seconds ~/ 3600)
            .toString()
            .padLeft(2, '0');

    final menit =
        ((seconds % 3600) ~/ 60)
            .toString()
            .padLeft(2, '0');

    final detik =
        (seconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$jam:$menit:$detik';
  }

  void mulaiBerhenti() {
    if (berjalan) {
      timer?.cancel();

      setState(() {
        berjalan = false;
      });
    } else {
      setState(() {
        berjalan = true;
      });

      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            seconds++;
          });
        },
      );
    }
  }

  void reset() {
    timer?.cancel();

    setState(() {
      seconds = 0;
      berjalan = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E1065),
            Color(0xFF0F172A),
            Color(0xFF030712),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                '⏳',
                style: TextStyle(
                  fontSize: 55,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Stopwatch Sesi Konsultasi',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE9D5FF),
                ),
              ),

              const SizedBox(height: 30),

              Card(
                color: const Color(0xFF0F172A),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    waktu,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Color(0xFFD8B4FE),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: mulaiBerhenti,
                      child: Text(
                        berjalan
                            ? 'BERHENTI'
                            : 'MULAI',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: reset,
                      child: const Text(
                        'RESET',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}