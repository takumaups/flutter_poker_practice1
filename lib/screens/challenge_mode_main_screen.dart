import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/card_utils.dart';
import '../utils/poker_hand_evaluator.dart';

class ChallengeModeMainScreen extends StatefulWidget {
  final int questionCount;
  final int playerCount;
  final int timeLimit;

  ChallengeModeMainScreen({
    required this.questionCount,
    required this.playerCount,
    required this.timeLimit,
  });

  @override
  _ChallengeModeMainScreenState createState() => _ChallengeModeMainScreenState();
}

class _ChallengeModeMainScreenState extends State<ChallengeModeMainScreen> {
  int _currentQuestion = 1;
  int _remainingTime = 0;
  Timer? _timer;
  int _correctCount = 0;
  Set<int> _selectedWinnerIndices = {};
  List<List<String>> _playerCards = [];
  List<String> _boardCards = [];
  List<int> _correctWinnerIndices = [];
  String? _correctHandName;
  late PokerHandEvaluator _evaluator;

  // 役選択用
  bool _winnerJudged = false;
  bool _winnerCorrect = false;
  String? _selectedHand;
  bool _handJudged = false;
  bool _handCorrect = false;
  late int _mainWinnerIndex;
  late HandResult _mainWinnerResult;
  final List<String> _hands = [
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

  @override
  void initState() {
    super.initState();
    _evaluator = PokerHandEvaluator();
    _dealCardsAndSetWinners();
    _startTimer();
  }

  void _dealCardsAndSetWinners() {
    List<String> deck = CardUtils.getDeck();
    deck.shuffle();
    _playerCards = [];
    int cardIndex = 0;
    for (int i = 0; i < widget.playerCount; i++) {
      _playerCards.add(deck.sublist(cardIndex, cardIndex + 2));
      cardIndex += 2;
    }
    _boardCards = deck.sublist(cardIndex, cardIndex + 5);
    _correctWinnerIndices = _calculateWinners();
    _mainWinnerIndex = _correctWinnerIndices[0];
    _mainWinnerResult = _evaluator.evaluate([..._playerCards[_mainWinnerIndex], ..._boardCards]);
    _correctHandName = _mainWinnerResult.name;
  }

  List<int> _calculateWinners() {
    List<HandResult> results = [];
    for (var hand in _playerCards) {
      List<String> combined = [...hand, ..._boardCards];
      results.add(_evaluator.evaluate(combined));
    }
    int maxScore = results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
    List<int> winners = [];
    for (int i = 0; i < results.length; i++) {
      if (results[i].score == maxScore) winners.add(i);
    }
    return winners;
  }

  void _startTimer() {
    _remainingTime = widget.timeLimit;
    _timer?.cancel();
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

  void _onTimeUp() {
    setState(() {
      _winnerJudged = true;
      _winnerCorrect = false;
      _handJudged = true;
      _handCorrect = false;
    });
  }

  void _onJudgeWinner() {
    if (_winnerJudged) return;
    bool allCorrect = _selectedWinnerIndices.length == _correctWinnerIndices.length &&
        _selectedWinnerIndices.containsAll(_correctWinnerIndices);
    setState(() {
      _winnerJudged = true;
      _winnerCorrect = allCorrect;
      if (!allCorrect) {
        _handJudged = true;
        _handCorrect = false;
      }
      _timer?.cancel();
    });
  }

  void _onJudgeHand() {
    if (_handJudged || _selectedHand == null) return;
    bool handCorrect = _selectedHand == _correctHandName;
    setState(() {
      _handJudged = true;
      _handCorrect = handCorrect;
      if (_winnerCorrect && handCorrect) _correctCount++;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.questionCount) {
      setState(() {
        _currentQuestion++;
        _selectedWinnerIndices.clear();
        _winnerJudged = false;
        _winnerCorrect = false;
        _selectedHand = null;
        _handJudged = false;
        _handCorrect = false;
      });
      _dealCardsAndSetWinners();
      _startTimer();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('終了'),
          content: Text('正答数: $_correctCount / ${widget.questionCount}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildCardWidget(String card) {
    final rank = card.substring(0, card.length - 1);
    final suitImage = CardUtils.getSuitImagePath(card);
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

  Widget _buildHandSelection() {
    final winnerCards = [..._playerCards[_mainWinnerIndex], ..._boardCards];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('勝者のカード (手札＋ボード)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          children: winnerCards.map(_buildCardWidget).toList(),
        ),
        SizedBox(height: 20),
        Text('あなたの考えた役を選んでください', style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        ..._hands.map((hand) => RadioListTile<String>(
              title: Text(hand),
              value: hand,
              groupValue: _selectedHand,
              onChanged: _handJudged
                  ? null
                  : (value) {
                      setState(() {
                        _selectedHand = value;
                      });
                    },
            )),
        SizedBox(height: 16),
        if (!_handJudged)
          Center(
            child: ElevatedButton(
              onPressed: _selectedHand == null ? null : _onJudgeHand,
              child: Text('役を判定'),
            ),
          ),
        if (_handJudged)
          Center(
            child: Column(
              children: [
                Text(
                  _handCorrect ? '✅ 正解！' : '❌ 不正解！',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('正解の役: $_correctHandName'),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text('次の問題へ'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャレンジモード ($_currentQuestion/${widget.questionCount})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('残り時間: $_remainingTime 秒', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('ボードカード', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _boardCards.map(_buildCardWidget).toList(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: !_winnerJudged
                  ? ListView.builder(
                      itemCount: widget.playerCount,
                      itemBuilder: (context, i) {
                        final isSelected = _selectedWinnerIndices.contains(i);
                        return Card(
                          color: isSelected ? Colors.orange.shade200 : null,
                          child: InkWell(
                            onTap: _winnerJudged
                                ? null
                                : () {
                                    setState(() {
                                      if (_selectedWinnerIndices.contains(i)) {
                                        _selectedWinnerIndices.remove(i);
                                      } else {
                                        _selectedWinnerIndices.add(i);
                                      }
                                    });
                                  },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('プレイヤー ${i + 1} の手札',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Row(
                                    children: _playerCards[i].map(_buildCardWidget).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : _winnerCorrect && !_handJudged
                      ? _buildHandSelection()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _winnerCorrect ? '✅ 勝者選択 正解！' : '❌ 勝者選択 不正解',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text('正解: プレイヤー ${_correctWinnerIndices.map((i) => i + 1).join(", ")}'),
                              Text('役: $_correctHandName'),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _nextQuestion,
                                child: Text('次の問題へ'),
                              ),
                            ],
                          ),
                        ),
            ),
            if (!_winnerJudged)
              ElevatedButton(
                onPressed: _selectedWinnerIndices.isEmpty ? null : _onJudgeWinner,
                child: Text('判定'),
              ),
          ],
        ),
      ),
    );
  }
} 