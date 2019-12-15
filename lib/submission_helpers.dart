import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:spensly/database_helpers.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:spensly/update_dialog.dart';


Future<String> createZipFile(String csvContents, List<File> imageFiles) async {
  final String dateString = DateFormat("yyyy-MM-dd-hh-mm-ss").format(DateTime.now());
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final temporaryDirectory = await getTemporaryDirectory();
  List<File> filesToZip = [];
  
  // write csv
  File csvFile = await File('${documentsDirectory.path}/tmp/$dateString.csv').create(recursive: true);
  csvFile = await csvFile.writeAsString(csvContents);
  filesToZip.add(csvFile);
  
  // get list of image file locations
  filesToZip += imageFiles;
  filesToZip.forEach((f) => debugPrint(f.path));

  // create zip
  final String zipFileName = '${temporaryDirectory.path}/spensly-$dateString.zip';
  var encoder = ZipFileEncoder();
  encoder.create(zipFileName);
  filesToZip.forEach((f) => encoder.addFile(f));
  encoder.close();

  // return zip filename
  return zipFileName;
}

void sendEmail(context) async {
  DatabaseHelper db = DatabaseHelper.instance;
  List<Expense> unsubmittedExpenses = await db.queryUnsubmittedExpenses();
  if (unsubmittedExpenses.length == 0) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text('No Expenses'),
        content: Text('No unsubmitted expenses available to send.'),
        actions: [
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    return;
  }
  List<int> unsubmittedExpenseIds = unsubmittedExpenses.map((e) => e.id).toList();
  
  String csvContents = await db.generateCsvString(unsubmittedExpenseIds);
  double totalRequestAmount = unsubmittedExpenses.map((e) => e.amount).reduce((value, element) => value + element);
  String emailSubject = "Expense Reimbursment Request";
  String emailBody = """
Hi,

Please find the receipts and itemization of my business expenses attached.  The total amount is \$$totalRequestAmount.

Thanks
""";

  // get image files
  final photoDirectory = await imageDirectory;
  List<File> imageFiles = unsubmittedExpenses.where((e) => e.filename != '').map((e) => File(join(photoDirectory, e.filename))).toList();
  String zipFilePath = await createZipFile(csvContents, imageFiles);
  debugPrint('zipFilePath $zipFilePath');

  final Email email = Email(
    body: emailBody,
    subject: emailSubject,
    recipients: [],
    cc: [],
    bcc: [],
    attachmentPath: zipFilePath,
  );

  await FlutterEmailSender.send(email);
  showDialog(
    context: context,
    child: UpdateDialog(db: db, expenseIds: unsubmittedExpenseIds)
  );

}
