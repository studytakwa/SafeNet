import 'package:flutter/material.dart';

class TimeLimitScreen extends StatelessWidget {
  const TimeLimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_off, size: 80),
              SizedBox(height: 16),
              Text('Limite de 2h atteinte',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Reviens demain, prends une pause ! 😊',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}