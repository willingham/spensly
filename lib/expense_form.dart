import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spensly/camera.dart';
import 'package:spensly/database_helpers.dart';
import 'package:path/path.dart' show join;


import 'package:camera/camera.dart';



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
  File imageFile = null;  

  @override
  initState() {
    super.initState();
    if (expense.date == null) {
      expense.date = DateTime.now();
    }
    setImageFile();
  }

  void setImageFile() async {
    if (expense.filename != "") {
      final photoDirectory = await imageDirectory;
      setState(() {
        imageFile = File(join(photoDirectory, expense.filename));
      });
      
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

    void takePhoto() async {
      final cameras = await availableCameras();

      // Get a specific camera from the list of available cameras.
      final firstCamera = cameras.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(
            camera: firstCamera,
            onPhotoTaken: (filename) async {
              // @TODO: Check delete existing image if exists
              await setState(() =>
                  expense.filename = filename);
              setImageFile();

            },
          ),
        ),
      );               
    }

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

            // photo area
            GestureDetector(
              onTap: () => takePhoto(),
              child: Container(
                width: 100.0,
                height: 150.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Colors.redAccent,
                ),
                child: imageFile != null
                  ? Image.file(imageFile)
                  : Center(child: Icon(Icons.camera))
              )
            ),

            // create button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text("Create"),
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