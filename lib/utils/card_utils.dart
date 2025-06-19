import 'package:flutter/material.dart';

class CardUtils {
  static List<String> getDeck() {
    List<String> suits = ['H', 'C', 'D', 'S'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'];
    return [for (var s in suits) for (var r in ranks) r + s];
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
}
