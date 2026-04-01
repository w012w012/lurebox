/// 鱼种历史记录数据模型
///
/// 定义了用户曾经使用过的鱼种的历史记录。
/// 用于：
/// - 记录用户输入过的鱼种
/// - 统计各鱼种的使用频次
/// - 在添加新渔获时提供鱼种 autocomplete 推荐
///
/// 字段说明：
/// - id: 历史记录唯一标识
/// - name: 鱼种名称（用户输入的原始文本）
/// - useCount: 使用次数（每次渔获记录都会增加）
/// - isDeleted: 逻辑删除标记
/// - createdAt: 首次添加的时间
///
/// 设计特点：
/// - 使用 useCount 字段支持按使用频率排序
/// - 支持逻辑删除（保留历史数据）
/// - 每次用户输入新鱼种时创建记录或增加计数
///
/// 典型用途：
/// - 渔获录入时的鱼种自动补全
/// - 鱼种使用统计
/// - 热门鱼种推荐

class SpeciesHistory {
  final int id;
  final String name;
  final int useCount;
  final bool isDeleted;
  final DateTime createdAt;

  const SpeciesHistory({
    required this.id,
    required this.name,
    required this.useCount,
    this.isDeleted = false,
    required this.createdAt,
  });

  factory SpeciesHistory.fromMap(Map<String, dynamic> map) {
    return SpeciesHistory(
      id: map['id'] as int,
      name: map['name'] as String,
      useCount: map['use_count'] as int? ?? 1,
      isDeleted: map['is_deleted'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'use_count': useCount,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SpeciesHistory copyWith({
    int? id,
    String? name,
    int? useCount,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return SpeciesHistory(
      id: id ?? this.id,
      name: name ?? this.name,
      useCount: useCount ?? this.useCount,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeciesHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SpeciesHistory(id: $id, name: $name, useCount: $useCount, isDeleted: $isDeleted)';
  }
}
