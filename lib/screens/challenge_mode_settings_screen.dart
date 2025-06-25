import 'package:flutter/material.dart';
import 'challenge_mode_main_screen.dart';

class ChallengeModeSettingsScreen extends StatefulWidget {
  @override
  _ChallengeModeSettingsScreenState createState() => _ChallengeModeSettingsScreenState();
}

class _ChallengeModeSettingsScreenState extends State<ChallengeModeSettingsScreen> {
  int _questionCount = 10;
  int _playerCount = 2;
  int _timeLimit = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャレンジモード設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('問題数', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                for (var count in [10, 30, 50, 100])
                  Row(
                    children: [
                      Radio<int>(
                        value: count,
                        groupValue: _questionCount,
                        onChanged: (value) {
                          setState(() {
                            _questionCount = value!;
                          });
                        },
                      ),
                      Text('$count'),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 24),
            Text('人数', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _playerCount,
              items: List.generate(8, (index) {
                int value = index + 2;
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
            SizedBox(height: 24),
            Text('制限時間（1問あたり）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                for (var sec in [5, 7, 10])
                  Row(
                    children: [
                      Radio<int>(
                        value: sec,
                        groupValue: _timeLimit,
                        onChanged: (value) {
                          setState(() {
                            _timeLimit = value!;
                          });
                        },
                      ),
                      Text('$sec 秒'),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChallengeModeMainScreen(
                        questionCount: _questionCount,
                        playerCount: _playerCount,
                        timeLimit: _timeLimit,
                      ),
                    ),
                  );
                },
                child: Text('スタート'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 