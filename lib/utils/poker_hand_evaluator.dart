// PokerHandEvaluator.dart
// 7枚のカードから最強役判定を行うクラス
// 役判定は完全対応：ロイヤルフラッシュ～ハイカードまで対応済み
// HandResultをトップレベルに出す
class HandResult {
  final String name;
  final int score;
  final List<String> cards;

  HandResult(this.name, this.score, this.cards);
}
class PokerHandEvaluator {
  // 役の種類（手札ランク）
  static const List<String> handRanks = [
    'High Card',
    'One Pair',
    'Two Pair',
    'Three of a Kind',
    'Straight',
    'Flush',
    'Full House',
    'Four of a Kind',
    'Straight Flush',
    'Royal Flush',
  ];

  // カードのランク順序
  static const Map<String, int> rankValue = {
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    'T': 10,
    'J': 11,
    'Q': 12,
    'K': 13,
    'A': 14,
  };

  // 入力: List<String> cards（例：['AS', 'KD', 'TH', ...]）7枚
  // 出力: HandResult (役名, 役の強さの点数, ベスト5枚)
  HandResult evaluate(List<String> cards) {
    if (cards.length < 5) {
      throw ArgumentError('5枚以上のカードを渡してください');
    }

    // 7枚中5枚で最強役を探索

    // 全ての5枚の組み合わせを列挙（21通り）
    List<List<String>> fiveCardCombos = _combinations(cards, 5);

    HandResult bestResult = HandResult('High Card', 0, []);

    for (var combo in fiveCardCombos) {
      var result = _evaluateFiveCards(combo);
      if (result.score > bestResult.score) {
        bestResult = result;
      }
    }

    return bestResult;
  }

  // 5枚のカードから役判定
  HandResult _evaluateFiveCards(List<String> fiveCards) {
    // カードをランク順にソート（降順）
    List<int> ranks = fiveCards.map((c) => rankValue[c[0]]!).toList();
    ranks.sort((a, b) => b.compareTo(a));

    List<String> suits = fiveCards.map((c) => c[1]).toList();

    bool flush = suits.toSet().length == 1;

    bool straight = _isStraight(ranks);

    Map<int, int> rankCounts = {};
    for (var r in ranks) {
      rankCounts[r] = (rankCounts[r] ?? 0) + 1;
    }

    // カウントの種類ごとに分類
    var counts = rankCounts.values.toList();
    counts.sort((a, b) => b.compareTo(a)); // 降順

    // 各役を判定（強い順）
    // ロイヤルフラッシュ
    if (flush && straight && ranks[0] == 14 && ranks[1] == 13) {
      return HandResult('ロイヤルフラッシュ', 9000000, fiveCards);
    }

    // ストレートフラッシュ
    if (flush && straight) {
      return HandResult('ストレートフラッシュ', 8000000 + ranks[0] * 1000, fiveCards);
    }

    // フォーカード
    if (counts[0] == 4) {
      int fourRank = rankCounts.entries.firstWhere((e) => e.value == 4).key;
      return HandResult('フォーカード', 7000000 + fourRank * 1000, fiveCards);
    }

    // フルハウス
    if (counts[0] == 3 && counts[1] == 2) {
      int threeRank = rankCounts.entries.firstWhere((e) => e.value == 3).key;
      int pairRank = rankCounts.entries.firstWhere((e) => e.value == 2).key;
      return HandResult('フルハウス', 6000000 + threeRank * 1000 + pairRank, fiveCards);
    }

    // フラッシュ
    if (flush) {
      int score = 5000000;
      int multiplier = 1000;
      for (var r in ranks) {
        score += r * multiplier;
        multiplier ~/= 10;
      }
      return HandResult('フラッシュ', score, fiveCards);
    }

    // ストレート
    if (straight) {
      return HandResult('ストレート', 4000000 + ranks[0] * 1000, fiveCards);
    }

    // スリーカード
    if (counts[0] == 3) {
      int threeRank = rankCounts.entries.firstWhere((e) => e.value == 3).key;
      return HandResult('スリーカード', 3000000 + threeRank * 1000, fiveCards);
    }

    // ツーペア
    if (counts[0] == 2 && counts[1] == 2) {
      // 高いペアと低いペアを取得
      List<int> pairs = rankCounts.entries.where((e) => e.value == 2).map((e) => e.key).toList();
      pairs.sort((a, b) => b.compareTo(a));
      int kicker = ranks.firstWhere((r) => !pairs.contains(r));
      int score = 2000000 + pairs[0] * 1000 + pairs[1] * 10 + kicker;
      return HandResult('ツーペア', score, fiveCards);
    }

    // ワンペア
    if (counts[0] == 2) {
      int pairRank = rankCounts.entries.firstWhere((e) => e.value == 2).key;
      int kickerScore = 0;
      int multiplier = 100;
      for (var r in ranks) {
        if (r != pairRank) {
          kickerScore += r * multiplier;
          multiplier ~/= 10;
        }
      }
      return HandResult('ワンペア', 1000000 + pairRank * 1000 + kickerScore, fiveCards);
    }

    // ハイカード
    int score = 0;
    int multiplier = 10000;
    for (var r in ranks) {
      score += r * multiplier;
      multiplier ~/= 10;
    }
    return HandResult('ハイカード', score, fiveCards);
  }

  // ストレート判定（ランクは降順）
  bool _isStraight(List<int> ranks) {
    // A-5ストレート対応
    List<int> distinctRanks = ranks.toSet().toList();
    distinctRanks.sort((a, b) => b.compareTo(a));
    if (distinctRanks.length < 5) return false;

    for (int i = 0; i <= distinctRanks.length - 5; i++) {
      bool straight = true;
      for (int j = 0; j < 4; j++) {
        if (distinctRanks[i + j] - distinctRanks[i + j + 1] != 1) {
          straight = false;
          break;
        }
      }
      if (straight) return true;
    }

    // A-2-3-4-5判定
    if (distinctRanks.contains(14) &&
        distinctRanks.contains(5) &&
        distinctRanks.contains(4) &&
        distinctRanks.contains(3) &&
        distinctRanks.contains(2)) {
      return true;
    }

    return false;
  }

  // nCr の組み合わせを返す（再帰）
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
