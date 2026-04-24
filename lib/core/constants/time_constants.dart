/// Time range constants for statistical queries (morning, night periods).
class TimeConstants {
  TimeConstants._();

  /// Morning period start hour (5 AM, in 'HH' format for SQL strftime).
  static const String morningStart = '05';

  /// Morning period end hour (9 AM, in 'HH' format for SQL strftime).
  static const String morningEnd = '09';

  /// Night period start hour (8 PM, in 'HH' format for SQL strftime).
  static const String nightStart = '20';

  /// Night period end hour (5 AM, in 'HH' format for SQL strftime).
  static const String nightEnd = '05';
}
