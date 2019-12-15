import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spensly/camera.dart';
import 'package:spensly/database_helpers.dart';
import 'package:path/path.dart' show join;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';


import 'package:camera/camera.dart';



class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    Key key,
    this.db,
    this.expenseIds,
  }) : super(key: key);

  final DatabaseHelper db;
  final List<int> expenseIds;

  void markSubmitted(context) async {
    expenseIds.forEach((id) async {
      Expense expense = await db.queryExpense(id);
      expense.filed = true;
      db.update(expense);
    });
    Navigator.of(context).pop();
    // @TODO Force reload after return to home
  }

  void delete(context) async {
    expenseIds.forEach((id) => db.delete(id));
    Navigator.of(context).pop();
    // @TODO Force reload after return to home

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