import 'package:flutter/material.dart';
import 'challenge_mode_settings_screen.dart';
import 'mode_selection_screen.dart';
import 'challenge_mode_main_screen.dart';

class ChallengeReviewScreen extends StatelessWidget {
  final List<ChallengeHistoryEntry> history;
  final int correctCount;
  final int totalCount;

  ChallengeReviewScreen({
    required this.history,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('チャレンジ振り返り')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('正答数: $correctCount / $totalCount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('正答率: ${(correctCount / totalCount * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, i) {
                  final entry = history[i];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('第${entry.questionNumber}問', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(entry.timeUp ? '時間切れ！' : (entry.winnerCorrect && entry.handCorrect ? '⭕ 正解' : '❌ 不正解'),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: entry.winnerCorrect && entry.handCorrect && !entry.timeUp ? Colors.green : Colors.red)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text('ボードカード:'),
                          Row(
                            children: entry.boardCards.map((c) => _buildCardWidget(c)).toList(),
                          ),
                          SizedBox(height: 4),
                          Text('自分の勝者選択: ${entry.selectedWinnerIndices.map((i) => i + 1).join(", ")}'),
                          Text('正解の勝者: ${entry.correctWinnerIndices.map((i) => i + 1).join(", ")}'),
                          SizedBox(height: 2),
                          Text('自分の役選択: ${entry.selectedHand ?? "-"}'),
                          Text('正解の役: ${entry.correctHand ?? "-"}'),
                          SizedBox(height: 4),
                          Text('各プレイヤーの手札:'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: List.generate(entry.playerCards.length, (idx) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('P${idx + 1}', style: TextStyle(fontSize: 12)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: entry.playerCards[idx].map((c) => _buildCardWidget(c)).toList(),
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => ChallengeModeSettingsScreen()),
                      (route) => false,
                    );
                  },
                  child: Text('もう一度チャレンジ'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => ModeSelectionScreen()),
                      (route) => false,
                    );
                  },
                  child: Text('ホームに戻る'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWidget(String card) {
    final rank = card.substring(0, card.length - 1);
    final suitChar = card[card.length - 1].toUpperCase();
    String suitImage;
    switch (suitChar) {
      case 'H':
        suitImage = 'assets/icons/heart.png';
        break;
      case 'C':
        suitImage = 'assets/icons/club.png';
        break;
      case 'D':
        suitImage = 'assets/icons/diamond.png';
        break;
      case 'S':
        suitImage = 'assets/icons/spade.png';
        break;
      default:
        suitImage = 'assets/icons/unknown.png';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rank, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(width: 2),
          Image.asset(suitImage, width: 14, height: 14),
        ],
      ),
    );
  }
} 