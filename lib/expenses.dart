import 'dart:core' as prefix0;
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spensly/database_helpers.dart';
import 'package:spensly/expense_form.dart';


class Spensly extends StatefulWidget {
  const Spensly({
    Key key,
  }) : super(key: key);

  _SpenslyState createState() =>_SpenslyState();
}

class _SpenslyState extends State<Spensly> {
  List<Expense> _expenses = [];
  DatabaseHelper _db;

  @override
  initState() {
    super.initState();
    _db = DatabaseHelper.instance;
    getAllExpenses();
  }

  String totalSpent() {
    double totalAmount = 0;
    if (_expenses.length > 1) {
      List<double> amounts = _expenses.map((e) => e.amount).toList();
      totalAmount = amounts.reduce((value, element) => value + element);
    } else if (_expenses.length == 1) {
      totalAmount = _expenses[0].amount;
    }
    return totalAmount.toStringAsFixed(2);
  }

  String todayAmountSpent() {
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(seconds: 1));
    List<Expense> todayExpenses = _expenses.where((Expense e) => e.date.isAfter(yesterday)).toList();
    double todayAmount = 0;
    if (todayExpenses.length > 1) {
      List<double> todayAmounts = todayExpenses.map((e) => e.amount).toList();
      todayAmount = todayAmounts.reduce((value, element) => value + element);
    } else if (todayExpenses.length == 1) {
      todayAmount = todayExpenses[0].amount;
    }

    return todayAmount.toStringAsFixed(2);
  }

  void getAllExpenses() {
    debugPrint("type _db ${_db.runtimeType}");
    _db.queryAllExpenses().then((expenses) {
      debugPrint('expenses ${expenses.toString()}');
      setState(() {
        _expenses = sortExpenses(expenses);
      });
    });
  }

  List<Expense> sortExpenses(List<Expense> expenses) {
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  void addExpense(Expense expense) {
    // insert into db
    _db.insert(expense).then((id) {
      debugPrint('id ${id}');
      // set id on local object
      expense.id = id;
      // update state with new object
      List<Expense> expenses = _expenses;
      expenses.add(expense);
      setState(() {
        _expenses = sortExpenses(expenses);
      });
    });
  }

  void updateExpense(Expense expense, int index) {
    // update db
    _db.update(expense).then((int i) {
      // update local state
      List<Expense> expenses = _expenses;
      expenses[index] = expense; 
      setState(() {
        _expenses = sortExpenses(expenses);
      });
    });
  }

  void testCreateExpense() {
    Expense e = new Expense();
    e.name = 'Lunch';
    e.amount = 123.00;
    e.date = DateTime.utc(2018, 11, 10);
    e.vendor = "Wendy's";
    e.filed = false;
    e.category = expenseCategories['food']['value'];
    debugPrint("Expense ${e}");
    addExpense(e);
  }

  void submitForm(Expense expense, int index) {
    debugPrint('herer');
    if (expense.id == null) {
      // create expense
      addExpense(expense);
      debugPrint("created expense ${expense.name}");
    } else {
      // update expense
      updateExpense(expense, index);
      debugPrint("Updated expense ${expense.name}");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Today",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Roboto',
                          fontSize: 20
                        ),
                      ),
                      heightFactor: 2.0,
                    ),
                    Center(
                      child: Text(
                        todayAmountSpent(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Roboto',
                          fontSize: 40
                        ),
                      ),
                      heightFactor: 1.1,
                    ),
                  ]
                )
              ),
              Expanded(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "All Time",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Roboto',
                          fontSize: 20
                        ),
                      ),
                      heightFactor: 2.0,
                    ),
                    Center(
                      child: Text(
                        totalSpent(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Roboto',
                          fontSize: 40
                        ),
                      ),
                      heightFactor: 1.1,
                    ),
                  ]
                )
              ),
            ]
          ),
          _expenses.length > 0 ? Container(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 40, 0, 5),
              child: Text(DateFormat.yMMMMd("en_US").format(_expenses[1].date))
            ),
          ) : Text(''),
          Expanded(
            child: ListView.separated(
              itemCount: _expenses.length,
              separatorBuilder: (context, index) {
                final me = _expenses[index].date;
                final next = _expenses[index + 1].date;
                if (!(me.year == next.year && me.month == next.month && me.day == next.day)) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(15, 40, 0, 5),
                    child: Text(
                      DateFormat.yMMMMd("en_US").format(_expenses[index + 1].date))
                  );
                }
                return Divider(color: Colors.black45, indent: 15, endIndent: 15,);
              },
              itemBuilder: (BuildContext ctxt, int index) {
                return Dismissible(
                  background: Container(color: Colors.red),
                  // Each Dismissible must contain a Key. Keys allow Flutter to
                  // uniquely identify widgets.
                  key: Key(_expenses[index].id.toString()),
                  // Provide a function that tells the app
                  // what to do after an item has been swiped away.
                  onDismissed: (direction) async {
                    // Remove the item from the data source.
                    int removed = await _db.delete(_expenses[index].id);
                    if (removed > 0) {
                      setState(() {
                        _expenses.removeAt(index);
                      });
                    }
                  },
                  child: ListTile(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => ExpenseDialog(expense: _expenses[index], onSubmit: submitForm, index: index)
                    ),//createExpense(),,
                    leading: Icon(expenseCategories[_expenses[index].category]['icon']),
                    title: Text(_expenses[index].name),
                    subtitle: Text(_expenses[index].vendor),
                    trailing: Text("\$${_expenses[index].amount.toString()}"),
                  )
                );
              }
            )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => ExpenseDialog(expense: Expense(), onSubmit: submitForm,)
        ),//createExpense(),
        tooltip: 'Add Expense',
        child: Icon(Icons.add),
      ),
    );
  }
}