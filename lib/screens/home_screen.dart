import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/providers/navigation_provider.dart';
import 'package:untitled/utils/theme.dart';
import 'package:untitled/widgets/app_drawer.dart';
import 'package:untitled/widgets/dashboard/summary_card.dart';
import 'package:untitled/widgets/dashboard/transaction_item.dart';
import 'package:untitled/widgets/dashboard/premium_bar_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final recentTransactions = expenseProvider.recentTransactions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'User Name',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Section
            Text(
              'Spending Analysis',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const PremiumBarChart(),
            const SizedBox(height: 24),

            // Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SummaryCard(
                    title: 'Total Balance',
                    amount:
                        '\$${expenseProvider.totalBalance.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  SummaryCard(
                    title: 'Income',
                    amount:
                        '\$${expenseProvider.totalIncome.toStringAsFixed(2)}',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  SummaryCard(
                    title: 'Expenses',
                    amount:
                        '\$${expenseProvider.totalExpense.toStringAsFixed(2)}',
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<NavigationProvider>(
                      context,
                      listen: false,
                    ).setIndex(1);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                return TransactionItem(transaction: recentTransactions[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
