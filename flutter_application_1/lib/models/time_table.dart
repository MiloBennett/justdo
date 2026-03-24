// 节次时间类
class SectionTime {
  final int section;
  final String startTime;
  final String endTime;

  const SectionTime({
    required this.section,
    required this.startTime,
    required this.endTime,
  });

  SectionTime copyWith({int? section, String? startTime, String? endTime}) {
    return SectionTime(
      section: section ?? this.section,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

// 默认时间表
class DefaultTimeTable {
  static const List<SectionTime> sections = [
    SectionTime(section: 1, startTime: '08:00', endTime: '08:45'),
    SectionTime(section: 2, startTime: '08:55', endTime: '09:40'),
    SectionTime(section: 3, startTime: '10:00', endTime: '10:45'),
    SectionTime(section: 4, startTime: '10:55', endTime: '11:40'),
    SectionTime(section: 5, startTime: '14:00', endTime: '14:45'),
    SectionTime(section: 6, startTime: '14:55', endTime: '15:40'),
    SectionTime(section: 7, startTime: '16:00', endTime: '16:45'),
    SectionTime(section: 8, startTime: '16:55', endTime: '17:40'),
    SectionTime(section: 9, startTime: '19:00', endTime: '19:45'),
    SectionTime(section: 10, startTime: '19:55', endTime: '20:40'),
    SectionTime(section: 11, startTime: '20:50', endTime: '21:35'),
    SectionTime(section: 12, startTime: '21:45', endTime: '22:30'),
  ];

  // 获取指定节次的开始时间
  static String getStartTime(int section) {
    if (section < 1 || section > sections.length) {
      return '08:00';
    }
    return sections[section - 1].startTime;
  }

  // 获取指定节次的结束时间
  static String getEndTime(int section) {
    if (section < 1 || section > sections.length) {
      return '08:45';
    }
    return sections[section - 1].endTime;
  }

  // 获取指定节次范围的时间文本
  static String getTimeRange(int startSection, int endSection) {
    final startTime = getStartTime(startSection);
    final endTime = getEndTime(endSection);
    return '$startTime-$endTime';
  }
}

// 用户自定义时间表
class CustomTimeTable {
  final List<SectionTime> sections;

  CustomTimeTable({List<SectionTime>? sections})
    : sections = sections ?? List.from(DefaultTimeTable.sections);

  // 获取指定节次的开始时间
  String getStartTime(int section) {
    final item = sections.where((s) => s.section == section).firstOrNull;
    return item?.startTime ?? DefaultTimeTable.getStartTime(section);
  }

  // 获取指定节次的结束时间
  String getEndTime(int section) {
    final item = sections.where((s) => s.section == section).firstOrNull;
    return item?.endTime ?? DefaultTimeTable.getEndTime(section);
  }

  // 获取指定节次范围的时间文本
  String getTimeRange(int startSection, int endSection) {
    final startTime = getStartTime(startSection);
    final endTime = getEndTime(endSection);
    return '$startTime-$endTime';
  }

  // 更新指定节次的时间
  CustomTimeTable updateSection(int section, String startTime, String endTime) {
    final newSections = sections.map((s) {
      if (s.section == section) {
        return SectionTime(
          section: section,
          startTime: startTime,
          endTime: endTime,
        );
      }
      return s;
    }).toList();
    return CustomTimeTable(sections: newSections);
  }

  // 重置为默认时间表
  CustomTimeTable reset() {
    return CustomTimeTable();
  }
}
