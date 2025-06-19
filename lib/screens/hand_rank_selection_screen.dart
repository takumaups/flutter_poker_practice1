import 'package:flutter/material.dart';
import 'winner_selection_screen.dart';
import 'player_count_screen.dart';
import '../utils/card_utils.dart';
import '../utils/poker_hand_evaluator.dart';

class HandRankSelectionScreen extends StatefulWidget {
  final List<List<String>> playerCards;
  final List<String> boardCards;
  final int winnerIndex;

  HandRankSelectionScreen({
    required this.playerCards,
    required this.boardCards,
    required this.winnerIndex,
  });

  @override
  _HandRankSelectionScreenState createState() =>
      _HandRankSelectionScreenState();
}

class _HandRankSelectionScreenState extends State<HandRankSelectionScreen> {
  final List<String> hands = [
    'ハイカード',
    'ワンペア',
    'ツーペア',
    'スリーカード',
    'ストレート',
    'フラッシュ',
    'フルハウス',
    'フォーカード',
    'ストレートフラッシュ',
    'ロイヤルフラッシュ',
  ];

  String? selectedHand;
  late List<String> winnerCards;
  late PokerHandEvaluator evaluator;
  late HandResult correctResult;
  late int currentWinnerIndex;

  @override
  void initState() {
    super.initState();
    currentWinnerIndex = widget.winnerIndex;
    winnerCards = [...widget.playerCards[currentWinnerIndex], ...widget.boardCards];
    evaluator = PokerHandEvaluator();
    correctResult = evaluator.evaluate(winnerCards);
  }



  Widget buildCardWidget(String card) {
    if (card.isEmpty) return SizedBox.shrink();

    final rank = card.substring(0, card.length - 1);
    final suitChar = card[card.length - 1].toUpperCase();

    String suitImagePath;
    switch (suitChar) {
      case 'H':
        suitImagePath = 'assets/icons/heart.png';
        break;
      case 'C':
        suitImagePath = 'assets/icons/club.png';
        break;
      case 'D':
        suitImagePath = 'assets/icons/diamond.png';
        break;
      case 'S':
        suitImagePath = 'assets/icons/spade.png';
        break;
      default:
        suitImagePath = 'assets/icons/unknown.png'; // 念のため
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
            suitImagePath,
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    if (selectedHand == null) return;

    bool correctHand = selectedHand == correctResult.name;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correctHand ? '正解！🎉' : '不正解... 😢'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('あなたの選択: $selectedHand'),
            Text('正解の役: ${correctResult.name}'),
            SizedBox(height: 10),
            Text('勝者: プレイヤー${currentWinnerIndex + 1}'),
            SizedBox(height: 10),
            Text('【役判定の詳細】'),
            Wrap(
              children: winnerCards.map(buildCardWidget).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => WinnerSelectionScreen(
                    playerCount: widget.playerCards.length,
                  ),
                ),
                (route) => false,
              );
            },
            child: Text('次の問題へ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => PlayerCountScreen()),
                (route) => false,
              );
            },
            child: Text('人数を変更する'),
          ),
        ],
      ),
    );
  }

  void _loadNextProblem() {
    setState(() {
      currentWinnerIndex = (currentWinnerIndex + 1) % widget.playerCards.length;
      winnerCards = [...widget.playerCards[currentWinnerIndex], ...widget.boardCards];
      correctResult = evaluator.evaluate(winnerCards);
      selectedHand = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('役を選択'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text('勝者のカード (手札＋ボード)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              children: winnerCards.map(buildCardWidget).toList(),
            ),
            SizedBox(height: 20),
            Text('あなたの考えた役を選んでください',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: hands.map((hand) {
                  return RadioListTile<String>(
                    title: Text(hand),
                    value: hand,
                    groupValue: selectedHand,
                    onChanged: (value) {
                      setState(() {
                        selectedHand = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: selectedHand == null ? null : _checkAnswer,
              child: Text('判定する'),
            ),
          ],
        ),
      ),
    );
  }
}
