import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gaming_application/bit_bouns.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pass context to BitBouns
    BitBouns game = BitBouns(context);

    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}