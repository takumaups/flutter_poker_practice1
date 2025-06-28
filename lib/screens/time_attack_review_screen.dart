import 'package:flutter/material.dart';

class TimeAttackReviewScreen extends StatelessWidget {
  final int score;
  final List<Map<String, dynamic>> questionHistory;
  final int timeLimit;

  TimeAttackReviewScreen({
    required this.score,
    required this.questionHistory,
    required this.timeLimit,
  });

  @override
  Widget build(BuildContext context) {
    int correctCount = questionHistory.where((q) => q['isCorrect']).length;
    int totalQuestions = questionHistory.length;
    double accuracy = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('タイムアタック結果'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 結果サマリー
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('最終スコア', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    '$score 点',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('解答数', style: TextStyle(fontSize: 14)),
                          Text('$totalQuestions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('正解数', style: TextStyle(fontSize: 14)),
                          Text('$correctCount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('正答率', style: TextStyle(fontSize: 14)),
                          Text('${accuracy.toStringAsFixed(1)}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // 解答履歴
            Text('解答履歴', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...questionHistory.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> question = entry.value;
              
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: question['isCorrect'] ? Colors.green.shade300 : Colors.red.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: question['isCorrect'] ? Colors.green.shade50 : Colors.red.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '問題 ${question['questionIndex']}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: question['isCorrect'] ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            question['isCorrect'] ? '正解' : '不正解',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // ボードカード
                    Text('ボードカード:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: (question['boardCards'] as List<String>).map(_buildCardWidget).toList(),
                    ),
                    SizedBox(height: 8),
                    
                    // プレイヤーの手札
                    Text('プレイヤーの手札:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    ...List.generate(question['playerCards'].length, (playerIndex) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text('プレイヤー${playerIndex + 1}: ', style: TextStyle(fontSize: 12)),
                            ...(question['playerCards'][playerIndex] as List<String>).map(_buildCardWidget).toList(),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 8),
                    
                    // 解答と正解
                    Row(
                      children: [
                        Text('勝者選択: ', style: TextStyle(fontSize: 12)),
                        Text(
                          question['winnerCorrect'] ? '正解' : '不正解',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: question['winnerCorrect'] ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('役選択: ', style: TextStyle(fontSize: 12)),
                        Text(
                          question['handCorrect'] ? '正解' : '不正解',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: question['handCorrect'] ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('正解の勝者: ', style: TextStyle(fontSize: 12)),
                        Text(
                          'プレイヤー${(question['correctWinnerIndices'] as List<int>).map((i) => i + 1).join(", ")}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('正解の役: ', style: TextStyle(fontSize: 12)),
                        Text(
                          '${question['correctHandName']}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            
            SizedBox(height: 24),
            
            // ホームに戻るボタン
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('ホームに戻る'),
              ),
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
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rank,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Arial',
            ),
          ),
          SizedBox(width: 2),
          Image.asset(
            suitImage,
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }
} 