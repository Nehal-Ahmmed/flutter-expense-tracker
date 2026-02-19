import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:untitled/models/transaction.dart';
import 'package:untitled/utils/theme.dart';

class Expensepdfservice {
  //method for generate pdf bytes
  static Future<Uint8List> generateExpenseTransactionReport(Transaction transaction) async {
    final pdf = pw.Document();

    if(transaction.goods == null || transaction.goods!.isEmpty){
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Expense Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headers: [
                'Title',
                'Unit Price',
                'Quantity',
                'Total Price',
                'Description',
                'Category',
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueAccent,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerRight,
              },
              data: transaction.goods!.map( (gd) {
                return[
                  gd.name,
                  gd.price,
                  gd.quantity,
                  "${(gd.quantity ?? 0) * (gd.price ?? 0)} TK",
                  gd.desc,
                  gd.category?.name
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 30),

            pw.Text(
              'Summary',
              style:  pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold
              )
            ),

            pw.SizedBox(height: 10),

            pw.Container(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                    children: [
                      _row('Total Items', transaction.goods!.length.toString()),
                      // //english comment: Fixed fold logic to use object properties instead of map keys
                      _row('Total Quantity', transaction.goods!.fold(0, (sum, item) => sum + (item.quantity ?? 0)).toString()),
                      pw.Divider(),
                      _row('Grand Total', "${transaction.goods!.fold(0.0, (sum, item) => sum + ((item.quantity ?? 0) * (item.price ?? 0))).toStringAsFixed(2)} TK"),
                    ]
                )
            )
          ];
        },
      ),
    );
    return pdf.save();
  }


  //row
  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label), pw.Text(value)],
      ),
    );
  }

  static Future<void> sharePdf(Transaction transaction) async{
    final data = await generateExpenseTransactionReport(transaction);
    await Printing.sharePdf(bytes: data,filename: 'expense_report_${transaction.id}.pdf');
  }

  static Future<void> savePdf(Transaction transaction) async{
    final data =await generateExpenseTransactionReport(transaction);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => data,
      name: 'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    // final directory = await getApplicationDocumentsDirectory();
    // final file = File('${directory.path}/expense_${transaction.id}.pdf');
    // await file.writeAsBytes(data);
    // return file.path;
  }

}
