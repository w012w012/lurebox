/// 备份历史记录模型
///
/// 用于追踪和管理本地备份文件
class BackupHistory {
  final int? id;
  final String filePath;
  final String fileName;
  final BackupType backupType;
  final int fileSize;
  final int fishCount;
  final int equipmentCount;
  final int photoCount;
  final DateTime createdAt;

  const BackupHistory({
    this.id,
    required this.filePath,
    required this.fileName,
    required this.backupType,
    required this.fileSize,
    this.fishCount = 0,
    this.equipmentCount = 0,
    this.photoCount = 0,
    required this.createdAt,
  });

  /// 从 Map 创建 BackupHistory
  factory BackupHistory.fromMap(Map<String, dynamic> map) {
    return BackupHistory(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      backupType: BackupType.fromString(map['backup_type'] as String),
      fileSize: map['file_size'] as int,
      fishCount: map['fish_count'] as int? ?? 0,
      equipmentCount: map['equipment_count'] as int? ?? 0,
      photoCount: map['photo_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'file_name': fileName,
      'backup_type': backupType.value,
      'file_size': fileSize,
      'fish_count': fishCount,
      'equipment_count': equipmentCount,
      'photo_count': photoCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改指定字段
  BackupHistory copyWith({
    int? id,
    String? filePath,
    String? fileName,
    BackupType? backupType,
    int? fileSize,
    int? fishCount,
    int? equipmentCount,
    int? photoCount,
    DateTime? createdAt,
  }) {
    return BackupHistory(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      backupType: backupType ?? this.backupType,
      fileSize: fileSize ?? this.fileSize,
      fishCount: fishCount ?? this.fishCount,
      equipmentCount: equipmentCount ?? this.equipmentCount,
      photoCount: photoCount ?? this.photoCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 获取文件大小的人类可读格式
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 获取备份类型的显示名称
  String get typeLabel => backupType.label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupHistory &&
        other.id == id &&
        other.filePath == filePath;
  }

  @override
  int get hashCode => Object.hash(id, filePath);

  @override
  String toString() {
    return 'BackupHistory(id: $id, fileName: $fileName, type: ${backupType.label}, size: $formattedFileSize)';
  }
}

/// 备份类型枚举
enum BackupType {
  json('json', 'JSON 备份'),
  zipFull('zip_full', '完整备份'),
  zipDbOnly('zip_db', '仅数据库');

  final String value;
  final String label;

  const BackupType(this.value, this.label);

  static BackupType fromString(String value) {
    return BackupType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => BackupType.json,
    );
  }
}
