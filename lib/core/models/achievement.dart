/// 成就等级
enum AchievementLevel {
  bronze,
  silver,
  gold,
  platinum;

  /// Display name (Chinese)
  String get label {
    switch (this) {
      case AchievementLevel.bronze:
        return '青铜';
      case AchievementLevel.silver:
        return '白银';
      case AchievementLevel.gold:
        return '黄金';
      case AchievementLevel.platinum:
        return '铂金';
    }
  }

  /// JSON serialization name (English)
  String get jsonName {
    switch (this) {
      case AchievementLevel.bronze:
        return 'bronze';
      case AchievementLevel.silver:
        return 'silver';
      case AchievementLevel.gold:
        return 'gold';
      case AchievementLevel.platinum:
        return 'platinum';
    }
  }

  static AchievementLevel fromJson(String value) {
    return AchievementLevel.values.firstWhere(
      (e) => e.jsonName == value || e.label == value,
      orElse: () => AchievementLevel.bronze,
    );
  }
}

/// 成就模型
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementLevel level;
  final String category;
  final int target;
  final int current;
  final DateTime? unlockedAt;
  final double progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.level,
    required this.category,
    required this.target,
    required this.current,
    this.unlockedAt,
    required this.progress,
  });

  bool get isUnlocked => current >= target;
  bool get isLocked => !isUnlocked;
  double get progressPercent {
    if (target == 0) return 0.0;
    return (current / target * 100).clamp(0, 100);
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementLevel? level,
    String? category,
    int? target,
    int? current,
    DateTime? unlockedAt,
    double? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      level: level ?? this.level,
      category: category ?? this.category,
      target: target ?? this.target,
      current: current ?? this.current,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'level': level.jsonName,
      'category': category,
      'target': target,
      'current': current,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      level: AchievementLevel.fromJson(json['level'] as String),
      category: json['category'] as String,
      target: json['target'] as int,
      current: json['current'] as int,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: (json['progress'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, current: $current, target: $target, isUnlocked: $isUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
