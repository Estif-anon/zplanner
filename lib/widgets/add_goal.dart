import 'package:flutter/material.dart';
import 'package:z_planner/models/data_models.dart';
import 'package:z_planner/screens/add_a_tag.dart';

class AddGoal extends StatefulWidget {
  const AddGoal({
    super.key,
    required this.addDailyGoal,
    required this.tags,
    required this.addTag,
  });

  final void Function(DailyGoal goal) addDailyGoal;
  final List<Tag> tags;
  final void Function(Tag tag) addTag;
  @override
  State<AddGoal> createState() {
    return AddGoalState();
  }
}

class AddGoalState extends State<AddGoal> {
  Tag? _currentTag;
  bool isValid = true;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  final _formKey = GlobalKey<FormState>();
  final List<Tag> tags = [];

  void addLocalTag(Tag tag) {
    setState(() {
      tags.add(tag);
      _currentTag = tag;
    });
    widget.addTag(tag);
  }

  bool onSaveGoal() {
    _formKey.currentState!.save();
    if (hours == 0 && minutes == 0 && seconds == 0) {
      setState(() {
        isValid = false;
      });
    }

    if (_formKey.currentState!.validate()) {
      widget.addDailyGoal(
        DailyGoal(
          tag: _currentTag!,
          duration: Duration(hours: hours, minutes: minutes, seconds: seconds),
        ),
      );
      return true;
    }
    setState(() {
      isValid = true;
    });
    return false;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      tags.addAll(widget.tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 12,
      ),
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Add a Goal',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField(
                  validator: (value) {
                    if (value == null) {
                      return 'select a tag';
                    }
                    return null;
                  },
                  decoration:
                      const InputDecoration(label: Text('Select a Tag')),
                  dropdownColor: Colors.black54,
                  value: _currentTag,
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
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _currentTag = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    useSafeArea: true,

                    // transitionAnimationController: AnimationController(vsync: this),
                    context: context,
                    builder: (ct) => AddTag(
                      tags: widget.tags,
                      addTag: addLocalTag,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add a new tag'),
              ),
              SizedBox(
                width: 190,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('Hour'),
                        ),
                        validator: (value) {
                          if (!isValid) {
                            return 'Please';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (value != null) {
                            hours = int.tryParse(value) ?? 0;
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('Minute'),
                        ),
                        validator: (value) {
                          if (!isValid) {
                            return 'enter a';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (value != null) {
                            minutes = int.tryParse(value) ?? 0;
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('Second'),
                        ),
                        validator: (value) {
                          if (!isValid) {
                            return 'duration.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (value != null) {
                            seconds = int.tryParse(value) ?? 0;
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              ElevatedButton(
                onPressed: () {
                  if (onSaveGoal()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
