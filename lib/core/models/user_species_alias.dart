/// 用户鱼种别名模型
///
/// 用于存储用户输入的鱼种别名与标准鱼种ID之间的映射关系。
/// 当用户输入一个非标准鱼种名称时，系统通过此表建立映射关系。
class UserSpeciesAlias {
  final int? id;
  final String userAlias; // 用户输入的名称
  final String speciesId; // 映射到的鱼种ID
  final DateTime createdAt; // 首次创建时间

  const UserSpeciesAlias({
    this.id,
    required this.userAlias,
    required this.speciesId,
    required this.createdAt,
  });

  factory UserSpeciesAlias.fromMap(Map<String, dynamic> map) {
    return UserSpeciesAlias(
      id: map['id'] as int?,
      userAlias: map['user_alias'] as String,
      speciesId: map['species_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_alias': userAlias,
      'species_id': speciesId,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  UserSpeciesAlias copyWith({
    int? id,
    String? userAlias,
    String? speciesId,
    DateTime? createdAt,
  }) {
    return UserSpeciesAlias(
      id: id ?? this.id,
      userAlias: userAlias ?? this.userAlias,
      speciesId: speciesId ?? this.speciesId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSpeciesAlias &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserSpeciesAlias(id: $id, userAlias: $userAlias, speciesId: $speciesId)';
  }
}
