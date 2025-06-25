class HandResult {
  final String name;
  final int score;
  final List<String> cards;

  HandResult(this.name, this.score, this.cards);
}

class PokerHandEvaluator {
  static const Map<String, int> rankValue = {
    '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7,
    '8': 8, '9': 9, 'T': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14,
  };

  HandResult evaluate(List<String> cards) {
    if (cards.length < 5) {
      throw ArgumentError('5枚以上のカードを渡してください');
    }

    List<List<String>> fiveCardCombos = _combinations(cards, 5);
    HandResult bestResult = HandResult('ハイカード', 0, []);

    for (var combo in fiveCardCombos) {
      var result = _evaluateFiveCards(combo);
      if (result.score > bestResult.score) {
        bestResult = result;
      }
    }

    return bestResult;
  }

  HandResult _evaluateFiveCards(List<String> fiveCards) {
    List<int> ranks = fiveCards.map((c) => rankValue[c[0]]!).toList();
    List<String> suits = fiveCards.map((c) => c[1]).toList();

    Map<int, int> rankCounts = {};
    for (var r in ranks) {
      rankCounts[r] = (rankCounts[r] ?? 0) + 1;
    }

    var counts = rankCounts.values.toList();
    counts.sort((a, b) => b.compareTo(a));

    bool flush = suits.toSet().length == 1;
    var straightHighCard = _getStraightHighCard(ranks);

    // ロイヤルフラッシュ
    if (flush && straightHighCard == 14) {
      var flushRanks = _getFlushRanks(fiveCards, suits[0]);
      if (flushRanks.toSet().containsAll([14, 13, 12, 11, 10])) {
        return HandResult('ロイヤルフラッシュ', 9000000, fiveCards);
      }
    }

    // ストレートフラッシュ
    if (flush && straightHighCard != null) {
      var flushRanks = _getFlushRanks(fiveCards, suits[0]);
      if (_getStraightHighCard(flushRanks) != null) {
        return HandResult('ストレートフラッシュ', 8000000 + straightHighCard! * 1000, fiveCards);
      }
    }

    // フォーカード
    if (counts[0] == 4) {
      int four = rankCounts.entries.firstWhere((e) => e.value == 4).key;
      int kicker = ranks.firstWhere((r) => r != four);
      return HandResult('フォーカード', 7000000 + four * 1000 + kicker, fiveCards);
    }

    // フルハウス
    if (counts[0] == 3 && counts.length > 1 && counts[1] >= 2) {
      int three = rankCounts.entries.firstWhere((e) => e.value == 3).key;
      int pair = rankCounts.entries
          .where((e) => e.value >= 2 && e.key != three)
          .map((e) => e.key)
          .fold(0, (a, b) => a > b ? a : b);
      return HandResult('フルハウス', 6000000 + three * 1000 + pair, fiveCards);
    }

    // フラッシュ
    if (flush) {
      List<int> flushRanks = _getFlushRanks(fiveCards, suits[0]);
      flushRanks.sort((a, b) => b.compareTo(a));
      int score = 5000000;
      int multiplier = 1000;
      for (var r in flushRanks) {
        score += r * multiplier;
        multiplier ~/= 10;
      }
      return HandResult('フラッシュ', score, fiveCards);
    }

    // ストレート
    if (straightHighCard != null) {
      return HandResult('ストレート', 4000000 + straightHighCard * 1000, fiveCards);
    }

    // スリーカード
    if (counts[0] == 3) {
      int three = rankCounts.entries.firstWhere((e) => e.value == 3).key;
      List<int> kickers = ranks.where((r) => r != three).toList()..sort((a, b) => b.compareTo(a));
      while (kickers.length < 2) kickers.add(0);
      return HandResult('スリーカード', 3000000 + three * 10000 + kickers[0] * 100 + kickers[1], fiveCards);
    }

    // ツーペア
    if (counts[0] == 2 && counts[1] == 2) {
      List<int> pairs = rankCounts.entries.where((e) => e.value == 2).map((e) => e.key).toList();
      pairs.sort((a, b) => b.compareTo(a));
      int kicker = ranks.firstWhere((r) => !pairs.contains(r));
      return HandResult('ツーペア', 2000000 + pairs[0] * 1000 + pairs[1] * 10 + kicker, fiveCards);
    }

    // ワンペア
    if (counts[0] == 2) {
      int pair = rankCounts.entries.firstWhere((e) => e.value == 2).key;
      List<int> kickers = ranks.where((r) => r != pair).toList()..sort((a, b) => b.compareTo(a));
      int kickerScore = 0, multiplier = 100;
      for (var r in kickers) {
        kickerScore += r * multiplier;
        multiplier ~/= 10;
      }
      return HandResult('ワンペア', 1000000 + pair * 1000 + kickerScore, fiveCards);
    }

    // ハイカード
    ranks.sort((a, b) => b.compareTo(a));
    int score = 0, multiplier = 10000;
    for (var r in ranks) {
      score += r * multiplier;
      multiplier ~/= 10;
    }
    return HandResult('ハイカード', score, fiveCards);
  }

  List<int> _getFlushRanks(List<String> cards, String suit) {
    return cards.where((c) => c[1] == suit).map((c) => rankValue[c[0]]!).toList();
  }

  int? _getStraightHighCard(List<int> inputRanks) {
    Set<int> setRanks = inputRanks.toSet();
    List<int> ranks = setRanks.toList()..sort((a, b) => b.compareTo(a));

    // 通常のストレート判定
    for (int i = 0; i <= ranks.length - 5; i++) {
      bool straight = true;
      for (int j = 1; j < 5; j++) {
        if (ranks[i + j - 1] - 1 != ranks[i + j]) {
          straight = false;
          break;
        }
      }
      if (straight) return ranks[i];
    }

    // ローボールストレート（A-2-3-4-5）
    if (setRanks.containsAll([14, 5, 4, 3, 2])) {
      return 5;
    }

    return null;
  }

  List<List<T>> _combinations<T>(List<T> list, int r) {
    List<List<T>> result = [];
    void comb(int start, List<T> current) {
      if (current.length == r) {
        result.add(List.from(current));
        return;
      }
      for (int i = start; i < list.length; i++) {
        current.add(list[i]);
        comb(i + 1, current);
        current.removeLast();
      }
    }
    comb(0, []);
    return result;
  }
}
