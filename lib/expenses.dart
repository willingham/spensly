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

  void createExpense() {
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

  void submitForm(Expense expense) {
    debugPrint('herer');
    if (expense.id == null) {
      // create expense
      addExpense(expense);
      debugPrint("created expense ${expense.name}");
    } else {
      // update expense
      debugPrint("Update expense not yet implemented");

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
                child: Center( 
                  heightFactor: 4.0,
                  child: Text('foo'))
              ),
              Expanded(
                child: Center( child: Text('bar'))
              )
            ]
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _expenses.length,
              separatorBuilder: (context, index) {
                final me = _expenses[index].date;
                final next = _expenses[index + 1].date;
                if (!(me.year == next.year && me.month == next.month && me.day == next.day)) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, 40, 0, 5),
                    child: Text(
                      DateFormat.yMMMMd("en_US").format(_expenses[index + 1].date))
                  );
                }
                return Divider(color: Colors.black);
              },
              itemBuilder: (BuildContext ctxt, int index) {
                return new ListTile(
                  leading: Icon(expenseCategories[_expenses[index].category]['icon']),
                  title: Text(_expenses[index].name),
                  subtitle: Text(_expenses[index].vendor),
                  trailing: Text("\$${_expenses[index].amount.toString()}"),
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