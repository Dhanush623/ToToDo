import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/models/todo.dart';
import 'package:totodo/src/widgets/custom_elevated_button.dart';
import 'package:totodo/src/widgets/custom_icon_button.dart';

class CustomToDoItem extends StatelessWidget {
  const CustomToDoItem({
    super.key,
    required this.todo,
    required this.updateFunction,
    required this.deleteFunction,
    required this.bottomSheetFunction,
  });
  final Todo todo;
  final Function updateFunction;
  final Function deleteFunction;
  final Function bottomSheetFunction;

  void _showDeleteConfirmationDialog(BuildContext context, String? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            todo.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          content: const Text(
            Constants.deleteMessage,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                Constants.no,
              ),
            ),
            customElevatedButton(
              Constants.yes,
              () {
                Navigator.of(context).pop();
                deleteFunction(id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      value: todo.isFinished,
      onChanged: (bool? value) {
        updateFunction(
          value,
          todo.id,
        );
      },
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        todo.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        DateFormat(Constants.dateFormat).format(
          todo.createdOn!.toDate(),
        ),
      ),
      secondary: Wrap(
        children: [
          customIconButton(
            Icons.edit,
            Constants.edit,
            () => bottomSheetFunction(
              context,
              todo,
            ),
          ),
          customIconButton(
            Icons.delete,
            Constants.delete,
            () => _showDeleteConfirmationDialog(context, todo.id),
          )
        ],
      ),
    );
  }
}
