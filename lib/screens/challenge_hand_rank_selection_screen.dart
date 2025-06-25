import 'package:flutter/material.dart';
import '../utils/card_utils.dart';
import '../utils/poker_hand_evaluator.dart';
import 'dart:async';

class ChallengeHandRankSelectionScreen extends StatefulWidget {
  final List<List<String>> playerCards;
  final List<String> boardCards;
  final int winnerIndex;
  final int? timeLimit;

  ChallengeHandRankSelectionScreen({
    required this.playerCards,
    required this.boardCards,
    required this.winnerIndex,
    this.timeLimit,
  });

  @override
  _ChallengeHandRankSelectionScreenState createState() => _ChallengeHandRankSelectionScreenState();
}

class _ChallengeHandRankSelectionScreenState extends State<ChallengeHandRankSelectionScreen> {
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
  int _remainingTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    currentWinnerIndex = widget.winnerIndex;
    winnerCards = [...widget.playerCards[currentWinnerIndex], ...widget.boardCards];
    evaluator = PokerHandEvaluator();
    correctResult = evaluator.evaluate(winnerCards);
    if (widget.timeLimit != null) {
      _remainingTime = widget.timeLimit!;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _remainingTime--;
          if (_remainingTime <= 0) {
            _timer?.cancel();
            _onTimeUp();
          }
        });
      });
    }
  }

  void _onTimeUp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('時間切れ... 😢'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              Navigator.pop(context, false);
            },
            child: Text('次の問題へ'),
          ),
        ],
      ),
    );
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
        suitImagePath = 'assets/icons/unknown.png';
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
    _timer?.cancel();

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
              Navigator.pop(context, correctHand);
            },
            child: Text('次の問題へ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('役を選択'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              if (widget.timeLimit != null)
                Text('残り時間: $_remainingTime 秒', style: TextStyle(fontSize: 18)),
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
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: hands.map((hand) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: hand,
                        groupValue: selectedHand,
                        onChanged: (value) {
                          setState(() {
                            selectedHand = value;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedHand = hand;
                          });
                        },
                        child: Text(hand, style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedHand == null ? null : _checkAnswer,
                child: Text('役を判定'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 