import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static final SensorService instance = SensorService._init();
  SensorService._init();

  StreamSubscription? _accelerometerSub;
  StreamSubscription? _gyroscopeSub;

  // Shake detection state
  int _lastShakeTimestamp = 0;
  static const double _shakeThreshold = 14.0;
  static const int _shakeSlopTimeMs = 800;

  // Gyroscope tilt state (Pitch & Roll for 3D card tilt)
  double pitch = 0.0;
  double roll = 0.0;

  // Start listening to Accelerometer for "Shake to Shuffle"
  void startShakeDetection({required Function() onShake}) {
    _accelerometerSub?.cancel();
    _accelerometerSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      final double gX = event.x;
      final double gY = event.y;
      final double gZ = event.z;

      // Net acceleration calculation minus earth gravity
      final double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > _shakeThreshold) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (_lastShakeTimestamp + _shakeSlopTimeMs < now) {
          _lastShakeTimestamp = now;
          HapticFeedback.mediumImpact();
          onShake();
        }
      }
    });
  }

  // Start listening to Gyroscope for "Mystic 3D Parallax Tilt"
  void startGyroscopeTilt({required Function(double pitch, double roll) onTilt}) {
    _gyroscopeSub?.cancel();
    _gyroscopeSub = gyroscopeEventStream().listen((GyroscopeEvent event) {
      // Accumulate or damp rotation
      pitch = (pitch * 0.9) + (event.x * 0.1);
      roll = (roll * 0.9) + (event.y * 0.1);

      // Clamp between -1.0 and 1.0 for smooth shader/matrix animation
      final clampedPitch = pitch.clamp(-1.0, 1.0);
      final clampedRoll = roll.clamp(-1.0, 1.0);

      onTilt(clampedPitch, clampedRoll);
    });
  }

  void stopAll() {
    _accelerometerSub?.cancel();
    _gyroscopeSub?.cancel();
  }
}

