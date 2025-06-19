import 'package:flutter/material.dart';
import '../utils/card_utils.dart';
import '../utils/poker_hand_evaluator.dart'; // PokerHandEvaluatorを必ず用意しておく
import 'hand_rank_selection_screen.dart';

class WinnerSelectionScreen extends StatefulWidget {
  final int playerCount;

  WinnerSelectionScreen({required this.playerCount});

  @override
  _WinnerSelectionScreenState createState() => _WinnerSelectionScreenState();
}

class _WinnerSelectionScreenState extends State<WinnerSelectionScreen> {
  late List<List<String>> playerCards;
  late List<String> boardCards;

  Set<int> selectedWinnerIndices = {}; // 複数選択OK
  bool isJudged = false;
  String? judgeResultMessage;
  late List<int> correctWinnerIndices; // 複数勝者対応

  late PokerHandEvaluator evaluator;
  late HandResult _bestHand; // 最高役結果を保持

  String? correctHandName; // 正解役名表示用

  @override
  void initState() {
    super.initState();
    evaluator = PokerHandEvaluator();
    _dealCards();
    correctWinnerIndices = _calculateWinners();
  }

  void _dealCards() {
    List<String> deck = CardUtils.getDeck();
    deck.shuffle();

    playerCards = [];
    int cardIndex = 0;

    for (int i = 0; i < widget.playerCount; i++) {
      playerCards.add(deck.sublist(cardIndex, cardIndex + 2));
      cardIndex += 2;
    }

    boardCards = deck.sublist(cardIndex, cardIndex + 5);
  }

  List<int> _calculateWinners() {
    List<HandResult> results = [];

    for (var hand in playerCards) {
      List<String> combined = [...hand, ...boardCards];
      results.add(evaluator.evaluate(combined));
    }

    // 最高ランクのスコアを取得
    int maxScore = results.map((r) => r.score).reduce((a, b) => a > b ? a : b);

    // 最高ランクの手役を保持
    _bestHand = results.firstWhere((r) => r.score == maxScore);

    // 最高ランクのプレイヤーをすべて取得（チョップ対応）
    List<int> winners = [];
    for (int i = 0; i < results.length; i++) {
      if (results[i].score == maxScore) winners.add(i);
    }
    return winners;
  }

  void _judgeWinner() {
    if (selectedWinnerIndices.isEmpty) return;

    // 選択が完全一致かチェック
    bool allCorrect = selectedWinnerIndices.length == correctWinnerIndices.length &&
        selectedWinnerIndices.containsAll(correctWinnerIndices);

    setState(() {
      isJudged = true;
      correctHandName = _bestHand.name; // 役名を保存

      if (allCorrect) {
        judgeResultMessage =
            '✅ 正解！ 勝者は プレイヤー ${correctWinnerIndices.map((i) => i + 1).join(", ")} です';
      } else {
        judgeResultMessage =
            '❌ 不正解！ 正解は プレイヤー ${correctWinnerIndices.map((i) => i + 1).join(", ")} で、役は $correctHandName です';
      }
    });
  }

  Color _getSuitColor(String card) {
    return CardUtils.getSuitColor(card);
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rank,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Arial',
            ),
          ),
          SizedBox(width: 4),
          Image.asset(
            suitImage,
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('勝者を選択'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text('ボードカード',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: boardCards.map(_buildCardWidget).toList(),
              ),
              SizedBox(height: 20),
              ...List.generate(widget.playerCount, (i) {
                final isSelected = selectedWinnerIndices.contains(i);
                return Card(
                  color: isSelected ? Colors.orange.shade200 : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (selectedWinnerIndices.contains(i)) {
                          selectedWinnerIndices.remove(i);
                        } else {
                          selectedWinnerIndices.add(i);
                        }
                      });
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'プレイヤー ${i + 1} の手札',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Arial',
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: playerCards[i].map(_buildCardWidget).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 20),

              if (isJudged) ...[
                Text(
                  judgeResultMessage ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                if (judgeResultMessage!.startsWith('✅')) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HandRankSelectionScreen(
                            playerCards: playerCards,
                            boardCards: boardCards,
                            winnerIndex: correctWinnerIndices.first,
                          ),
                        ),
                      );
                    },
                    child: Text('役の選択へ進む'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // 新しい問題の準備
                        _dealCards();
                        selectedWinnerIndices.clear();
                        isJudged = false;
                        judgeResultMessage = null;
                        correctHandName = null;
                        correctWinnerIndices = _calculateWinners();
                      });
                    },
                    child: Text('次の問題へ'),
                  ),
                ],
              ] else ...[
                ElevatedButton(
                  onPressed: selectedWinnerIndices.isEmpty ? null : _judgeWinner,
                  child: Text('勝者判定'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
