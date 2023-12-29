import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart' as syspath;
// import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:z_planner/models/data_models.dart';
import 'package:z_planner/screens/add_a_tag.dart';
import 'package:z_planner/screens/report_screen.dart';
import 'package:z_planner/widgets/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  
  Tag? currentTag;
  bool isRunning = false;
  bool isLoading = false;
  List<Tag> tags = [];
  
  List<Task> tasks = [];
  Task task = Task(
    tag: Tag(color: Colors.blueAccent, tagName: 'Sleep'),
    startingDate: DateTime.now(),
  );
  List<DailyGoal> goals = [];

  // Future<void> _launchUrl() async {
  //   if (!await launchUrl(Uri.parse('google.com'))) {
  //     throw Exception('couldn');
  //   }
  // }

  Future<Database> _getDatabase() async {
    final appDir = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(appDir, 'planner.db'),
        version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE Tags (id INTEGER PRIMARY KEY, tag_name TEXT, alpha INTEGER, red INTEGER, green INTEGER, blue INTEGER)');
      await db.execute(
          'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, tag_name TEXT, seconds INTEGER, minutes INTEGER, hours INTEGER, day INTEGER, month INTEGER, year INTEGER)');
      await db.execute(
          'CREATE TABLE Goals (id INTEGER PRIMARY KEY, tag_name TEXT, hours INTEGER, minutes INTEGER, seconds INTEGER, is_active INTEGER, active_days TEXT)');
      
    });
    return db;
  }

  void addDailyGoal(DailyGoal goal, int creationDate) async {
    goals.add(goal);
    final index = goals.indexOf(goal);
    goals[index].activeDays[creationDate] = goals[index].isActive;
    final db = await _getDatabase();
    final formattedActiveDays = goal.activeDays
        .map((key, value) => MapEntry(key.toString(), value.toString()));
    await db.insert('Goals', {
      'id': goals.indexOf(goal),
      'tag_name': goal.tag.tagName,
      'hours': goal.duration.inHours,
      'minutes': goal.duration.inMinutes,
      'seconds': goal.duration.inSeconds,
      'is_active': goal.isActive ? 1 : 0,
      'active_days': json.encode(formattedActiveDays),
    });
  }

  void changeGoalStatus(DailyGoal goal, int updatingDate, bool value) async {
    final index = goals.indexOf(goal);
    // goals[index].isActive = !goals[index].isActive;
    //TODO I realized isActive is only useful to the daily_goals_screen. we could've used bool as a parametel here.
    goals[index].activeDays[updatingDate] = value;
    //I may need to come back on this one TODO
    final formattedActiveDays = goal.activeDays
        .map((key, value) => MapEntry(key.toString(), value.toString()));

    final db = await _getDatabase();
    await db.update(
      'Goals',
      {
        'active_days': json.encode(formattedActiveDays),
      },
      where: 'id = ?',
      whereArgs: [
        goals.indexOf(goal),
      ],
    );
  }

  void addTag(Tag tag) async {
    setState(() {
      tags.add(tag);
    });
    onTagChanged(tag);

    final db = await _getDatabase();
    db.insert('Tags', {
      'id': tags.indexOf(tag),
      'tag_name': tag.tagName,
      'alpha': tag.color.alpha,
      'red': tag.color.red,
      'green': tag.color.green,
      'blue': tag.color.blue,
    });

    // final dbPath = await sql.getDatabasesPath();
    // final path = await syspath.getApplicationDocumentsDirectory();
    // final smt = path.path;
  }

  void onTagChanged(Tag? tag) async {
    if (tag == null) {
      return;
    }
    setState(() {
      currentTag = tag;
    });
    onStop();
    final previousTask = task;
    final temp = DateTime.now();
    //TODO don't use just the day, but the month and the year also.
    if (tasks.any((task) =>
        task.startingDate.day == temp.day &&
        task.tag.tagName == tag.tagName)) {
      setState(() {
        task = tasks.firstWhere((task) =>
            task.startingDate.day == temp.day &&
            task.tag.tagName == tag.tagName);
      });
    } else {
      setState(() {
        task = Task(tag: tag, startingDate: DateTime.now());
      });
      tasks.add(task);
      final db = await _getDatabase();
      await db.insert('Tasks', {
        'id': tasks.indexOf(task),
        'tag_name': task.tag.tagName,
        'seconds': task.duration.inSeconds,
        'minutes': task.duration.inMinutes,
        'hours': task.duration.inHours,
        'day': task.startingDate.day,
        'month': task.startingDate.month,
        'year': task.startingDate.year,
      });
      await db.update(
        'Tasks',
        {
          'seconds': previousTask.duration.inSeconds,
          'minutes': previousTask.duration.inMinutes,
          'hours': previousTask.duration.inHours,
        },
        where: 'id = ?',
        whereArgs: [tasks.indexOf(previousTask)],
      );
      //maybe do this before changing the task variable, incase the indexOf doensn't work with prev value
      //plus read the documentation of how we can construct the map
    }
  }

  void onStart(Tag? tag) {
    if (tag == null) {
      return;
    }
    //check if there is a tast in memory saved with the same day as Duration.now()

    // final
    //create a task with duration.zero, and the tag if there is no task with the same tag and day
    // if there is a task in the same day, resume that task (create the task with a duration of that or update the task's duration)
    //change the isRunning to true
    setState(() {
      isRunning = true;
    });
    final tempIndex = tasks.indexOf(task);
    addASecond(tasks[tempIndex]);
    // call on the duration counter (second adder)
  }

  void onStop() {
    setState(() {
      isRunning = false;
    });
    //change isRunning to false
  }

  void addASecond(Task task) async {
    while (isRunning) {
      await Future.delayed(const Duration(microseconds: 16666));
      setState(() {
        task.duration = task.duration + const Duration(microseconds: 16666);
      });
    }
  }

  @override
  void initState() async {
    super.initState();
    setState(() {
      isLoading = true;
    });
    final db = await _getDatabase();
    final tagsData = await db.query('Tags');
    final tagsList = tagsData.map((row) {
      final a = row['alpha'] as int;
      final r = row['red'] as int;
      final g = row['green'] as int;
      final b = row['blue'] as int;
      return Tag(
          color: Color.fromARGB(a, r, g, b),
          tagName: row['tag_name'] as String);
    }).toList();
    setState(() {
          tags = [...tagsList];
    });


    final tasksData = await db.query('Tasks');
    final tasksList = tasksData.map((row) {
      final tagName = row['tag_name'] as String;
      final tagColor =
          tags.firstWhere((element) => element.tagName == tagName).color;
      final tag = Tag(color: tagColor, tagName: tagName);
      final duration = Duration(
        hours: row['hours'] as int,
        minutes: (row['minutes'] as int) % 60,
        seconds: (row['seconds'] as int) % 60,
      );
      final startingDate =
          DateTime(row['year'] as int, row['month'] as int, row['day'] as int);

      return Task(tag: tag, startingDate: startingDate, duration: duration);
    }).toList();
    setState(() {
          tasks = [...tasksList];

    });
    // can we make this work while the lists tasks and tags are still finals, to improve performance?
    final goalsData = await db.query('Goals');
    final goalsList = await goalsData.map((row) {
      final tagName = row['tag_name'] as String;
      final tagColor =
          tags.firstWhere((element) => element.tagName == tagName).color;
      final tag = Tag(color: tagColor, tagName: tagName);
      final duration = Duration(
        hours: row['hours'] as int,
        minutes: (row['minutes'] as int) % 60,
        seconds: (row['seconds'] as int) % 60,
      );
      final isActive = row['is_active'] as int == 1 ? true : false;
      final tempGoal =
          DailyGoal(tag: tag, duration: duration, isActive: isActive);
      final Map<String, dynamic> activeDaysData =
          json.decode(row['active_days'] as String);
      final activeDays = activeDaysData.map(
        (key, value) => MapEntry(
          int.parse(key),
          bool.parse(value),
        ),
      );

      tempGoal.activeDays = activeDays;

      return tempGoal;
    }).toList();
    setState(() {
          goals = [...goalsList];

    });// I don't think I should set state for this one tho
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Z Planner'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ReportScreen(tasks: tasks, goals: goals),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                useSafeArea: true,

                // transitionAnimationController: AnimationController(vsync: this),
                context: context,
                builder: (ctx) => AddTag(
                  tags: tags,
                  addTag: addTag,
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: MainDrawer(
        addTag: addTag,
        addGoal: addDailyGoal,
        goals: goals,
        tags: tags,
        changeGoalStatus: changeGoalStatus,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: task.tag.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(15),
            child: Text(
              '${'${task.duration.inHours}'.padLeft(2, '0')}:${'${task.duration.inMinutes % 60}'.padLeft(2, '0')}:${'${task.duration.inSeconds % 60}'.padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 32,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isRunning
                    ? () {
                        setState(() {
                          onStop();
                        });
                      }
                    : () {
                        setState(() {
                          onStart(currentTag);
                        });
                      },
                icon: isRunning
                    ? const Icon(Icons.stop)
                    : const Icon(Icons.play_arrow),
                label: isRunning ? const Text('Stop') : const Text('Start'),
              ),
              DropdownButton(
                  dropdownColor: const Color.fromARGB(52, 0, 0, 0),
                  items: tags
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: e.color,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                e.tagName,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  value: currentTag,
                  onChanged: onTagChanged),
            ],
          ),
        ],
      ),
    );
  }
}
