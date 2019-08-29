import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spensly/database_helpers.dart';


class ExpenseDialog extends StatefulWidget {
  const ExpenseDialog({
    Key key,
    this.onSubmit,
    this.expense,
  }) : super(key: key);

  final Function onSubmit;
  final Expense expense;

  @override
  _ExpenseDialogState createState() => _ExpenseDialogState(expense: expense);
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final Expense expense;
  _ExpenseDialogState({this.expense});

  @override
  initState() {
    super.initState();
    if (expense.date == null) {
      expense.date = DateTime.now();
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: expense.date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(9101));
        if (picked != null) 
          setState(() {
            expense.date = picked;
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
   child:  Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(DateFormat.yMMMMd("en_US").format(expense.date)),
                  Expanded(
                    child: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  )),
                ]
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: expense.name,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                onSaved: (val) {
                  setState(() =>
                      expense.name = val);
                }
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                
                initialValue: expense.amount.toString(),
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                onSaved: (val) {
                  setState(() =>
                      expense.amount = double.parse(val));
                }
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: expense.vendor,
                decoration: InputDecoration(
                  labelText: 'Vendor',
                ),
                onSaved: (val) {
                  setState(() =>
                      expense.vendor = val);
                }
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: expense.category,
                    items: expenseCategoryList.map((String category) {
                      return  DropdownMenuItem<String>(
                        value: category,
                        child: new Text(expenseCategories[category]['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() =>
                        expense.category = val);
                    },
                  )
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text("Submit"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    widget.onSubmit(expense);
                  }
                },
              ),
            )
          ],
        ),
      )
    ));
  }
}