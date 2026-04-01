import 'dart:convert';

/// 云备份配置模型
///
/// 支持多种云存储提供商：WebDAV、Nextcloud、OwnCloud 等
class CloudConfig {
  final int? id;
  final CloudProvider provider;
  final String serverUrl;
  final String username;
  final String password;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CloudConfig({
    this.id,
    required this.provider,
    required this.serverUrl,
    required this.username,
    required this.password,
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Map 创建 CloudConfig
  factory CloudConfig.fromMap(Map<String, dynamic> map) {
    return CloudConfig(
      id: map['id'] as int?,
      provider: CloudProvider.fromString(map['provider'] as String),
      serverUrl: map['server_url'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider': provider.value,
      'server_url': serverUrl,
      'username': username,
      'password': password,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改指定字段
  CloudConfig copyWith({
    int? id,
    CloudProvider? provider,
    String? serverUrl,
    String? username,
    String? password,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CloudConfig(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 转换为 JSON 字符串（用于安全存储）
  String toJson() => jsonEncode(toMap()..remove('password'));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CloudConfig &&
        other.id == id &&
        other.provider == provider &&
        other.serverUrl == serverUrl &&
        other.username == username &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, provider, serverUrl, username, isActive);

  @override
  String toString() {
    return 'CloudConfig(id: $id, provider: ${provider.label}, serverUrl: $serverUrl, username: $username, isActive: $isActive)';
  }
}

/// 云存储提供商枚举
enum CloudProvider {
  webdav('webdav', 'WebDAV'),
  nextcloud('nextcloud', 'Nextcloud'),
  owncloud('owncloud', 'OwnCloud');

  final String value;
  final String label;

  const CloudProvider(this.value, this.label);

  static CloudProvider fromString(String value) {
    return CloudProvider.values.firstWhere(
      (p) => p.value == value,
      orElse: () => CloudProvider.webdav,
    );
  }
}
