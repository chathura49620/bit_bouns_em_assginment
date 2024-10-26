import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gaming_application/components/jump_button.dart';
import 'package:flutter_gaming_application/components/level.dart';
import 'package:flutter_gaming_application/components/player.dart';

class BitBouns extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks,
        HasGameRef {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  final BuildContext context; // Add context as a field

  BitBouns(this.context); 
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showControls = true;
  bool playSounds = true;
  double soundVolume = 1.0;
  List<String> levelNames = ['Level-01', 'Level-02', 'Level-03', 'Level-04'];
  int currentLevelIndex = 0;
  int score = 23;
   late TextComponent scoreText; 
   late TextComponent levelText; 


 void collectFruit() {
    score++;
    updateScoreDisplay();
  }

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    _loadLevel();
    addScoreDisplay();
    if (showControls) {
      addJoystick();
      add(JumpButton());
    }

    return super.onLoad();
  }
  
 void addScoreDisplay() {
     scoreText = TextComponent(
      text: 'Level:${currentLevelIndex + 1 + 3}\nScore: $score',
      position: Vector2(0, 0),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
    add(scoreText);

    // Use a listener to update the display dynamicall
  }

   void updateScoreDisplay() {
    // Update the score display text directly
    scoreText.text = 'Score:\n $score\nLevel:\n ${currentLevelIndex + 1}';
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      // priority: 100,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 16, bottom: 16),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
      updateScoreDisplay();
    } else {
      // no more levels
       Navigator.pushReplacementNamed(context, '/gameWin');
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
  }
}