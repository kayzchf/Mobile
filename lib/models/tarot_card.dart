class TarotCard {
  final int id;
  final int number;
  final String name;
  final String arcanaType;
  final String element;
  final String uprightMeaning;
  final String reversedMeaning;
  final String loveAdvice;
  final String careerAdvice;
  final List<String> keywords;
  final String affirmation;
  final String symbol;
  final String? imagePath;

  const TarotCard({
    required this.id,
    required this.number,
    required this.name,
    required this.arcanaType,
    required this.element,
    required this.uprightMeaning,
    required this.reversedMeaning,
    required this.loveAdvice,
    required this.careerAdvice,
    required this.keywords,
    required this.affirmation,
    required this.symbol,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'arcana_type': arcanaType,
      'element': element,
      'upright_meaning': uprightMeaning,
      'reversed_meaning': reversedMeaning,
      'love_advice': loveAdvice,
      'career_advice': careerAdvice,
      'keywords': keywords.join(','),
      'affirmation': affirmation,
      'symbol': symbol,
      'image_path': imagePath,
    };
  }

  factory TarotCard.fromMap(Map<String, dynamic> map) {
    return TarotCard(
      id: map['id'] as int,
      number: map['number'] as int,
      name: map['name'] as String,
      arcanaType: map['arcana_type'] as String,
      element: map['element'] as String,
      uprightMeaning: map['upright_meaning'] as String,
      reversedMeaning: map['reversed_meaning'] as String,
      loveAdvice: map['love_advice'] as String,
      careerAdvice: map['career_advice'] as String,
      keywords: (map['keywords'] as String).split(','),
      affirmation: map['affirmation'] as String? ?? '',
      symbol: map['symbol'] as String? ?? '🔮',
      imagePath: map['image_path'] as String? ?? 'assets/cards/${map['number']}.png',
    );
  }
}
