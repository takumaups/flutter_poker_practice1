import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/card_utils.dart';
import '../utils/poker_hand_evaluator.dart';
import 'challenge_hand_rank_selection_screen.dart';
import 'challenge_mode_settings_screen.dart';
import 'mode_selection_screen.dart';
import 'challenge_review_screen.dart';

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
  int _handRemainingTime = 0;
  Timer? _handTimer;
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

  String? judgeResultMessage;

  List<ChallengeHistoryEntry> _history = [];

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

  void _startHandTimer() {
    _handRemainingTime = widget.timeLimit;
    _handTimer?.cancel();
    _handTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _handRemainingTime--;
        if (_handRemainingTime <= 0) {
          _handTimer?.cancel();
          _onHandTimeUp();
        }
      });
    });
  }

  void _onTimeUp() {
    setState(() {
      if (!_winnerJudged) {
        _winnerJudged = true;
        _winnerCorrect = false;
        _handJudged = true;
        _handCorrect = false;
        judgeResultMessage = '時間切れ！';
        _timer?.cancel();
        _handTimer?.cancel();
      } else if (_winnerCorrect && !_handJudged) {
        // 役選択中のタイムアップ
        _handJudged = true;
        _handCorrect = false;
        judgeResultMessage = '時間切れ！';
        _handTimer?.cancel();
      }
    });
  }

  void _onHandTimeUp() {
    setState(() {
      if (_winnerCorrect && !_handJudged) {
        _handJudged = true;
        _handCorrect = false;
        _handTimer?.cancel();
      }
    });
  }

  void _onJudgeWinner() async {
    if (_winnerJudged) return;
    bool allCorrect = _selectedWinnerIndices.length == _correctWinnerIndices.length &&
        _selectedWinnerIndices.containsAll(_correctWinnerIndices);
    setState(() {
      _winnerJudged = true;
      _winnerCorrect = allCorrect;
      if (!allCorrect) {
        _handJudged = true;
        _handCorrect = false;
        _timer?.cancel();
        _handTimer?.cancel();
      }
    });
    if (allCorrect) {
      _timer?.cancel();
      _handTimer?.cancel();
      // HandRankSelectionScreenに遷移し、役判定の正誤を受け取る
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ChallengeHandRankSelectionScreen(
            playerCards: _playerCards,
            boardCards: _boardCards,
            winnerIndex: _correctWinnerIndices[0],
            timeLimit: widget.timeLimit,
          ),
        ),
      );
      if (result == true) {
        setState(() {
          _correctCount++;
        });
      }
      _nextQuestion();
    }
  }

  void _onJudgeHand() {
    if (_handJudged || _selectedHand == null) return;
    bool handCorrect = _selectedHand == _correctHandName;
    setState(() {
      _handJudged = true;
      _handCorrect = handCorrect;
      if (_winnerCorrect && handCorrect) _correctCount++;
      _handTimer?.cancel();
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
      _handTimer?.cancel();
      // 履歴を記録
      _history.add(ChallengeHistoryEntry(
        questionNumber: _currentQuestion,
        playerCards: List<List<String>>.from(_playerCards.map((e) => List<String>.from(e))),
        boardCards: List<String>.from(_boardCards),
        selectedWinnerIndices: Set<int>.from(_selectedWinnerIndices),
        correctWinnerIndices: List<int>.from(_correctWinnerIndices),
        winnerCorrect: _winnerCorrect,
        selectedHand: _selectedHand,
        correctHand: _correctHandName,
        handCorrect: _handCorrect,
        timeUp: judgeResultMessage == '時間切れ！',
      ));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChallengeReviewScreen(
            history: _history,
            correctCount: _correctCount,
            totalCount: widget.questionCount,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _handTimer?.cancel();
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
    // HandRankSelectionScreenに遷移するため、ここは使わない
    return SizedBox.shrink();
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
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.8,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: widget.playerCount,
                      physics: NeverScrollableScrollPhysics(),
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
                              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'プレイヤー ${i + 1} の手札',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Expanded(
                                    child: Row(
                                      children: _playerCards[i].map(_buildCardWidget).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : !_winnerCorrect
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('❌ 勝者選択 不正解', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text('正解: プレイヤー ${_correctWinnerIndices.map((i) => i + 1).join(", ")}'),
                              Text('役: $_correctHandName'),
                              SizedBox(height: 12),
                              Text('あなたの選択: ${_selectedWinnerIndices.map((i) => i + 1).join(", ")}'),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _boardCards.map(_buildCardWidget).toList(),
                              ),
                              SizedBox(height: 12),
                              if (_selectedWinnerIndices.isNotEmpty)
                                Column(
                                  children: [
                                    Text('あなたが選んだ手札'),
                                    ..._selectedWinnerIndices.map((idx) => Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _playerCards[idx].map(_buildCardWidget).toList(),
                                    )),
                                  ],
                                ),
                              SizedBox(height: 8),
                              Text('正解の手札'),
                              ..._correctWinnerIndices.map((idx) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _playerCards[idx].map(_buildCardWidget).toList(),
                              )),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _nextQuestion,
                                child: Text('次の問題へ'),
                              ),
                            ],
                          ),
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
            if ((_winnerJudged || _handJudged) && judgeResultMessage != null && judgeResultMessage!.isNotEmpty)
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    judgeResultMessage!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChallengeHistoryEntry {
  final int questionNumber;
  final List<List<String>> playerCards;
  final List<String> boardCards;
  final Set<int> selectedWinnerIndices;
  final List<int> correctWinnerIndices;
  final bool winnerCorrect;
  final String? selectedHand;
  final String? correctHand;
  final bool handCorrect;
  final bool timeUp;

  ChallengeHistoryEntry({
    required this.questionNumber,
    required this.playerCards,
    required this.boardCards,
    required this.selectedWinnerIndices,
    required this.correctWinnerIndices,
    required this.winnerCorrect,
    required this.selectedHand,
    required this.correctHand,
    required this.handCorrect,
    required this.timeUp,
  });
} 