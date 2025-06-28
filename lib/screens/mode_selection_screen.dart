import 'package:flutter/material.dart';
import 'player_count_screen.dart';
import 'challenge_mode_settings_screen.dart';
import 'time_attack_settings_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('モード選択'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerCountScreen(),
                  ),
                );
              },
              child: Text('ひたすら練習モード'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChallengeModeSettingsScreen(),
                  ),
                );
              },
              child: Text('チャレンジモード'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimeAttackSettingsScreen(),
                  ),
                );
              },
              child: Text('タイムアタック'),
            ),
          ],
        ),
      ),
    );
  }
} 