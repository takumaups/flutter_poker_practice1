import 'package:flutter/material.dart';
import 'time_attack_main_screen.dart';

class TimeAttackSettingsScreen extends StatefulWidget {
  @override
  _TimeAttackSettingsScreenState createState() => _TimeAttackSettingsScreenState();
}

class _TimeAttackSettingsScreenState extends State<TimeAttackSettingsScreen> {
  int _playerCount = 2;
  int _timeLimit = 120; // デフォルト120秒

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('タイムアタック設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('人数', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
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
            SizedBox(height: 32),
            Text('制限時間', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                for (var sec in [60, 120, 180])
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
                      Text('${sec}秒'),
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
                      builder: (_) => TimeAttackMainScreen(
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