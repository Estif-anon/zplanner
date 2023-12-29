import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:z_planner/models/data_models.dart';

class GoalReports extends StatefulWidget {
  const GoalReports({required this.goals, required this.tasks, super.key});
  final List<DailyGoal> goals;
  final List<Task> tasks;

  @override
  State<GoalReports> createState() => _GoalReportsState();
}

class _GoalReportsState extends State<GoalReports> {
  List<int> listOfDays = [];

  //but first a list of dates to be built
  //A function that will get me the list of goals given the date
  List<DailyGoal> getListOfGoals(int activeDay, List<DailyGoal> goals) {
    final filteredList =
        goals.where((goal) => goal.activeDays[activeDay] == true).toList();
    return filteredList;
  }

  // A function that will get me the task given the tag name and the date
  Task getTheTask(int date, String tagName) {
    final task = widget.tasks.firstWhere(
        (task) => task.daysInInt == date && task.tag.tagName == tagName);
    return task;
  }

  BarChartGroupData generateBarGroup(
    int x,
    Color color,
    double goalValue,
    double taskValue,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: goalValue,
          color: color.withOpacity(0.45),
          width: 10,
        ),
        BarChartRodData(
          toY: taskValue,
          color: color.withOpacity(0.99),
          width: 10,
        ),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0] : [],
    );
  }

  String getFormattedToolTipData(int goalSecondsinInt, int taskSecondsinInt) {
    final goalDuration = Duration(seconds: goalSecondsinInt);
    final taskDuration = Duration(seconds: taskSecondsinInt);

    final goalhours = goalDuration.inHours == 0
        ? ''
        : goalDuration.inHours == 1
            ? '${goalDuration.inHours} hour'
            : '${goalDuration.inHours} hours';
    final goalminutes = (goalDuration.inMinutes % 60) == 0
        ? ''
        : '${goalDuration.inMinutes % 60} minutes';
    final goalseconds = (goalDuration.inSeconds % 60) == 0
        ? ''
        : '${goalDuration.inSeconds % 60} seconds';

    final taskhours = taskDuration.inHours == 0
        ? ''
        : taskDuration.inHours == 1
            ? '${taskDuration.inHours} hour'
            : '${taskDuration.inHours} hours';
    final taskminutes = (taskDuration.inMinutes % 60) == 0
        ? ''
        : '${taskDuration.inMinutes % 60} minutes';
    final taskseconds = (taskDuration.inSeconds % 60) == 0
        ? ''
        : '${taskDuration.inSeconds % 60} seconds';
    return 'Goal: $goalhours $goalminutes $goalseconds \n Achieved: $taskhours $taskminutes $taskseconds';
  }

  int touchedGroupIndex = -1;
  //or a function that will get me a list of tasks that correspond with the list of goals

  @override
  void initState() {
    super.initState();
    for (final goal in widget.goals) {
      final days = goal.activeDays.keys;
      listOfDays.addAll(days);
    }
  }

  @override
  Widget build(BuildContext context) {
    // listOfDays.sort((a,b) => b.compareTo(a));
    final SplayTreeSet<int> setOfDays =
        SplayTreeSet.from(listOfDays, (a, b) => b.compareTo(a));
    final sortedListOfDays = setOfDays.toList();

    return ListView.builder(
      itemCount: sortedListOfDays.length,
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                borderData: FlBorderData(
                  show: true,
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        final goalTag = getListOfGoals(
                                sortedListOfDays[index], widget.goals)[i]
                            .tag;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            goalTag.tagName,
                            style: TextStyle(
                              color: goalTag.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                gridData: const FlGridData(
                  show: false,
                  drawVerticalLine: false,
                  drawHorizontalLine: false,
                ),
                barGroups: getListOfGoals(sortedListOfDays[index], widget.goals)
                    .asMap()
                    .entries
                    .map((e) {
                  final index = e.key;
                  final goal = e.value;
                  final task =
                      getTheTask(sortedListOfDays[index], goal.tag.tagName);
                  return generateBarGroup(
                      index,
                      goal.tag.color,
                      goal.duration.inSeconds.toDouble(),
                      task.duration.inSeconds.toDouble());
                }).toList(),
                maxY: 20,
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent,
                    tooltipMargin: 0,
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      final goalData = group.barRods[0];
                      final taskData = group.barRods[1];
                      return BarTooltipItem(
                        getFormattedToolTipData(
                            goalData.toY.toInt(), taskData.toY.toInt()),
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rod.color,
                          fontSize: 15,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 12,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions &&
                        response != null &&
                        response.spot != null) {
                      setState(() {
                        touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                      });
                    } else {
                      setState(() {
                        touchedGroupIndex = -1;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
