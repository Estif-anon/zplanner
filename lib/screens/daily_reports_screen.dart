import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:z_planner/models/data_models.dart';

class DailyReports extends StatefulWidget {
  DailyReports({required this.tasks, super.key});
  final List<Task> tasks;

  @override
  State<DailyReports> createState() => _DailyReportsState();
}

class _DailyReportsState extends State<DailyReports> {
  int touchedIndex = -1;
  final SplayTreeSet<List<Task>> summarySet = SplayTreeSet(
    (list1, list2) => (list2[0].startingDate.day +
            (list2[0].startingDate.month * 30) +
            (list2[0].startingDate.year * 12))
        .compareTo(list1[0].startingDate.day +
            (list1[0].startingDate.month * 30) +
            (list1[0].startingDate.year * 12)),
            //because if we only used only the day to compare,
            // it would break when the month or the year changes.
  );

  void createSummary() {
    for (final task in widget.tasks) {
      final date = task.startingDate.day;
      final dateList = widget.tasks
          .where((element) => element.startingDate.day == date)
          .toList();
      summarySet.add(dateList);
    }
    //to create a summary chart for each day.
  }

  List<PieChartSectionData> showingSections(List<Task> tasks) {
    final localTasks = tasks.toList();
    final totalSeconds = tasks.fold(0,
        (previousValue, element) => previousValue + element.duration.inSeconds);
    final unaccountedFor = 86400 - totalSeconds;
    localTasks.add(
      Task(
        tag: Tag(color: Colors.grey, tagName: 'Unaccounted-for'),
        startingDate: tasks[0].startingDate,
        duration: Duration(seconds: unaccountedFor),
      ),
    );
    //24 hours is 86400 so the unaccounted-for in a day
    return List.generate(localTasks.length, (index) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 3)];
      return PieChartSectionData(
        color: localTasks[index].tag.color,
        value: localTasks[index].duration.inSeconds.toDouble(),
        title: '${(localTasks[index].duration.inSeconds / 86400) * 100} %',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }

  List<Widget> showDescriptions(List<Task> tasks) {
    final localTasks = tasks.toList();
    final totalSeconds = tasks.fold(0,
        (previousValue, element) => previousValue + element.duration.inSeconds);
    final unaccountedFor = 86400 - totalSeconds;
    localTasks.add(
      Task(
        tag: Tag(color: Colors.grey, tagName: 'Unaccounted-for'),
        startingDate: tasks[0].startingDate,
        duration: Duration(seconds: unaccountedFor),
      ),
    );
    return List.generate(localTasks.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 2),
        child: Row(
          children: [
            Container(
              height: 16,
              width: 16,
              color: localTasks[index].tag.color,
            ),
            const SizedBox(
              width: 3,
            ),
            Text(
              localTasks[index].tag.tagName,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryList = summarySet.toList();
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: summaryList.length,
        itemBuilder: (ctx, index) {
          return Container(
            color: Colors.transparent,
            child: AspectRatio(
              aspectRatio: 1.3,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    height: 18,
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: showingSections(summaryList[index]),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summaryList[index][0].formattedDate,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      ...showDescriptions(summaryList[index]),
                    ],
                  ),
                  const SizedBox(
                    width: 28,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
