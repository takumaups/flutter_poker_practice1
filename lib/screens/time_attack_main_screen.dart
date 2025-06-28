import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/card_utils.dart';
import '../utils/poker_hand_evaluator.dart';
import 'hand_rank_selection_screen.dart';
import 'time_attack_review_screen.dart';

class TimeAttackMainScreen extends StatefulWidget {
  final int playerCount;
  final int timeLimit;

  TimeAttackMainScreen({
    required this.playerCount,
    required this.timeLimit,
  });

  @override
  _TimeAttackMainScreenState createState() => _TimeAttackMainScreenState();
}

class _TimeAttackMainScreenState extends State<TimeAttackMainScreen> {
  late Timer _timer;
  int _remainingTime = 0;
  int _score = 0;
  int _currentQuestionIndex = 0;
  List<Map<String, dynamic>> _questionHistory = [];
  bool _isGameOver = false;
  
  late List<List<String>> _playerCards;
  late List<String> _boardCards;
  late List<int> _correctWinnerIndices;
  late String _correctHandName;
  bool _winnerCorrect = false;
  bool _handCorrect = false;
  
  // 勝者選択用の状態
  Set<int> _selectedWinnerIndices = {};
  bool _winnerJudged = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.timeLimit;
    _startTimer();
    _generateNewQuestion();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer.cancel();
    setState(() {
      _isGameOver = true;
    });
    
    // 振り返り画面に遷移
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TimeAttackReviewScreen(
          score: _score,
          questionHistory: _questionHistory,
          timeLimit: widget.timeLimit,
        ),
      ),
    );
  }

  void _generateNewQuestion() {
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
    _correctHandName = _getCorrectHandName();
    
    // 状態をリセット
    _selectedWinnerIndices.clear();
    _winnerJudged = false;
    _winnerCorrect = false;
    _handCorrect = false;
  }

  List<int> _calculateWinners() {
    List<HandResult> results = [];
    var evaluator = PokerHandEvaluator();

    for (var hand in _playerCards) {
      List<String> combined = [...hand, ..._boardCards];
      results.add(evaluator.evaluate(combined));
    }

    // 最高ランクのスコアを取得
    int maxScore = results.map((r) => r.score).reduce((a, b) => a > b ? a : b);

    // 最高ランクのプレイヤーをすべて取得（チョップ対応）
    List<int> winners = [];
    for (int i = 0; i < results.length; i++) {
      if (results[i].score == maxScore) winners.add(i);
    }
    return winners;
  }

  String _getCorrectHandName() {
    var evaluator = PokerHandEvaluator();
    List<String> winnerCards = [..._playerCards[_correctWinnerIndices.first], ..._boardCards];
    var result = evaluator.evaluate(winnerCards);
    return result.name;
  }

  void _judgeWinner() {
    if (_selectedWinnerIndices.isEmpty) return;

    // 選択が完全一致かチェック
    bool allCorrect = _selectedWinnerIndices.length == _correctWinnerIndices.length &&
        _selectedWinnerIndices.containsAll(_correctWinnerIndices);

    setState(() {
      _winnerJudged = true;
      _winnerCorrect = allCorrect;
    });
    
    if (allCorrect) {
      // 勝者選択が正解の場合、役選択画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HandRankSelectionScreen(
            playerCards: _playerCards,
            boardCards: _boardCards,
            winnerIndex: _correctWinnerIndices.first,
            timeLimit: widget.timeLimit,
            remainingTime: _remainingTime,
          ),
        ),
      ).then((handCorrect) {
        _handCorrect = handCorrect ?? false;
        // 役選択から戻ってきたら直接次の問題に進む
        _processAnswer();
      });
    } else {
      // 勝者選択が不正解の場合、次の問題へ
      _processAnswer();
    }
  }

  void _processAnswer() {
    // 得点計算（勝者選択と役選択の両方が正解で+1点、どちらかが不正解で-1点）
    if (_winnerCorrect && _handCorrect) {
      _score++;
    } else {
      _score--;
    }
    
    // 解答履歴に追加
    _questionHistory.add({
      'questionIndex': _currentQuestionIndex + 1,
      'playerCards': _playerCards,
      'boardCards': _boardCards,
      'correctWinnerIndices': _correctWinnerIndices,
      'correctHandName': _correctHandName,
      'winnerCorrect': _winnerCorrect,
      'handCorrect': _handCorrect,
      'isCorrect': _winnerCorrect && _handCorrect,
      'remainingTime': _remainingTime,
    });
    
    _currentQuestionIndex++;
    
    // 次の問題を生成
    _generateNewQuestion();
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
    if (_isGameOver) {
      return Scaffold(
        appBar: AppBar(
          title: Text('タイムアタック'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('時間切れ！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('最終スコア: $_score 点', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('タイムアタック'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 45),
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
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // スコア表示
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('スコア: $_score 点', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('問題: ${_currentQuestionIndex + 1}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // ボードカード
            Text('ボードカード', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _boardCards.map(_buildCardWidget).toList(),
            ),
            SizedBox(height: 20),
            
            // プレイヤーの手札（直接勝者選択可能）
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: widget.playerCount,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
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
              ),
            ),
            
            SizedBox(height: 16),
            
            if (!_winnerJudged) ...[
              Text('勝者を選択してください', 
                   style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _selectedWinnerIndices.isEmpty ? null : _judgeWinner,
                child: Text('勝者判定'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 