import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.6, // Adjust opacity as needed
              child: Image.asset(
                'assets/images/Background/menuBackground.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
    
    Scaffold(
      appBar: AppBar(
        title: const Text('Game Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/game');
              },
              child: const Text('Start Game'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add other menu options like settings or leaderboard
              },
              child: const Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add other menu options
              },
              child: const Text('Leaderboard'),
            ),
          ],
        ),
      ),
    )
        ]
    );
  }
}
