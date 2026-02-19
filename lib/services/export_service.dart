import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

import '../models/transaction.dart';

class ExportService {
  static Future<void> exportToCSV(List<Transaction> transactions) async {
    List<List<dynamic>> rows = [];

    // Header row
    rows.add(["ID", "Date", "Title", "Type", "Amount", "Description", "Items"]);

    for (var tx in transactions) {
      String goodsStr = tx.goods?.map((g) => "${g.name}(${g.quantity})").join(" | ") ?? "";

      List<dynamic> row = [];
      row.add(tx.id);
      row.add(DateFormat('yyyy-MM-dd').format(tx.date));
      row.add(tx.title);
      row.add(tx.type.name);
      row.add(tx.amount);
      row.add(tx.desc ?? "");
      row.add(goodsStr);
      rows.add(row);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    // ফাইল সেভ করার লজিক (Android/iOS এর জন্য path_provider লাগবে)
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/transactions_report.csv');
    await file.writeAsString(csvData);

    print("Exported to: ${file.path}");
  }
}