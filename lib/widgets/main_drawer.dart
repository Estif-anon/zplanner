import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:z_planner/models/data_models.dart';
import 'package:z_planner/screens/about_screen.dart';
import 'package:z_planner/screens/add_a_tag.dart';
import 'package:z_planner/screens/daily_goals_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({
    super.key,
    required this.addTag,
    required this.addGoal,
    required this.goals,
    required this.tags,
    required this.changeGoalStatus,
  });

  final void Function(Tag tag) addTag;
  final void Function(DailyGoal goal, int creationDate) addGoal;
  final List<DailyGoal> goals;
  final List<Tag> tags;
  final void Function(DailyGoal goal, int updatingDate, bool value) changeGoalStatus;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.av_timer,
                  size: 42,
                ),
                const SizedBox(
                  width: 14,
                ),
                Text(
                  'Z Planner',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 40,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.add_box,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Add a Tag',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Add a Tag'),
                  ),
                  body: AddTag(addTag: addTag, tags: tags),
                );
              }));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.add_to_photos_sharp,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Add a Task',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.check_box,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Daily Goals',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => DailyGoalsScreen(
                    changeGoalStatus: changeGoalStatus,
                    addDailyGoal: addGoal,
                    goals: goals,
                    tags: tags,
                    addTag: addTag,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.app_shortcut,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Other Apps',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              if (await url_launcher.canLaunchUrl(
                Uri.parse('https://t.me/zanonism'),
              )) {
                await url_launcher.launchUrl(
                  Uri.parse('https://t.me/zanonism'),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'About',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
