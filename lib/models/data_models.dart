import 'package:flutter/material.dart';

class Tag {
  Tag({required this.color, required this.tagName});
  final Color color;
  final String tagName;
}

class Task {
  Task(
      {this.duration = Duration.zero,
      required this.tag,
      required this.startingDate});
  final DateTime startingDate;
  Duration duration;
  final Tag tag;

  String get formattedDuration {
    return '${'${duration.inHours}'.padLeft(2, '0')}:${'${duration.inMinutes % 60}'.padLeft(2, '0')}:${'${duration.inSeconds % 60}'.padLeft(2, '0')}';
  }

  String get formattedDate {
    return 'Date: ${startingDate.day}-${startingDate.month}-${startingDate.year}';
  }

  int get daysInInt {
    return (startingDate.day) + (startingDate.month * 30) + (startingDate.year *12);
  }
}

class DailyGoal {
  DailyGoal({required this.tag, required this.duration, this.placeHolder, this.isActive = true});
  final Duration duration;
  final DateTime? placeHolder;
  final Tag tag;
  bool isActive;
  Map<int, bool> activeDays = {};

  String get formattedDuration {
    final hours = duration.inHours == 0
        ? ''
        : duration.inHours == 1
            ? '${duration.inHours} hour'
            : '${duration.inHours} hours';
    final minutes = (duration.inMinutes % 60) == 0
        ? ''
        : '${duration.inMinutes % 60} minutes';
    final seconds = (duration.inSeconds % 60) == 0
        ? ''
        : '${duration.inSeconds % 60} seconds';

    return '$hours $minutes $seconds';
  }

  
}
