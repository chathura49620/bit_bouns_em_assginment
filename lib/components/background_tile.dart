import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class BackgroundTile extends ParallaxComponent with HasGameRef {
  final String color;

  BackgroundTile({
    this.color = 'Gray',
    position,
  }) : super(
          position: position,
        );

  final double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
    size = Vector2.all(64);

    // Ensure the color path is valid
    final imagePath = 'Background/${color.isNotEmpty ? color : "Gray"}.png';

    // Preload the image to avoid cache errors
    await gameRef.images.load(imagePath);

    parallax = await gameRef.loadParallax(
      [ParallaxImageData(imagePath)],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );

    return super.onLoad();
  }
}
