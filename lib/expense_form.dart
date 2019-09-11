import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spensly/camera.dart';
import 'package:spensly/database_helpers.dart';
import 'package:path/path.dart' show join;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';


import 'package:camera/camera.dart';



class ExpenseDialog extends StatefulWidget {
  const ExpenseDialog({
    Key key,
    this.onSubmit,
    this.expense,
    this.index,
  }) : super(key: key);

  final Function onSubmit;
  final Expense expense;
  final int index;

  @override
  _ExpenseDialogState createState() => _ExpenseDialogState(expense: expense);
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final Expense expense;
  _ExpenseDialogState({this.expense});
  File imageFile = null; 
  String _category = ''; 

  FocusNode name = new FocusNode();
  FocusNode amount = new FocusNode();
  FocusNode vendor = new FocusNode();

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
        child: Container(
          width: double.maxFinite,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            shrinkWrap: true,
            children: <Widget>[
              DateTimeField(
                initialValue: expense.date,
                enableInteractiveSelection: false,
                readOnly: true,
                resetIcon: null,
                format: DateFormat('MM/dd/yyyy'),
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Date',
                ),
                onChanged: (picked) {
                  setState(() =>
                    expense.date = picked);
                },
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: expense.date ?? DateTime.now(),
                      lastDate: DateTime(2100));
                },
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                initialValue: expense.name,
                decoration: InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: 'Name',
                ),
                onSaved: (val) {
                  setState(() =>
                      expense.name = val);
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term){
                  // process
                }
              ),
              TextFormField(
                initialValue: expense.amount.toString(),
                decoration: InputDecoration(
                  icon: Icon(Icons.attach_money),
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  setState(() =>
                      expense.amount = double.parse(val));
                },
                onFieldSubmitted: (term){
                  // process
                },
                textInputAction: TextInputAction.next
              ),
              TextFormField(
                initialValue: expense.vendor,
                decoration: InputDecoration(
                  icon: Icon(Icons.store),
                  labelText: 'Vendor',
                ),
                onSaved: (val) {
                  setState(() =>
                      expense.vendor = val);
                },
                onFieldSubmitted: (term){
                  // process
                },
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next
              ),
              FormField(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: Icon(Icons.category),
                      labelText: 'Category',
                    ),
                    isEmpty: expense.category == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
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
                    )
                  );
                }
              ),

              // submitted / filed
              CheckboxListTile(
                title: Text('Already Submitted'),
                value: expense.filed,
                onChanged: (val) {
                  setState(() =>
                      expense.filed = val);
                }
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
                  child: expense.id == null ? Text("Create") : Text("Update"),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      widget.onSubmit(expense, widget.index);
                      Navigator.pop(context);
                    }
                  },
                ),
              )
            ],
          ),
        )
      )
    );
  }
}