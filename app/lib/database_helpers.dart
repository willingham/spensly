import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

Future<String> get imageDirectory async {
  final String directory = "expenses";
  final documentsDirectory = await getApplicationDocumentsDirectory();
  return join(documentsDirectory.path, directory);
}



final expenseCategories = {
  'lodging': {
    'icon': Icons.hotel,
    'name': 'Lodging',
    'value': 'lodging'
  },
  'food': {
    'icon': Icons.fastfood,
    'name': 'Food & Beverage',
    'value': 'food'
  },
  'transportation': {
    'icon': Icons.directions_car,
    'name': 'Transportation',
    'value': 'transportation'
  },
  'training': {
    'icon': Icons.school,
    'name': 'Training',
    'value': 'training'
  },
  'supplies': {
    'icon': Icons.folder,
    'name': 'Supplies',
    'value': 'supplies'
  },
  'other': {
    'icon': Icons.live_help,
    'name': 'Other',
    'value': 'other'
  },
};

final expenseCategoryList = expenseCategories.keys;


// database table and column names
final String tableExpense = 'expense';
final String columnId = '_id';
final String columnName = 'name';
final String columnVendor = 'vendor';
final String columnAmount = 'amount';
final String columnDate = 'date';
final String columnFilename = 'filename';
final String columnFiled = 'filed';
final String columnCategory = 'category';

// data model class
class Expense {

  int id;
  String name = "";
  String vendor = "";
  double amount = 0.0;
  DateTime date = DateTime.now();
  String filename = "";
  bool filed = false;
  String category = "other";

  Expense();

  // convenience constructor to create a Expense object
  Expense.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    vendor = map[columnVendor];
    amount = map[columnAmount];
    date = DateTime.fromMillisecondsSinceEpoch(map[columnDate]);
    filename = map[columnFilename];
    filed = map[columnFiled] == 0 ? false : true;
    category = map[columnCategory];
  }

  // convenience method to create a Map from this Expense object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnVendor: vendor,
      columnAmount: amount.toString(),
      columnDate: date.millisecondsSinceEpoch,
      columnFilename: filename,
      columnFiled: filed,
      columnCategory: category
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {

  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "Spensly.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL string to create the database 
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableExpense (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnVendor TEXT,
            $columnAmount REAL NOT NULL,
            $columnDate INTEGER NOT NULL,
            $columnFilename TEXT,
            $columnFiled Integer NOT NULL,
            $columnCategory TEXT NOT NULL
          )
          ''');
  }

  // Database helper methods:

  Future<int> insert(Expense expense) async {
    Database db = await database;
    int id = await db.insert(tableExpense, expense.toMap());
    return id;
  }

  Future<Expense> queryExpense(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableExpense,
        columns: [columnId, columnName, columnAmount, columnDate, columnVendor, columnFilename, columnFiled, columnCategory],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Expense>> queryAllExpenses() async {
    Database db = await database;
    List<Map> maps = await db.query(tableExpense,
        columns: [columnId, columnName, columnAmount, columnDate, columnVendor, columnFilename, columnFiled, columnCategory],
    );
    if (maps.length > 0) {
      return maps.map((data) => Expense.fromMap(data)).toList();
    }
    return [];
  }

  Future<List<Expense>> queryUnsubmittedExpenses() async {
    List<Expense> expenses = await queryAllExpenses();
    return expenses.where((e) => !e.filed).toList();
  }

  Future<int> delete(int id) async {
    Database db = await database;
    int numDeleted = await db.delete(tableExpense,
         where: '$columnId = ?', whereArgs: [id]
    );
    return numDeleted;
  }

  Future<int> update(Expense expense) async {
    Database db = await database;
    return await db.update(tableExpense, expense.toMap(),
        where: '$columnId = ?', whereArgs: [expense.id]);
  }

  Future<String> generateCsvString(ids) async {
    Database db = await database;
    List<String> columnsToInclude = [columnName, columnAmount, columnDate, columnVendor, columnFilename, columnCategory];
    debugPrint(ids.join(','));
    List<Map> maps = await db.query(tableExpense,
        columns: columnsToInclude,
        where: '$columnId IN (${ids.join(', ')})');

    
    double totalAmount = 0;
    List<List<dynamic>> data = [];

    // add header row
    data.add(columnsToInclude);

    // add value rows
    maps.forEach((e) {
      totalAmount += e[columnAmount];
      data.add(columnsToInclude.map((c) {
        if (c == columnFilename) {
          return basename(e[c]);
        }
        return e[c];
      }).toList());
    });

    // add total row
    data.add(["Total Amount: ${totalAmount.toString()}"]);

    String csv = const ListToCsvConverter().convert(data);

    //debugPrint(csv);
    return csv;
  }
}