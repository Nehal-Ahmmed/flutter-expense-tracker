import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:untitled/models/transaction.dart';
import 'package:intl/intl.dart';

class FinalPdfService {
  static Future<void> generateTransactionReport(
    List<Transaction> transactions,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        // MultiPage ব্যবহার করা ভালো যাতে ডেটা বেশি হলে অটোমেটিক নতুন পেজ নেয়
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Final Report',
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

            // Table
            pw.Table.fromTextArray(
              headers: ['Date', 'Title', 'Type', 'Details', 'Total'],
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
              data: transactions.map((tx) {
                // Goods গুলোর একটা ছোট সামারি তৈরি করছি PDF এর এক সেলে দেখানোর জন্য
                String goodsSummary = tx.goods != null
                    ? tx.goods!
                          .map((g) => "${g.name} (x${g.quantity})")
                          .join(", ")
                    : "No items";

                return [
                  DateFormat('yyyy-MM-dd').format(tx.date),
                  tx.title,
                  tx.type.name.toUpperCase(),
                  goodsSummary,
                  "${tx.amount.toStringAsFixed(2)} TK",
                ];
              }).toList(),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 20),
              child: pw.Divider(),
            ),

            // Grand Total calculation
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: ${transactions.fold(0.0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)} TK',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );

    // সরাসরি প্রিন্ট বা সেভ ডায়ালগ দেখানোর জন্য
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static Future<void> shareTransactionReport(
    List<Transaction> transactions,
  ) async {
    final pdf = pw.Document();

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
              headers: ['Date', 'Title', 'Type', 'Details', 'Total'],
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
              data: transactions.map((tx) {
                String goodsSummary = tx.goods != null
                    ? tx.goods!
                          .map((g) => "${g.name} (x ${g.quantity})")
                          .join(", ")
                    : 'No items';

                return [
                  DateFormat('yyyyy-MM-dd').format(tx.date),
                  tx.title,
                  tx.type.name.toUpperCase(),
                  goodsSummary,
                  "${tx.amount.toStringAsFixed(2)} TK",
                ];
              }).toList(),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 20),
              child: pw.Divider(),
            ),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: ${transactions.fold(0.0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)} TK',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final pdfBytes =await pdf.save();

    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdfBytes,
    //   name: 'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    // );

    await Printing.sharePdf(bytes: pdfBytes, filename: 'expense_report.pdf');
  }
}
