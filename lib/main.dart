import 'package:flutter/material.dart';
import 'screens/player_count_screen.dart';
import 'screens/mode_selection_screen.dart';

void main() {
  runApp(PokerPracticeApp());
}

class PokerPracticeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'テキサスホールデム勝者判定練習',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ModeSelectionScreen(),
    );
  }
}
