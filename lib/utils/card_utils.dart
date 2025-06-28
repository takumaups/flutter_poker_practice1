import 'package:flutter/material.dart';

class PokerCard {
  final String rank;
  final String suit;
  
  PokerCard({required this.rank, required this.suit});
  
  @override
  String toString() => rank + suit;
}

class CardUtils {
  static List<String> getDeck() {
    List<String> suits = ['H', 'C', 'D', 'S'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'];
    return [for (var s in suits) for (var r in ranks) r + s];
  }

  static List<PokerCard> generateAllCards() {
    List<String> suits = ['H', 'C', 'D', 'S'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'];
    List<PokerCard> cards = [];
    for (var suit in suits) {
      for (var rank in ranks) {
        cards.add(PokerCard(rank: rank, suit: suit));
      }
    }
    return cards;
  }

  static int getRankValue(String rank) {
    switch (rank) {
      case 'A': return 14;
      case 'K': return 13;
      case 'Q': return 12;
      case 'J': return 11;
      case 'T': return 10;
      default:  return int.tryParse(rank) ?? 0;
    }
  }

  /// スートに応じた画像のパスを返す
  static String getSuitImagePath(String card) {
    if (card.isEmpty) return '';
    String suitChar = card.substring(card.length - 1).toUpperCase();
    switch (suitChar) {
      case 'H': return 'assets/icons/heart.png';
      case 'C': return 'assets/icons/club.png';
      case 'D': return 'assets/icons/diamond.png';
      case 'S': return 'assets/icons/spade.png';
      default:  return '';
    }
  }

  /// 数字部分の色を返す（数字だけに使う）
  static Color getSuitColor(String card) {
    if (card.isEmpty) return Colors.black;
    String suitChar = card.substring(card.length - 1).toUpperCase();
    switch (suitChar) {
      case 'H': return Colors.red;
      case 'C': return Color(0xFF4CAF50);
      case 'D': return Color(0xFF00BCD4);
      case 'S': return Colors.black;
      default:  return Colors.black;
    }
  }

  /// カードウィジェットを構築する
  static Widget buildCardWidget(PokerCard card, {double size = 60}) {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 左上の数字とスート
          Positioned(
            top: 2,
            left: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.rank,
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: getSuitColor(card.toString()),
                  ),
                ),
                Image.asset(
                  getSuitImagePath(card.toString()),
                  width: size * 0.15,
                  height: size * 0.15,
                ),
              ],
            ),
          ),
          // 右下の数字とスート（反転）
          Positioned(
            bottom: 2,
            right: 2,
            child: Transform.rotate(
              angle: 3.14159, // 180度回転
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.rank,
                    style: TextStyle(
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: getSuitColor(card.toString()),
                    ),
                  ),
                  Image.asset(
                    getSuitImagePath(card.toString()),
                    width: size * 0.15,
                    height: size * 0.15,
                  ),
                ],
              ),
            ),
          ),
          // 中央のスート
          Center(
            child: Image.asset(
              getSuitImagePath(card.toString()),
              width: size * 0.3,
              height: size * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
