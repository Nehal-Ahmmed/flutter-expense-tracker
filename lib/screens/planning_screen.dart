import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/models/transaction.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/utils/theme.dart';

import 'package:untitled/widgets/dashboard/premium_pie_chart.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final transactions = expenseProvider.transactions;

    // Calculate Category Spending
    Map<CategoryType, double> categorySpending = {};
    double totalExpense = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
        categorySpending.update(
          tx.category,
          (value) => value + tx.amount,
          ifAbsent: () => tx.amount,
        );
      }
    }

    // Sort categories by spending
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics & Planning',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Section
            Text(
              'Expense Breakdown',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320, // Increased height for badges
              child: totalExpense == 0
                  ? Center(
                      child: Text(
                        'No expenses yet',
                        style: GoogleFonts.outfit(color: Colors.grey),
                      ),
                    )
                  : PremiumPieChart(
                      categorySpending: categorySpending,
                      totalExpense: totalExpense,
                    ),
            ),
            const SizedBox(height: 32),

            // Category List
            Text(
              'Detailed Spend',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedCategories.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final entry = sortedCategories[index];
                final category = entry.key;
                final amount = entry.value;
                final percentage = (amount / totalExpense) * 100;

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, color: category.color),
                  ),
                  title: Text(
                    category.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            // Dummy Budget Section
            Text(
              'Monthly Budget',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Limit'),
                      Text(
                        '\$2,000.00',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: totalExpense / 2000 > 1 ? 1 : totalExpense / 2000,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        totalExpense > 2000
                            ? Colors.red
                            : AppTheme.primaryColor,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((totalExpense / 2000) * 100).toStringAsFixed(1)}% used',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
