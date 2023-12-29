
import 'package:flutter/material.dart';
import 'package:z_planner/models/data_models.dart';
// import 'package:fl_chart/fl_char';
import 'package:fl_chart/fl_chart.dart';
import 'package:z_planner/screens/daily_reports_screen.dart';
import 'package:z_planner/screens/goal_reports_screen.dart';

class ReportScreen extends StatelessWidget {
  ReportScreen({required this.tasks,required this.goals, super.key});
  final List<Task> tasks;
  final List<DailyGoal> goals;
  

  final chart = PieChart(PieChartData());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(
                text: 'Daily Reports',
              ),
              Tab(
                text: 'Goal Reports',
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          DailyReports(tasks: tasks),
          GoalReports(goals: goals,tasks: tasks),
        ]),
      ),
    );
  }
}
