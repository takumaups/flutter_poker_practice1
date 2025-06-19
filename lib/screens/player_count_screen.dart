import 'package:flutter/material.dart';
import 'winner_selection_screen.dart';

class PlayerCountScreen extends StatefulWidget {
  @override
  _PlayerCountScreenState createState() => _PlayerCountScreenState();
}

class _PlayerCountScreenState extends State<PlayerCountScreen> {
  int _playerCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プレイヤー人数を選択'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('人数を選んでください', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            DropdownButton<int>(
              value: _playerCount,
              items: List.generate(8, (index) {
                int value = index + 2; // 2人〜9人
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value 人'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _playerCount = value;
                  });
                }
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WinnerSelectionScreen(playerCount: _playerCount),
                  ),
                );
              },
              child: Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}
