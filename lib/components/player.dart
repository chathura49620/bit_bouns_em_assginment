import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gaming_application/components/Saw.dart';
import 'package:flutter_gaming_application/components/checkpoint.dart';
import 'package:flutter_gaming_application/components/collision_block.dart';
import 'package:flutter_gaming_application/components/custom_hitbox.dart';
import 'package:flutter_gaming_application/components/fruit.dart';
import 'package:flutter_gaming_application/bit_bouns.dart';
import 'package:flutter_gaming_application/utils/utils.dart';

enum PlayerState { idle, running , jumping , falling ,hit , appearing , disappearing  }



class Player extends SpriteAnimationGroupComponent
    with HasGameRef<BitBouns>, KeyboardHandler, CollisionCallbacks {

  String character;
  // ignore: use_super_parameters
  Player({
    position,
    this.character = "Pink Man"
  }) : super(position: position);

  //player adding
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnnimation;
  late final SpriteAnimation jumpingAnnimation;
  late final SpriteAnimation fallingAnnimation;
  late final SpriteAnimation hitAnnimation;
  late final SpriteAnimation appearingAnnimation;
  late final SpriteAnimation disappearingAnnimation;


  final double stepTime = 0.05;

  //movements
  final double _gravity = 9.8;
  final double _jumpForce = 300;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  // ignore: non_constant_identifier_names
  List<CollisionBlock> CollisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while(accumulatedTime >= fixedDeltaTime){
      if(!gotHit && !reachedCheckpoint){
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.arrowUp);

    return super.onKeyEvent(event, keysPressed);
  }



  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(!reachedCheckpoint){
      if(other is Fruit) other.collidedWithPlayer();
      if(other is Saw) _respawn();
      if(other is Checkpoint) _reachCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _sprintAnimation('Idle', 11);
    runningAnnimation = _sprintAnimation('Run', 12);
    jumpingAnnimation = _sprintAnimation('Jump', 1);
    fallingAnnimation = _sprintAnimation('Fall', 1);
    hitAnnimation = _sprintAnimation('Hit', 7);
    appearingAnnimation = _specialSprintAnimation('Appearing', 7);
    disappearingAnnimation = _specialSprintAnimation('Desappearing', 7);

    //list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnnimation,
      PlayerState.jumping: jumpingAnnimation,
      PlayerState.falling: fallingAnnimation,
      PlayerState.hit: hitAnnimation,
      PlayerState.appearing: appearingAnnimation,
      PlayerState.disappearing: disappearingAnnimation,
    };

    //set currunt animation
    current = PlayerState.running;
  }

  SpriteAnimation _sprintAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }

  SpriteAnimation _specialSprintAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$state (96x96).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if(velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    }else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }

    //check if moving and set running
    if(velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    //check if falling set Falling
    if(velocity.y > _gravity) playerState = PlayerState.falling;

    //check if jumping set Jumping
    if(velocity.y < 0) playerState = PlayerState.jumping;


    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if(hasJumped && isOnGround) _playerJump(dt);

    // if(velocity.y > 0) isOnGround = false; optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
    
  }

  void _playerJump(double dt) {
    if(game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume * 0.5);
    velocity.y = -_jumpForce;
    position.y += velocity.y *dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _checkHorizontalCollisions() {
    for(final block in CollisionBlocks){
      //handle collisions
      if(!block.isPlatform){
        if(checkCollision(this, block)){
          if(velocity.x > 0){
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if(velocity.x < 0){
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }

      }

    }
  }
  
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
  
  void _checkVerticalCollisions() {
    for(final block in CollisionBlocks){
      //handle collisions
      if(block.isPlatform){
       if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      }else{
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if(velocity.y < 0){
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      }

    }
  }
  
  void _respawn() async {
    const hitDuration = Duration(milliseconds: 350);
    const apperingDuration = Duration(milliseconds: 350);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;
    
    Future.delayed(hitDuration,(){
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      current = PlayerState.appearing;
      Future.delayed(apperingDuration, (){
        velocity = Vector2.zero();
        position = startingPosition;
        _updatePlayerState();
        Future.delayed(canMoveDuration, () => gotHit = false);
      });
    });
  }
  
  void _reachCheckpoint() {
    reachedCheckpoint = true;
     if(game.playSounds) FlameAudio.play('disappear.wav', volume: game.soundVolume * 0.5);
    if(scale.x > 0 ){
      position = position - Vector2.all(32);
    }else if(scale.x < 0){
      position = position + Vector2(32,32);
    }
    current = PlayerState.disappearing;

    const reachedCheckpointDuration = Duration(milliseconds: 350);
    Future.delayed(reachedCheckpointDuration, (){
      reachedCheckpoint = false;
      position = Vector2.all(-640);

      const waitToChangeDuration = Duration(seconds: 3);
      Future.delayed(waitToChangeDuration, (){
          game.loadNextLevel();
      });
    });
  }

  void collidedwithEnemy() {
    _respawn();
  }
  
  
  
  
}
