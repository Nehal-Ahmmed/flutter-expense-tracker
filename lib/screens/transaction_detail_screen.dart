import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.redAccent : Colors.green;

    String categoryName = 'Others';
    if (isExpense &&
        transaction.goods != null &&
        transaction.goods!.isNotEmpty) {
      // প্রথম আইটেমের ক্যাটাগরি নিচ্ছে, কারণ ট্রানজেকশন লেভেলে ক্যাটাগরি নেই
      categoryName =
          transaction.goods!.first.category?.toString().split('.').last ??
          'Shopping';
      // প্রথম অক্ষর বড় হাতের করার জন্য (Optional):
      categoryName = categoryName[0].toUpperCase() + categoryName.substring(1);
    } else if (!isExpense) {
      categoryName = 'Salary';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Amount Circle
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              transaction.title,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${isExpense ? "-" : "+"}\$${transaction.amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 40),

            // Details Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    Icons.category,
                    'Category',
                    categoryName,
                  ),
                  const Divider(height: 30),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Date',
                    DateFormat('MMMM dd, yyyy').format(transaction.date),
                  ),
                  const Divider(height: 30),
                  _buildDetailRow(
                    context,
                    Icons.access_time,
                    'Time',
                    DateFormat('hh:mm a').format(transaction.date),
                  ),
                  const Divider(height: 30),
                  _buildDetailRow(
                    context,
                    Icons.notes,
                    'Note',
                    'No additional notes',
                  ), // Placeholder for notes if model doesn't have it
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
