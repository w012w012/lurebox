/// 鱼种别名相关异常
class SpeciesAliasException implements Exception {
  final String message;
  final String? operation;
  final dynamic cause;

  const SpeciesAliasException({
    required this.message,
    this.operation,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SpeciesAliasException: $message');
    if (operation != null) {
      buffer.write(' (operation: $operation)');
    }
    if (cause != null) {
      buffer.write(' - caused by: $cause');
    }
    return buffer.toString();
  }
}
