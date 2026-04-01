/// 日期格式
class DateFormats {
  static const String dateTime = 'yyyy-MM-dd HH:mm';
  static const String date = 'yyyy-MM-dd';
  static const String time = 'HH:mm';
}

/// 鱼竿分类
class RodCategory {
  static const String general = 'general';
  static const String longCast = 'longCast';
  static const String lightGame = 'lightGame';
  static const String frog = 'frog';
  static const String jigging = 'jigging';
  static const String octopus = 'octopus';

  static const List<String> all = [
    general,
    longCast,
    lightGame,
    frog,
    jigging,
    octopus,
  ];

  static String getName(String category) {
    switch (category) {
      case general:
        return '泛用';
      case longCast:
        return '远投';
      case lightGame:
        return '微物';
      case frog:
        return '雷强';
      case jigging:
        return '铁板/慢摇';
      case octopus:
        return '章鱼/墨鱼';
      default:
        return category;
    }
  }
}

/// 渔轮分类
class ReelCategory {
  static const String general = 'general';
  static const String longCast = 'longCast';
  static const String lightGame = 'lightGame';
  static const String frog = 'frog';
  static const String jigging = 'jigging';
  static const String baitcasting = 'baitcasting';
  static const String spinning = 'spinning';

  static const List<String> all = [
    general,
    longCast,
    lightGame,
    frog,
    jigging,
    baitcasting,
    spinning,
  ];

  static String getName(String category) {
    switch (category) {
      case general:
        return '泛用';
      case longCast:
        return '远投';
      case lightGame:
        return '微物';
      case frog:
        return '雷强';
      case jigging:
        return '铁板/慢摇';
      case baitcasting:
        return '水滴轮';
      case spinning:
        return '纺车轮';
      default:
        return category;
    }
  }
}
