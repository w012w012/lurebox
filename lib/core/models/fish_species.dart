/// 鱼类分类枚举
///
/// 用于对鱼类进行分类管理
enum FishCategory {
  freshwaterLure('淡水路亚', '淡水路亚鱼种'),
  freshwaterGeneral('淡水综合', '淡水综合鱼种'),
  saltwaterLure('海水路亚', '海水路亚鱼种'),
  saltwaterGeneral('海水综合', '海水综合鱼种');

  const FishCategory(this.label, this.description);
  final String label;
  final String description;

  static FishCategory fromValue(int value) {
    return FishCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FishCategory.freshwaterLure,
    );
  }

  int get value {
    switch (this) {
      case FishCategory.freshwaterLure:
        return 0;
      case FishCategory.freshwaterGeneral:
        return 1;
      case FishCategory.saltwaterLure:
        return 2;
      case FishCategory.saltwaterGeneral:
        return 3;
    }
  }
}

/// 鱼类稀有度枚举
///
/// 表示鱼类的稀有程度，用于成就系统和图鉴展示
enum FishRarity {
  common(1, '普通'),
  uncommon(2, '少见'),
  rare(3, '稀有'),
  legendary(4, '传说'),
  mythical(5, '神话');

  const FishRarity(this.value, this.label);
  final int value;
  final String label;

  static FishRarity fromValue(int value) {
    return FishRarity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FishRarity.common,
    );
  }
}

/// 鱼类物种模型
///
/// 代表一个具体的鱼类物种，包含学名、分类、稀有度、习性等信息
class FishSpecies {
  final String id;
  final String standardName;
  final String? scientificName;
  final List<String> aliases;
  final FishCategory category;
  final FishRarity rarity;
  final String? habitat;
  final String? behavior;
  final String? fishingMethod;
  final String? description;
  final String? iconEmoji;

  const FishSpecies({
    required this.id,
    required this.standardName,
    this.scientificName,
    this.aliases = const [],
    required this.category,
    required this.rarity,
    this.habitat,
    this.behavior,
    this.fishingMethod,
    this.description,
    this.iconEmoji,
  });

  factory FishSpecies.fromMap(Map<String, dynamic> map) {
    return FishSpecies(
      id: map['id'] as String,
      standardName: map['standard_name'] as String,
      scientificName: map['scientific_name'] as String?,
      aliases: (map['aliases'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      category: FishCategory.fromValue(map['category'] as int? ?? 0),
      rarity: FishRarity.fromValue(map['rarity'] as int? ?? 1),
      habitat: map['habitat'] as String?,
      behavior: map['behavior'] as String?,
      fishingMethod: map['fishing_method'] as String?,
      description: map['description'] as String?,
      iconEmoji: map['icon_emoji'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'standard_name': standardName,
      'scientific_name': scientificName,
      'aliases': aliases.join(','),
      'category': category.value,
      'rarity': rarity.value,
      'habitat': habitat,
      'behavior': behavior,
      'fishing_method': fishingMethod,
      'description': description,
      'icon_emoji': iconEmoji,
    };
  }

  FishSpecies copyWith({
    String? id,
    String? standardName,
    String? scientificName,
    List<String>? aliases,
    FishCategory? category,
    FishRarity? rarity,
    String? habitat,
    String? behavior,
    String? fishingMethod,
    String? description,
    String? iconEmoji,
  }) {
    return FishSpecies(
      id: id ?? this.id,
      standardName: standardName ?? this.standardName,
      scientificName: scientificName ?? this.scientificName,
      aliases: aliases ?? this.aliases,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      habitat: habitat ?? this.habitat,
      behavior: behavior ?? this.behavior,
      fishingMethod: fishingMethod ?? this.fishingMethod,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishSpecies &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FishSpecies(id: $id, standardName: $standardName, rarity: ${rarity.label})';
  }
}
