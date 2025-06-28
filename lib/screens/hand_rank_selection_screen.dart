import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/card_utils.dart';
import '../utils/poker_hand_evaluator.dart';

class HandRankSelectionScreen extends StatefulWidget {
  final List<List<String>> playerCards;
  final List<String> boardCards;
  final int winnerIndex;
  final int? timeLimit; // タイムアタックモード用の制限時間
  final int? remainingTime; // タイムアタックモード用の残り時間

  HandRankSelectionScreen({
    required this.playerCards,
    required this.boardCards,
    required this.winnerIndex,
    this.timeLimit,
    this.remainingTime,
  });

  @override
  _HandRankSelectionScreenState createState() => _HandRankSelectionScreenState();
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
  
  // タイムアタックモード用
  Timer? _timer;
  int _remainingTime = 0;
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    currentWinnerIndex = widget.winnerIndex;
    winnerCards = [...widget.playerCards[currentWinnerIndex], ...widget.boardCards];
    evaluator = PokerHandEvaluator();
    correctResult = evaluator.evaluate(winnerCards);
    
    // タイムアタックモードの場合、タイマーを開始
    if (widget.timeLimit != null && widget.remainingTime != null) {
      _remainingTime = widget.remainingTime!;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isTimeUp = true;
          timer.cancel();
          // 時間切れで自動的に次の問題に進む
          Navigator.pop(context, false);
        }
      });
    });
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            child: Text('人数選択に戻る'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('役を選択'),
        // タイムアタックモードの場合、制限時間を表示
        actions: widget.timeLimit != null ? [
          Container(
            padding: EdgeInsets.only(right: 45), // 45px左に移動
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  '${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
