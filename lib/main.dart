import 'package:flutter/material.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gaming_application/auth/login_screen.dart';
import 'package:flutter_gaming_application/auth/register_screen.dart';
import 'package:flutter_gaming_application/components/game_screen.dart';
import 'package:flutter_gaming_application/components/game_win_screen.dart';
import 'package:flutter_gaming_application/components/menu_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(
    MaterialApp(
      initialRoute: '/splash',
      title: 'Pixel Adventure',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/splash': (context) => const SplashScreen(),
        '/menu': (context) => const MenuScreen(),
        '/game': (context) => const GameScreen(),
        '/gameWin': (context) => const GameWinScreen(),
      },
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlameSplashScreen(
      theme: FlameSplashTheme.white,
      onFinish: (BuildContext context) => Navigator.pushReplacementNamed(context, '/login'),
      showBefore: (BuildContext context) {
        return const Text(
          'Welcome to Bit Bouns',
          style: TextStyle(fontSize: 24, color: Colors.white),
        );
      },
      showAfter: (BuildContext context) {
        return const CircularProgressIndicator();
      },
    );
  }
}
