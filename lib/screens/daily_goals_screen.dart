import 'package:flutter/material.dart';
import 'package:z_planner/models/data_models.dart';
// import 'package:z_planner/screens/add_a_tag.dart';
import 'package:z_planner/widgets/add_goal.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({
    super.key,
    required this.addDailyGoal,
    required this.goals,
    required this.tags,
    required this.addTag,
    required this.changeGoalStatus,
  });

  final List<DailyGoal> goals;
  final void Function(DailyGoal goal, int creationDate) addDailyGoal;
  final List<Tag> tags;
  final void Function(Tag tag) addTag;
  final void Function(DailyGoal goal, int updatingDate, bool value)
      changeGoalStatus;

  @override
  State<DailyGoalsScreen> createState() {
    return _DailyGoalsScreenState();
  }
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  final List<DailyGoal> localGoals = [];
  void localGoalStatusHandler(DailyGoal goal, int index, bool value) {
    setState(() {
      localGoals[index].isActive = value;
    });
    final updatingDate =
        DateTime.now().day + DateTime.now().month * 30 + DateTime.now().year;

    widget.changeGoalStatus(goal, updatingDate, value);
  }

  void addLocalGoal(DailyGoal goal) {
    setState(() {
      localGoals.add(goal);
    });
    final creationDate =
        DateTime.now().day + DateTime.now().month * 30 + DateTime.now().year;
    widget.addDailyGoal(goal, creationDate);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      localGoals.addAll(widget.goals);
    });
  }

  @override
  Widget build(BuildContext context) {
    final goals = localGoals.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Goals'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  useSafeArea: true,
                  context: context,
                  builder: (ctx) => AddGoal(
                      addDailyGoal: addLocalGoal,
                      tags: widget.tags,
                      addTag: widget.addTag));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: goals.length,
          itemBuilder: (ctx, index) {
            return SwitchListTile(
              value: goals[index].isActive,
              onChanged: (value) {
                localGoalStatusHandler(
                  goals[index],
                  localGoals.indexOf(
                    goals[index],
                  ),
                  value,
                );
              },
              secondary: Container(
                height: 25,
                width: 25,
                color: goals[index].tag.color,
              ),
              title: Text(goals[index].tag.tagName),
              subtitle: Text('Plan: ${goals[index].formattedDuration} a day.'),
            );
          },
        ),
      ),
    );
  }
}
