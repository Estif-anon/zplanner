import 'package:flutter/material.dart';
import 'package:z_planner/models/data_models.dart';

class AddTag extends StatefulWidget {
  const AddTag({required this.addTag, required this.tags, super.key});
  final void Function(Tag tag) addTag;
  final List<Tag> tags;

  @override
  State<AddTag> createState() {
    return AddTagState();
  }
}

class AddTagState extends State<AddTag> {
  // final tagNameController = TextEditingController();
  String tagName = '';
  var tagColor = Colors.amberAccent;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              // controller: tagNameController,
              maxLength: 25,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
              decoration: InputDecoration(
                label: const Text('Tag Name'),
                counterStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a tag name';
                }
                return null;
              },
              onSaved: (value) {
                tagName = value!;
              },
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 70,
                  child: DropdownButtonFormField(dropdownColor: Color.fromARGB(85, 255, 255, 255),
                    value: tagColor,
                    items: Colors.accents
                        .map(
                          (e) => DropdownMenuItem<MaterialAccentColor>(
                            value: e,
                            child: Container(
                              width: 50,
                              height: 16,
                              color: e,
                            ),
                          ),
                        )
                        .toList(),
                    // isExpanded: true,
                    onChanged: (value) {
                      tagColor = value!;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      if (!widget.tags.any(
                          (element) => element.tagName == tagName.trim())) {
                        widget.addTag(
                          Tag(
                            color: tagColor,
                            tagName: tagName.trim(),
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
