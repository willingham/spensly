import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spensly/database_helpers.dart';


class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    Key key,
    this.db,
    this.expenseIds,
    this.stateChanged,
  }) : super(key: key);

  final DatabaseHelper db;
  final List<int> expenseIds;
  final Function stateChanged;

  void markSubmitted(context) async {
    expenseIds.forEach((id) async {
      Expense expense = await db.queryExpense(id);
      expense.filed = true;
      db.update(expense);
    });
    stateChanged();
    Navigator.of(context).pop();
  }

  void delete(context) async {
    expenseIds.forEach((id) => db.delete(id));
    stateChanged();
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    int num = expenseIds.length;
    return AlertDialog(
      //contentPadding: EdgeInsets.all(0.0),
      title: Text('Update Expense${num == 1 ? "" : "s"}'),
      content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What would you like to do with ${num == 1 ? "this" : "these"} $num item${num == 1 ? "" : "s"}?'),
            RaisedButton(
              child: Text('Mark as Submitted'),
              onPressed: () => markSubmitted(context),
            ),
            RaisedButton(
              child: Text('Delete'),
              onPressed: () => delete(context),
            ),
            RaisedButton(
              child: Text('Do Nothing'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ]
        )
      
    );
  }
}